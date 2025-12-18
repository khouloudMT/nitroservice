import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final booking = ModalRoute.of(context)!.settings.arguments as BookingModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la réservation'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Share booking details
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Statut header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(booking.status),
                    size: 60,
                    color: _getStatusColor(booking.status),
                  ),
                  SizedBox(height: 12),
                  Text(
                    booking.getStatusText(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service
                  _buildSection(
                    'Service',
                    [
                      _buildDetailRow(Icons.build, 'Service', booking.serviceName),
                      _buildDetailRow(
                        Icons.payments,
                        'Prix',
                        '${booking.totalPrice.toStringAsFixed(0)} DT',
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Mécanicien
                  if (booking.mechanicName != null && booking.mechanicName!.isNotEmpty)
                    _buildSection(
                      'Mécanicien',
                      [
                        _buildDetailRow(Icons.person, 'Nom', booking.mechanicName!),
                        _buildDetailRow(Icons.phone, 'Téléphone', booking.mechanicPhone ?? 'N/A'),
                      ],
                    )
                  else
                    SizedBox.shrink(),

                  SizedBox(height: 24),
                  _buildSection(
                    'Date & Heure',
                    [
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        DateFormat('dd/MM/yyyy').format(booking.scheduledDate),
                      ),
                      _buildDetailRow(
                        Icons.access_time,
                        'Heure',
                        DateFormat('HH:mm').format(booking.scheduledDate),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Adresse
                  _buildSection(
                    'Localisation',
                    [
                      _buildDetailRow(
                        Icons.location_on,
                        'Adresse',
                        booking.address,
                      ),
                    ],
                  ),

                  if (booking.notes != null) ...[
                    SizedBox(height: 24),
                    _buildSection(
                      'Notes',
                      [
                        Text(
                          booking.notes!,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 24),

                  // Boutons d'action
                  if (booking.status == BookingStatus.confirmed) ...[
                    CustomButton(
                      text: 'Voir sur la carte',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/map',
                          arguments: {
                            'latitude': booking.latitude,
                            'longitude': booking.longitude,
                          },
                        );
                      },
                      icon: Icons.map,
                    ),
                    SizedBox(height: 12),
                    CustomButton(
                      text: 'Contacter le mécanicien',
                      onPressed: () {
                        // TODO: Call mechanic
                      },
                      icon: Icons.phone,
                      isOutlined: true,
                    ),
                  ],

                  if (booking.status == BookingStatus.completed) ...[
                    CustomButton(
                      text: 'Donner un avis',
                      onPressed: () {
                        // TODO: Rate service
                      },
                      icon: Icons.star,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.info;
      case BookingStatus.inProgress:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.build_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }
}