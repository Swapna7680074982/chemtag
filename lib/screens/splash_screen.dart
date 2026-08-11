import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/dcr_provider.dart';
import '../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    final startTime = DateTime.now();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if auto login/token restore works
    final isAuthenticated = await authProvider.tryAutoLogin();
    
    // Ensure the splash screen stays visible for at least 2 seconds for a premium UX
    final elapsedTime = DateTime.now().difference(startTime);
    final remainingTime = const Duration(seconds: 2) - elapsedTime;
    if (remainingTime > Duration.zero) {
      await Future.delayed(remainingTime);
    }

    if (mounted) {
      if (isAuthenticated) {
        // Load initial user specific DCR data if authenticated
        if (authProvider.currentUser != null) {
          final dcrProvider = Provider.of<DcrProvider>(context, listen: false);
          dcrProvider.loadMappedChemists(authProvider.currentUser!.employeeId);
          dcrProvider.fetchDcrHistory();
        }
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          // Logo with smooth scale and fade animations
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
