import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../services/api_service.dart';
import '../../models/mechanic_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/loading_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<MechanicModel> _mechanics = [];
  bool _isLoading = true;
  MechanicModel? _selectedMechanic;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Obtenir position actuelle
    await locationProvider.getCurrentLocation();
    
    // Charger mécaniciens
    try {
      final apiService = ApiService();
      _mechanics = await apiService.getAvailableMechanics();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement des mécaniciens'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    if (_isLoading || locationProvider.currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mécaniciens Disponibles'),
        ),
        body: LoadingWidget(message: 'Chargement de la carte...'),
      );
    }

    final currentPosition = LatLng(
      locationProvider.currentPosition!.latitude,
      locationProvider.currentPosition!.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Mécaniciens Disponibles'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(currentPosition, 15);
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showMechanicsList,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition,
              initialZoom: 13.0,
              onTap: (_, __) {
                setState(() {
                  _selectedMechanic = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nitroservice',
              ),
              MarkerLayer(
                markers: [
                  // Marqueur position utilisateur
                  Marker(
                    point: currentPosition,
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.person_pin_circle,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                  // Marqueurs mécaniciens
                  ..._mechanics.map((mechanic) {
                    return Marker(
                      point: LatLng(mechanic.latitude, mechanic.longitude),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMechanic = mechanic;
                          });
                          _showMechanicInfo(mechanic);
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: mechanic.available 
                                    ? AppColors.success 
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.build,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${mechanic.rating}⭐',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
          
          // Légende
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Votre position', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Disponible', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Occupé', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.services);
        },
        icon: const Icon(Icons.add),
        label: const Text('Réserver un service'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showMechanicInfo(MechanicModel mechanic) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        final distance = locationProvider.calculateDistanceFromCurrent(
          mechanic.latitude,
          mechanic.longitude,
        );

        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 30, color: AppColors.primary),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mechanic.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              '${mechanic.rating}/5',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: mechanic.available 
                          ? AppColors.success.withOpacity(0.1) 
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mechanic.available ? 'Disponible' : 'Occupé',
                      style: TextStyle(
                        color: mechanic.available ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Distance
              if (distance != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'À ${distance.toStringAsFixed(1)} km de vous',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              
              SizedBox(height: 12),
              
              // Téléphone
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    mechanic.phone,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Spécialités
              Row(
                children: [
                  Icon(Icons.build, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: mechanic.specialties.map((specialty) {
                        return Chip(
                          label: Text(specialty, style: TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: AppColors.primary),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Boutons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Call mechanic
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.phone),
                      label: Text('Appeler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Show a dialog to select a service first
                        _showServiceSelection(mechanic);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Réserver'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMechanicsList() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mécaniciens Disponibles (${_mechanics.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _mechanics.length,
                    itemBuilder: (context, index) {
                      final mechanic = _mechanics[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: mechanic.available 
                                ? AppColors.success 
                                : AppColors.error,
                            child: Icon(Icons.build, color: Colors.white),
                          ),
                          title: Text(
                            mechanic.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text('${mechanic.rating}'),
                                ],
                              ),
                              Text(
                                mechanic.specialties.join(', '),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            _mapController.move(
                              LatLng(mechanic.latitude, mechanic.longitude),
                              15,
                            );
                            _showMechanicInfo(mechanic);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showServiceSelection(MechanicModel mechanic) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingForm,
      arguments: {
        'mechanic': mechanic,
      },
    );
  }
}