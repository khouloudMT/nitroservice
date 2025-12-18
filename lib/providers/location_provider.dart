import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  String _currentAddress = '';
  bool _isLoading = false;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Obtenir position actuelle
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      Position? position = await _locationService.getCurrentLocation();
      
      if (position != null) {
        _currentPosition = position;
        _currentAddress = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } else {
        _errorMessage = 'Permission de localisation refusée';
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur de localisation';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculer distance
  double? calculateDistanceFromCurrent(double lat, double lon) {
    if (_currentPosition == null) return null;
    
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lon,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}