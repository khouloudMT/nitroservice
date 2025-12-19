import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/booking_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/service_card.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load services
      if (serviceProvider.services.isEmpty) {
        await serviceProvider.loadServices();
      }
      
      // Load user bookings
      if (authProvider.user != null) {
        bookingProvider.getUserBookings(authProvider.user!.uid);
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Notifications
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildQuickCategories(),
              _buildPopularServices(),
              _buildRecentBookings(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.map);
        },
        icon: const Icon(Icons.location_on),
        label: const Text('Trouver mécanicien'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Get user name, ensuring we have the profile loaded
        final userName = authProvider.userProfile?.name ?? 
                        authProvider.user?.displayName ?? 
                        'Utilisateur';
        final isPremium = authProvider.userProfile?.isPremium ?? false;
        final profilePictureBase64 = authProvider.userProfile?.profilePictureBase64;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: profilePictureBase64 != null && profilePictureBase64.isNotEmpty
                    ? MemoryImage(base64Decode(profilePictureBase64))
                    : null,
                child: profilePictureBase64 == null || profilePictureBase64.isEmpty
                    ? Icon(Icons.person, size: 35, color: AppColors.primary)
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenue,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isPremium) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0);
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un service...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          Provider.of<ServiceProvider>(context, listen: false).searchServices(value);
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pushNamed(context, AppRoutes.services);
          }
        },
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildQuickCategories() {
    final categories = [
      {'name': 'Vidange', 'icon': Icons.oil_barrel, 'color': Colors.blue},
      {'name': 'Freins', 'icon': Icons.circle, 'color': Colors.red},
      {'name': 'Batterie', 'icon': Icons.battery_charging_full, 'color': Colors.green},
      {'name': 'Pneus', 'icon': Icons.album, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Catégories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    Provider.of<ServiceProvider>(context, listen: false)
                        .filterByCategory(category['name'] as String);
                    Navigator.pushNamed(context, AppRoutes.services);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildPopularServices() {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        if (serviceProvider.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: LoadingWidget(message: 'Chargement des services...'),
          );
        }

        if (serviceProvider.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Text(
                    serviceProvider.errorMessage ?? 'Erreur',
                    style: TextStyle(color: AppColors.error),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => serviceProvider.loadServices(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final popularServices = serviceProvider.popularServices;

        if (popularServices.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services populaires',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.services);
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: popularServices.take(3).length,
              itemBuilder: (context, index) {
                final service = popularServices[index];
                return ServiceCard(
                  service: service,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.serviceDetail,
                      arguments: service,
                    );
                  },
                );
              },
            ),
          ],
        ).animate().fadeIn(delay: 300.ms);
      },
    );
  }

  Widget _buildRecentBookings() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final recentBookings = bookingProvider.bookings.take(2).toList();

        if (recentBookings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Réservations récentes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // Switch to booking history tab
                      final homeState = context.findAncestorStateOfType<State>();
                      // This would work if HomeScreen exposes a method to change tabs
                      Navigator.pushNamed(context, '/booking-history');
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentBookings.length,
              itemBuilder: (context, index) {
                final booking = recentBookings[index];
                return BookingCard(
                  booking: booking,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.bookingDetail,
                      arguments: booking,
                    );
                  },
                  onCancel: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Annuler la réservation'),
                        content: const Text('Voulez-vous vraiment annuler cette réservation ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Non'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Oui', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      bool success = await bookingProvider.cancelBooking(booking.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Réservation annulée'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ],
        ).animate().fadeIn(delay: 400.ms);
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.userProfile?.name ?? 'Utilisateur';
        final userEmail = authProvider.user?.email ?? '';
        final profilePictureBase64 = authProvider.userProfile?.profilePictureBase64;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: profilePictureBase64 != null && profilePictureBase64.isNotEmpty
                          ? MemoryImage(base64Decode(profilePictureBase64))
                          : null,
                      child: profilePictureBase64 == null || profilePictureBase64.isEmpty
                          ? Icon(Icons.person, size: 35, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Accueil'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Premium'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.premium);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Aide & Support'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text('Déconnexion', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Déconnexion', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await authProvider.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}