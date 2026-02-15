import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'store_items_screen.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'widgets/custom_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final decoded = jsonDecode(userStr);
        if (decoded is Map && mounted) {
          setState(() {
            _userName = decoded['name']?.toString() ?? 'User';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data in Dashboard: $e');
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _navigateToSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(initialQuery: query),
        ),
      );
      _searchController.clear();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: const AssetImage('assets/images/profile_avatar.png'),
                      onBackgroundImageError: (_, __) {},
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: [
                       IconButton(
                        icon: Icon(Icons.logout, color: isDark ? Colors.white : Colors.black),
                        onPressed: _handleLogout,
                      ),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Greeting
              Text(
                'Hello, $_userName!',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'What deal are you looking for today?',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1B1B25),
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Compare prices. Discover deals. Shop smarter all in one place',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: const Color(0xFF717171),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Floating Search Bar
              Container(
                height: 64,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _navigateToSearch(),
                        decoration: InputDecoration(
                          hintText: 'Search for milk, eggs, or deals...',
                          hintStyle: GoogleFonts.outfit(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF1B1B25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _navigateToSearch(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A6CF7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Featured Shops Section
              Text(
                'Featured Shops',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              
              // Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
                children: [
                  _buildStoreCard(
                    'Coles',
                    'Super Offers',
                    'assets/images/coles_logo.png',
                    const Color(0xFFE01A22),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StoreItemsScreen(shopName: 'Coles'),
                        ),
                      );
                    },
                  ),
                  _buildStoreCard(
                    'Woolworths',
                    'Fresh Deals',
                    'assets/images/woolworths_logo.png',
                    const Color(0xFF008A00),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StoreItemsScreen(shopName: 'Woolworths'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStoreCard(String name, String subtext, String logoAsset, Color accentColor, VoidCallback onTap) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Hero(
                tag: 'logo_$name',
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.store_rounded, color: accentColor, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF1B1B25),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF717171),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Catalogue',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: accentColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
