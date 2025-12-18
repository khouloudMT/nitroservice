import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Réparation à Domicile',
      description: 'Des mécaniciens professionnels viennent directement chez vous',
      icon: Icons.home_repair_service,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Réservation Facile',
      description: 'Prenez rendez-vous en quelques clics via notre application',
      icon: Icons.phone_android,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'Suivi en Temps Réel',
      description: 'Suivez l\'arrivée de votre mécanicien sur la carte',
      icon: Icons.location_on,
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: Text('Passer'),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Indicateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Bouton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                text: _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
    }
    Widget _buildPage(OnboardingPage page) {
    return Padding(
    padding: EdgeInsets.all(40),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
    color: page.color.withOpacity(0.1),
    shape: BoxShape.circle,
    ),
    child: Icon(
    page.icon,
    size: 100,
    color: page.color,
    ),
    ),
          SizedBox(height: 50),
          
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 20),
          
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    }
    Widget _buildDot(int index) {
    return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    margin: EdgeInsets.symmetric(horizontal: 5),
    width: _currentPage == index ? 24 : 8,
    height: 8,
    decoration: BoxDecoration(
    color: _currentPage == index ? AppColors.primary : Colors.grey[300],
    borderRadius: BorderRadius.circular(4),
    ),
    );
    }
    }
    class OnboardingPage {
    final String title;
    final String description;
    final IconData icon;
    final Color color;
    OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    });
    }