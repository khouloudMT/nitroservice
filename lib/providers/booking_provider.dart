
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Récupérer réservations de l'utilisateur
  void getUserBookings(String userId) {
    print('📌 Fetching bookings for user: $userId');
    _firebaseService.getUserBookings(userId).listen((bookings) {
      print('✅ Bookings received: ${bookings.length}');
      for (var booking in bookings) {
        print('   - ${booking.serviceName} (${booking.status.name}) on ${booking.scheduledDate}');
      }
      _bookings = bookings;
      notifyListeners();
    }, onError: (error) {
      print('❌ Error fetching bookings: $error');
      _errorMessage = 'Erreur lors du chargement des réservations';
      notifyListeners();
    });
  }

  // Créer nouvelle réservation
  Future<bool> createBooking({
    required String userId,
    required String serviceId,
    required String serviceName,
    required DateTime scheduledDate,
    required String address,
    required double latitude,
    required double longitude,
    required double totalPrice,
    String? notes,
    String? mechanicId,
    String? mechanicName,
    String? mechanicPhone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      BookingModel booking = BookingModel(
        id: '',
        userId: userId,
        serviceId: serviceId,
        serviceName: serviceName,
        scheduledDate: scheduledDate,
        address: address,
        latitude: latitude,
        longitude: longitude,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        notes: notes,
        mechanicId: mechanicId,
        mechanicName: mechanicName,
        mechanicPhone: mechanicPhone,
        createdAt: DateTime.now(),
      );

      print('📤 Saving to Firestore...');
      final bookingId = await _firebaseService.createBooking(booking);
      print('✅ Booking created with ID: $bookingId');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error creating booking: $e');
      _errorMessage = 'Erreur lors de la création de la réservation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Annuler réservation
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.cancelBooking(bookingId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'annulation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Filtrer par statut
  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // Réservations en attente
  List<BookingModel> get pendingBookings {
    return _bookings.where((b) => b.status == BookingStatus.pending).toList();
  }

  // Réservations terminées
  List<BookingModel> get completedBookings {
    return _bookings.where((b) => b.status == BookingStatus.completed).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}