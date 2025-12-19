import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Firebase Options
import 'firebase_options.dart';

// Services
import 'services/payment_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/location_provider.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/services/services_list_screen.dart';
import 'screens/services/service_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_history_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/premium/premium_screen.dart';

// Theme & Constants
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  // Initialize Stripe
  await PaymentService.initStripe();
  
  try {
    // Initialiser Firebase avec les options de configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized');
  } catch (e) {
    print('Firebase error: $e');
  }
  
  runApp(const NitroServiceApp());
}

class NitroServiceApp extends StatelessWidget {
  const NitroServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),

      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => SplashScreen(),
          AppRoutes.onboarding: (context) => OnboardingScreen(),
          AppRoutes.login: (context) => LoginScreen(),
          AppRoutes.register: (context) => RegisterScreen(),
          AppRoutes.home: (context) => HomeScreen(),
          AppRoutes.services: (context) => ServicesListScreen(),
          AppRoutes.serviceDetail: (context) => ServiceDetailScreen(),
          AppRoutes.bookingForm: (context) => BookingFormScreen(),
          AppRoutes.bookingHistory: (context) => BookingHistoryScreen(),
          AppRoutes.bookingDetail: (context) => BookingDetailScreen(),
          AppRoutes.map: (context) => MapScreen(),
          AppRoutes.profile: (context) => ProfileScreen(),
          AppRoutes.editProfile: (context) => EditProfileScreen(),
          AppRoutes.settings: (context) => SettingsScreen(),
          AppRoutes.premium: (context) => PremiumScreen(),
        },
      ),
    );
  }
}