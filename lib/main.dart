import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'dashboard_screen.dart';
import 'services/auth_service.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  
  // Explicitly enable analytics data collection
  // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  // Log app open event for testing
  // await FirebaseAnalytics.instance.logAppOpen();
  
  runApp(const SupermarketRagApp());
}

class SupermarketRagApp extends StatelessWidget {
  const SupermarketRagApp({super.key});

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DealMate AI', // Updated Title
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      // navigatorObservers: [observer],
      home: const AuthWrapper(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    
    // Premium Color Palette
    final primaryColor = const Color(0xFF2D58E1); // Matching original seed color
    final secondaryColor = const Color(0xFF2962FF); // Deep Blue
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        surfaceContainerHighest: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).apply(
        bodyColor: isDark ? Colors.white : const Color(0xFF1D1D1F),
        displayColor: isDark ? Colors.white : const Color(0xFF1D1D1F),
      ),
      useMaterial3: true,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthService().isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
        });
      }
    } catch (e) {
      debugPrint('Login status check error: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false; // Fallback to Onboarding/Login on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isLoggedIn! ? const DashboardScreen() : const OnboardingScreen();
  }
}
