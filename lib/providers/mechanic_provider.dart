import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mechanic_model.dart';

class MechanicProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<MechanicModel> _mechanics = [];
  MechanicModel? _selectedMechanic;
  bool _isLoading = false;
  String? _errorMessage;

  List<MechanicModel> get mechanics => _mechanics;
  MechanicModel? get selectedMechanic => _selectedMechanic;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load available mechanics
  Future<void> loadMechanics() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _mechanics = await _apiService.getAvailableMechanics();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select mechanic
  void selectMechanic(MechanicModel mechanic) {
    _selectedMechanic = mechanic;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedMechanic = null;
    notifyListeners();
  }

  // Get available mechanics
  List<MechanicModel> get availableMechanics {
    return _mechanics.where((m) => m.available).toList();
  }

  // Find nearest mechanic
  MechanicModel? findNearestMechanic(double userLat, double userLon) {
    if (_mechanics.isEmpty) return null;

    MechanicModel? nearest;
    double minDistance = double.infinity;

    for (var mechanic in _mechanics.where((m) => m.available)) {
      double distance = _calculateDistance(
        userLat,
        userLon,
        mechanic.latitude,
        mechanic.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = mechanic;
      }
    }

    return nearest;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple distance calculation (not accurate for long distances)
    double dx = lat2 - lat1;
    double dy = lon2 - lon1;
    return (dx * dx + dy * dy); // Square of distance, good enough for comparison
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}