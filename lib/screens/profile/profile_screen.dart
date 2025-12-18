import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec avatar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: userProfile?.hasProfilePicture ?? false
                        ? _getImageProvider(userProfile!.profilePictureBase64!)
                        : null,
                    child: (userProfile?.hasProfilePicture ?? false)
                        ? null
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userProfile?.name ?? 'Utilisateur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    authProvider.user?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  if (userProfile?.isPremium == true) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Membre Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Statistiques
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Réservations',
                      bookingProvider.bookings.length.toString(),
                      Icons.calendar_today,
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Terminées',
                      bookingProvider.completedBookings.length.toString(),
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'En cours',
                      bookingProvider.pendingBookings.length.toString(),
                      Icons.schedule,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Menu options
            _buildMenuItem(
              context,
              Icons.person_outline,
              'Modifier le profil',
              () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
            
            _buildMenuItem(
              context,
              Icons.history,
              'Historique des réservations',
              () {
                // Changer d'onglet vers historique
              },
            ),
            
            _buildMenuItem(
              context,
              Icons.star_outline,
              'Passer Premium',
              () {
                Navigator.pushNamed(context, '/premium');
              },
              trailing: userProfile?.isPremium == true 
                  ? Icon(Icons.check_circle, color: AppColors.success)
                  : Icon(Icons.arrow_forward_ios, size: 16),
            ),
            
            _buildMenuItem(
              context,
              Icons.payment,
              'Moyens de paiement',
              () {
                // TODO: Payment methods
              },
            ),
            
            _buildMenuItem(
              context,
              Icons.notifications_outlined,
              'Notifications',
              () {
                // TODO: Notifications settings
              },
            ),
            
            _buildMenuItem(
              context,
              Icons.settings,
              'Paramètres',
              () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Aide & Support',
              () {
                // TODO: Support
              },
            ),
            
            _buildMenuItem(
              context,
              Icons.info_outline,
              'À propos',
              () {
                _showAboutDialog(context);
              },
            ),
            
            SizedBox(height: 24),
            
            // Bouton déconnexion
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Déconnexion'),
                        content: Text('Voulez-vous vraiment vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Déconnexion',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await authProvider.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  icon: Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'Déconnexion',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.build_circle, size: 50, color: AppColors.primary),
      children: [
        SizedBox(height: 16),
        Text(AppStrings.appTagline),
        SizedBox(height: 16),
        Text('© 2024 NitroService. Tous droits réservés.'),
      ],
    );
  }

  ImageProvider _getImageProvider(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      print('Error decoding base64: $e');
      return AssetImage('assets/images/placeholder.png');
    }
  }
}