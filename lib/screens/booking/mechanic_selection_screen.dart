import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/mechanic_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/loading_widget.dart';

class MechanicSelectionScreen extends StatefulWidget {
  @override
  _MechanicSelectionScreenState createState() => _MechanicSelectionScreenState();
}

class _MechanicSelectionScreenState extends State<MechanicSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mechanicProvider = Provider.of<MechanicProvider>(context, listen: false);
      if (mechanicProvider.mechanics.isEmpty) {
        mechanicProvider.loadMechanics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir un mécanicien'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer2<MechanicProvider, LocationProvider>(
        builder: (context, mechanicProvider, locationProvider, child) {
          if (mechanicProvider.isLoading) {
            return Center(
              child: LoadingWidget(message: 'Chargement des mécaniciens...'),
            );
          }

          if (mechanicProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  SizedBox(height: 16),
                  Text(
                    mechanicProvider.errorMessage!,
                    style: TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => mechanicProvider.loadMechanics(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final mechanics = mechanicProvider.availableMechanics;

          if (mechanics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun mécanicien disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      '${mechanics.length} mécanicien(s) disponible(s)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => mechanicProvider.loadMechanics(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: mechanics.length,
                    itemBuilder: (context, index) {
                      final mechanic = mechanics[index];
                      final distance = locationProvider.currentPosition != null
                          ? locationProvider.calculateDistanceFromCurrent(
                              mechanic.latitude,
                              mechanic.longitude,
                            )
                          : null;

                      return _buildMechanicCard(context, mechanic, distance);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMechanicCard(
    BuildContext context,
    MechanicModel mechanic,
    double? distance,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Provider.of<MechanicProvider>(context, listen: false)
              .selectMechanic(mechanic);
          Navigator.pop(context, mechanic);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              mechanic.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                            if (distance != null) ...[
                              SizedBox(width: 12),
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                '${distance.toStringAsFixed(1)} km',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Disponible',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    mechanic.phone,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mechanic.specialties.map((specialty) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}