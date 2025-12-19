import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart' as payment_service;
import '../../services/firebase_service.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class PremiumScreen extends StatelessWidget {
  PremiumScreen({Key? key}) : super(key: key);

  final FirebaseService _firebaseService = FirebaseService();

  final List<PremiumFeature> _features = [
    PremiumFeature(
      icon: Icons.priority_high,
      title: 'Priorité des réservations',
      description: 'Passez en tête de file pour vos réservations',
    ),
    PremiumFeature(
      icon: Icons.monitor_heart,
      title: 'Diagnostic intelligent',
      description: 'Analyse avancée de l\'état de votre véhicule avec boîtier connecté',
    ),
    PremiumFeature(
      icon: Icons.support_agent,
      title: 'Support 24/7',
      description: 'Assistance dédiée disponible à tout moment',
    ),
    PremiumFeature(
      icon: Icons.discount,
      title: 'Réductions exclusives',
      description: 'Jusqu\'à 20% de réduction sur tous les services',
    ),
    PremiumFeature(
      icon: Icons.calendar_month,
      title: 'Réservations illimitées',
      description: 'Aucune limite sur le nombre de réservations',
    ),
    PremiumFeature(
      icon: Icons.eco,
      title: 'Diagnostic CO₂',
      description: 'Mesurez l\'impact écologique de votre véhicule',
    ),
    PremiumFeature(
      icon: Icons.history,
      title: 'Historique détaillé',
      description: 'Accès complet à l\'historique de maintenance',
    ),
    PremiumFeature(
      icon: Icons.notifications_active,
      title: 'Rappels automatiques',
      description: 'Notifications pour l\'entretien préventif',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isPremium = authProvider.userProfile?.isPremium ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.star,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPremium) ...[
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 32),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vous êtes Premium !',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  'Profitez de tous les avantages',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    SizedBox(height: 24),
                  ] else ...[
                    Text(
                      'Passez Premium',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    SizedBox(height: 8),
                    Text(
                      'Débloquez toutes les fonctionnalités exclusives',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    SizedBox(height: 24),
                  ],

                  if (!isPremium) ...[
                    Text(
                      'Choisissez votre plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildPricingCard(
                      context,
                      'Mensuel',
                      '25',
                      'DT/mois',
                      'Facturation mensuelle',
                      false,
                      () => _handlePremiumSubscription(context, true),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                    SizedBox(height: 12),
                    _buildPricingCard(
                      context,
                      'Annuel',
                      '250',
                      'DT/an',
                      'Économisez 50 DT',
                      true,
                      () => _handlePremiumSubscription(context, false),
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
                    SizedBox(height: 32),
                  ],

                  Text(
                    'Fonctionnalités incluses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  ..._features.asMap().entries.map((entry) {
                    int index = entry.key;
                    PremiumFeature feature = entry.value;
                    return _buildFeatureItem(feature)
                        .animate()
                        .fadeIn(delay: (400 + index * 50).ms)
                        .slideX(begin: -0.1, end: 0);
                  }).toList(),

                  SizedBox(height: 32),

                  Text(
                    'Ce que disent nos membres',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTestimonial(
                    'Ahmed K.',
                    'Le diagnostic intelligent m\'a fait économiser beaucoup d\'argent !',
                    5,
                  ).animate().fadeIn(delay: 600.ms),
                  SizedBox(height: 12),
                  _buildTestimonial(
                    'Sarah M.',
                    'Service premium exceptionnel, je recommande vivement.',
                    5,
                  ).animate().fadeIn(delay: 700.ms),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isPremium
          ? null
          : Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Essayer Premium',
                onPressed: () => _showSubscriptionDialog(context),
                icon: Icons.star,
                backgroundColor: AppColors.accent,
              ),
            ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    String title,
    String price,
    String period,
    String subtitle,
    bool isPopular,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isPopular ? AppColors.accent : Colors.grey.shade300,
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isPopular ? AppColors.accent.withOpacity(0.05) : Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isPopular)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'POPULAIRE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(width: 4),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isPopular ? AppColors.accent : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(PremiumFeature feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: AppColors.accent),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildTestimonial(String name, String text, int rating) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(
                          rating,
                          (index) => Icon(Icons.star, size: 16, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '"$text"',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Choisir un plan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Mensuel - 25 DT'),
              subtitle: Text('Facturation mensuelle'),
              onTap: () {
                Navigator.pop(context);
                _handlePremiumSubscription(context, true);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Annuel - 250 DT'),
              subtitle: Text('Économisez 50 DT'),
              trailing: Chip(
                label: Text('POPULAIRE', style: TextStyle(fontSize: 10)),
                backgroundColor: AppColors.accent,
              ),
              onTap: () {
                Navigator.pop(context);
                _handlePremiumSubscription(context, false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePremiumSubscription(BuildContext context, bool isMonthly) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userProfile = authProvider.userProfile;

    if (user == null || userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez vous connecter'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Process payment directly without loading dialog
      final amount = isMonthly ? 25.0 : 250.0;
      final description = isMonthly ? 'Premium Monthly' : 'Premium Annual';
      
      print('Starting payment: $amount USD');
      
      bool success = await payment_service.PaymentService.processPayment(
        context: context,
        amount: amount,
        description: description, currency: '',
      );

      if (success) {
        print(' Payment successful, updating profile...');
        
        // Update user premium status in Firestore
        DateTime endDate = isMonthly
            ? DateTime.now().add(Duration(days: 30))
            : DateTime.now().add(Duration(days: 365));

        await _firebaseService.updateUserProfile(user.uid, {
          'isPremium': true,
          'premiumEndDate': endDate,
        });

        // Reload user profile
        await authProvider.updateProfile({});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenue Premium!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        print('Payment cancelled or failed');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de paiement'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class PremiumFeature {
  final IconData icon;
  final String title;
  final String description;

  PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}