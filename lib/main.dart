import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/navigation_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dcr_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'widgets/gradient_button.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChemTagApp());
}

class ChemTagApp extends StatelessWidget {
  const ChemTagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DcrProvider()),
      ],
      child: SessionGate(
        child: MaterialApp(
          title: 'ChemTag',
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class SessionGate extends StatefulWidget {
  final Widget child;
  const SessionGate({required this.child, super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _isSessionExpiredHandlingActive = false;

  @override
  void initState() {
    super.initState();
    ApiService().onSessionExpired = _handleSessionExpired;
  }

  void _handleSessionExpired() {
    if (_isSessionExpiredHandlingActive) return;
    _isSessionExpiredHandlingActive = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dcrProvider = Provider.of<DcrProvider>(context, listen: false);

      final wasAuthenticated = authProvider.isAuthenticated;

      // Reset application authentication and local cache state
      await authProvider.logout();
      dcrProvider.clearAllData();

      final navContext = NavigationService.navigatorKey.currentContext;
      if (wasAuthenticated && navContext != null && navContext.mounted) {
        showDialog(
          context: navContext,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.danger,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Session Expired',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your session has expired. Please log in again to continue.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
            actions: [
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _isSessionExpiredHandlingActive = false;
                    NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('LOG IN AGAIN'),
                ),
              ),
            ],
          ),
        );
      } else {
        _isSessionExpiredHandlingActive = false;
        NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
