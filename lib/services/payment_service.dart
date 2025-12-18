import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  // =============================================================================
  // Load Stripe keys from .env file for security
  // Get your keys from: https://dashboard.stripe.com/test/apikeys
  // =============================================================================
  
  // Publishable key (starts with pk_test_ for testing)
  static String get publishableKey => 
    dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  
  // Secret key (starts with sk_test_ for testing) 
  // ⚠️ NEVER expose this in production! Use a backend server instead
  static String get secretKey => 
    dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  
  // Optional: Your backend URL if you have one
  static String? get backendUrl => dotenv.env['BACKEND_URL'];
  
  // =============================================================================

  /// Initialize Stripe with your publishable key
  /// Call this in main.dart before runApp()
  static Future<void> initStripe() async {
    try {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      print('✅ Stripe initialized successfully');
    } catch (e) {
      print('❌ Error initializing Stripe: $e');
      rethrow;
    }
  }

  /// Create a Payment Intent on Stripe
  /// This prepares a payment for processing
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to cents (Stripe uses smallest currency unit)
      // For example: 25.50 TND = 2550 cents
      int amountInCents = (amount * 100).toInt();

      print('Creating payment intent for $amountInCents cents ($amount $currency)');

      // Prepare request body
      Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
        'currency': currency.toLowerCase(),
        'payment_method_types[]': 'card',
        'description': 'NitroService Payment',
      };

      // Add customer ID if provided
      if (customerId != null && customerId.isNotEmpty) {
        body['customer'] = customerId;
      }

      // Add metadata if provided
      if (metadata != null) {
        metadata.forEach((key, value) {
          body['metadata[$key]'] = value.toString();
        });
      }

      // Make API request to Stripe
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Payment intent created: ${data['id']}');
        return data;
      } else {
        print('❌ Error creating payment intent: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in createPaymentIntent: $e');
      return null;
    }
  }

  /// Process a payment using Stripe Payment Sheet
  /// This is the main method to charge a customer
  static Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    String? customerEmail,
    String? customerName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🔄 Starting payment process...');

      // Step 1: Create Payment Intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      if (paymentIntent == null) {
        _showError(context, 'Échec de l\'initialisation du paiement');
        return false;
      }

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Payment Intent client secret
          paymentIntentClientSecret: paymentIntent['client_secret'],
          
          // Merchant display name
          merchantDisplayName: 'NitroService',
          
          // Customer information
          customerEphemeralKeySecret: null, // Optional: for saved cards
          customerId: null, // Optional: Stripe customer ID
          
          // Billing details
          billingDetails: BillingDetails(
            email: customerEmail,
            name: customerName,
          ),
          
          // UI customization
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6C63FF), // Your brand color
            ),
          ),
          
          // Enable features
          allowsDelayedPaymentMethods: false,
        ),
      );

      print('✅ Payment sheet initialized');

      // Step 3: Present Payment Sheet to user
      await Stripe.instance.presentPaymentSheet();

      print('✅ Payment successful!');
      
      // Payment succeeded
      _showSuccess(context, 'Paiement réussi !');
      return true;

    } on StripeException catch (e) {
      print('❌ Stripe error: ${e.error.code}');
      
      // Handle different error types
      if (e.error.code == FailureCode.Canceled) {
        _showError(context, 'Paiement annulé');
      } else if (e.error.code == FailureCode.Failed) {
        _showError(context, 'Paiement échoué: ${e.error.message}');
      } else {
        _showError(context, 'Erreur: ${e.error.localizedMessage ?? e.error.message}');
      }
      return false;
      
    } catch (e) {
      print('❌ Unexpected error: $e');
      _showError(context, 'Une erreur inattendue s\'est produite');
      return false;
    }
  }

  /// Process payment for Premium Subscription
  static Future<bool> processPremiumPayment({
    required BuildContext context,
    required String userId,
    required String userName,
    required String email,
    required bool isMonthly,
  }) async {
    final amount = isMonthly ? 25.0 : 250.0;
    final planName = isMonthly ? 'Premium Mensuel' : 'Premium Annuel';
    
    print('💳 Processing premium payment: $planName for $amount TND');

    return await processPayment(
      context: context,
      amount: amount,
      currency: 'tnd', // Tunisian Dinar
      description: 'Abonnement $planName',
      customerEmail: email,
      customerName: userName,
      metadata: {
        'userId': userId,
        'userName': userName,
        'email': email,
        'subscriptionType': isMonthly ? 'monthly' : 'annual',
        'type': 'premium_subscription',
        'planName': planName,
      },
    );
  }

  /// Process payment for Service Booking
  static Future<bool> processBookingPayment({
    required BuildContext context,
    required String userId,
    required String userName,
    required String email,
    required double amount,
    required String serviceId,
    required String serviceName,
    String? bookingId,
  }) async {
    print('💳 Processing booking payment: $serviceName for $amount TND');

    return await processPayment(
      context: context,
      amount: amount,
      currency: 'tnd',
      description: 'Service: $serviceName',
      customerEmail: email,
      customerName: userName,
      metadata: {
        'userId': userId,
        'userName': userName,
        'email': email,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'type': 'service_booking',
        if (bookingId != null) 'bookingId': bookingId,
      },
    );
  }

  /// Process custom payment
  static Future<bool> processCustomPayment({
    required BuildContext context,
    required double amount,
    required String description,
    required Map<String, dynamic> metadata,
    String? customerEmail,
    String? customerName,
  }) async {
    print('💳 Processing custom payment: $description for $amount TND');

    return await processPayment(
      context: context,
      amount: amount,
      currency: 'tnd',
      description: description,
      customerEmail: customerEmail,
      customerName: customerName,
      metadata: metadata,
    );
  }

  /// Show error message to user
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  /// Show success message to user
  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Validate Stripe keys (for debugging)
  static bool validateKeys() {
    bool isValid = true;
    
    if (!publishableKey.startsWith('pk_')) {
      print('❌ Invalid publishable key format');
      isValid = false;
    }
    
    if (!secretKey.startsWith('sk_')) {
      print('❌ Invalid secret key format');
      isValid = false;
    }
    
    if (publishableKey.contains('YOUR') || secretKey.contains('YOUR')) {
      print('❌ Please replace placeholder keys with actual Stripe keys');
      isValid = false;
    }
    
    if (isValid) {
      print('✅ Stripe keys validation passed');
    }
    
    return isValid;
  }
}

// =============================================================================
// STRIPE TEST CARDS
// =============================================================================
// Use these test card numbers during development:
//
// SUCCESS:
// - 4242 4242 4242 4242 (Visa)
// - 5555 5555 5555 4444 (Mastercard)
// - 3782 822463 10005 (American Express)
//
// DECLINE:
// - 4000 0000 0000 0002 (Card declined)
// - 4000 0000 0000 9995 (Insufficient funds)
//
// Use any future expiry date (e.g., 12/34)
// Use any 3-digit CVC (e.g., 123)
// Use any ZIP code (e.g., 12345)
//
// Full list: https://stripe.com/docs/testing#cards
// =============================================================================