# 🚗 NitroService

**NitroService** is a comprehensive on-demand vehicle service and mechanic booking platform built with Flutter. Connect with certified mechanics, schedule services, track bookings in real-time, and manage your vehicle maintenance—all from one intuitive mobile application.

## 📱 Features

### User Features
- **🔐 Secure Authentication** - Email/password registration and login with Firebase Authentication
- **🔍 Service Discovery** - Browse and search from a wide range of vehicle services
- **📍 Real-time Location** - Find nearby mechanics with integrated map view
- **📅 Easy Booking** - Schedule services with preferred mechanics at your convenience
- **💳 Secure Payments** - Integrated Stripe payment processing
- **📊 Booking History** - Track all your past and upcoming service appointments
- **⭐ Premium Membership** - Access exclusive features and priority service
- **👤 Profile Management** - Update your details and manage preferences
- **📸 Image Upload** - Share vehicle photos for accurate service quotes

### Technical Features
- **Cross-platform** - iOS, Android, Web, Windows, macOS, and Linux support
- **Offline Support** - Cached data with SharedPreferences
- **Real-time Updates** - Cloud Firestore integration for live data sync
- **Responsive UI** - Beautiful animations with Flutter Animate
- **State Management** - Efficient Provider pattern implementation
- **Clean Architecture** - Organized codebase with separation of concerns

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.x
- **Language:** Dart 3.9.2+
- **State Management:** Provider


### Backend & Services
- **Authentication:** Firebase Auth
- **Database:** Cloud Firestore
- **Storage:** Firebase Storage
- **Payment:** Stripe
- **Maps:** Flutter Map with Latlong2
- **Location:** Geolocator & Geocoding





## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants (colors, routes, strings)
│   ├── theme/          # Application theme configuration
│   └── utils/          # Helper functions and validators
├── models/             # Data models (User, Booking, Service, Mechanic)
├── providers/          # State management providers
├── screens/            # UI screens organized by feature
│   ├── auth/          # Login & Registration
│   ├── booking/       # Booking management
│   ├── home/          # Dashboard & Home
│   ├── map/           # Map view
│   ├── premium/       # Premium features
│   ├── profile/       # User profile
│   ├── services/      # Service listings
│   └── settings/      # App settings
├── services/           # Business logic services
│   ├── api_service.dart
│   ├── firebase_service.dart
│   ├── location_service.dart
│   └── payment_service.dart
└── widgets/            # Reusable UI components
```

## 🎯 Key Functionalities

### Authentication Flow
- User registration with email verification
- Secure login with Firebase Authentication
- Password reset functionality
- Session management

### Booking System
1. Browse available services
2. Select preferred mechanic
3. Choose date and time
4. Provide vehicle details
5. Confirm and pay
6. Track booking status in real-time

### Location Services
- GPS-based mechanic discovery
- Real-time location tracking
- Distance calculation
- Address geocoding

## 🔒 Security

- Firebase Authentication for secure user management
- Environment variables for sensitive data
- Secure payment processing with Stripe
- Data validation and sanitization



**Made with ❤️ using Flutter**
