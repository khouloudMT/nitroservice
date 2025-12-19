import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  // Load Stripe keys from .env file
  static String get publishableKey => 
    dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  
  static String get secretKey => 
    dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  /// Initialize Stripe
  static Future<void> initStripe() async {
    try {
      if (publishableKey.isEmpty) {
        print(' Stripe publishable key not found in .env');
        return;
      }
      
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      print('Stripe initialized');
    } catch (e) {
      print(' Stripe init error: $e');
    }
  }

  /// Process payment - simplest implementation
  static Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String description, required String currency,
  }) async {
    try {
      // Validate keys
      print('Checking payment keys...');
      print('Publishable key: ${publishableKey.isNotEmpty ? 'Loaded' : '❌ Empty'}');
      print('Secret key: ${secretKey.isNotEmpty ? ' Loaded' : ' Empty'}');
      
      if (publishableKey.isEmpty || secretKey.isEmpty) {
        print('Payment keys missing!');
        if (context.mounted) {
          _showError(context, 'Payment configuration error. Check your .env file.');
        }
        return false;
      }
      
      print('💳 Processing $amount USD payment...');

      // Create payment intent
      final Map<String, dynamic> paymentIntentData = await _createPaymentIntent(amount);
      
      if (paymentIntentData.isEmpty) {
        print('Payment intent is empty!');
        if (context.mounted) {
          _showError(context, 'Failed to initialize payment');
        }
        return false;
      }

      print('Payment intent received');
      
      // Initialize and present payment sheet
      print('Initializing payment sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'NitroService',
          style: ThemeMode.system,
        ),
      );

      print('Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();
      
      print('Payment completed successfully!');
      if (context.mounted) {
        _showSuccess(context, 'Payment successful!');
      }
      return true;

    } on StripeException catch (e) {
      print('StripeException detected');
      print('Code: ${e.error.code}');
      print('Message: ${e.error.message}');
      
      if (e.error.code != FailureCode.Canceled) {
        if (context.mounted) {
          _showError(context, 'Payment Error: ${e.error.message ?? "Unknown error"}');
        }
      } else {
        print('User cancelled payment');
      }
      return false;
    } catch (e) {
      print('Unexpected Error: $e');
      print('   Type: ${e.runtimeType}');
      if (context.mounted) {
        _showError(context, 'Error: ${e.toString()}');
      }
      return false;
    }
  }

  /// Create payment intent via API
  static Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    try {
      print('Creating payment intent on Stripe...');
      
      final body = {
        'amount': (amount * 100).toInt().toString(),
        'currency': 'usd',
      };

      print('   Amount: ${body["amount"]} cents (${amount} USD)');
      print('   Currency: ${body["currency"]}');

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Intent ID: ${data['id']}');
        return data;
      } else {
        print(' Status ${response.statusCode}');
        print(' Error: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Network Error: $e');
      return {};
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}