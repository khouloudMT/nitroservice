import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/service_model.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  ServiceModel? _selectedService;
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceModel> get services => _filteredServices.isEmpty ? _services : _filteredServices;
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger tous les services
  Future<void> loadServices() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _services = await _apiService.getServices();
      _filteredServices = [];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger service par ID
  Future<void> loadServiceById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedService = await _apiService.getServiceById(id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rechercher services
  void searchServices(String query) {
    if (query.isEmpty) {
      _filteredServices = [];
    } else {
      _filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(query.toLowerCase()) ||
               service.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Filtrer par catégorie
  void filterByCategory(String category) {
    if (category.isEmpty || category == 'Tous') {
      _filteredServices = [];
    } else {
      _filteredServices = _services.where((service) {
        return service.category == category;
      }).toList();
    }
    notifyListeners();
  }

  // Services populaires
  List<ServiceModel> get popularServices {
    return _services.where((service) => service.isPopular).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
