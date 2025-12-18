import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/mechanic_model.dart';

class ApiService {
  // Remplacez par votre URL MockAPI
  static const String baseUrl = 'https://692dfaa9e5f67cd80a4d9187.mockapi.io/api/v1/';

  // GET - Services
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // GET - Service par ID
  Future<ServiceModel> getServiceById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/services/$id'));
    
    if (response.statusCode == 200) {
      return ServiceModel.fromJson(json.decode(response.body));
    }
    throw Exception('Service introuvable');
  }

  // GET - Mécaniciens disponibles
  Future<List<MechanicModel>> getAvailableMechanics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mechanics'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => MechanicModel.fromJson(json)).toList();
      }
      throw Exception('Erreur de chargement');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}