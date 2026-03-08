import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'reviews_screen.dart';
import 'how_to_use_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'utils/user_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final decoded = jsonDecode(userStr);
        if (decoded is Map && mounted) {
          setState(() {
            _userName = UserUtils.formatUserName(decoded['name']?.toString());
            _userEmail = UserUtils.formatEmail(decoded['email']?.toString());
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data in Profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B1B25), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1B1B25),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFF0F4FF),
                      child: const Icon(Icons.person, size: 40, color: Color(0xFF4A6CF7)),
                    ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B1B25),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userEmail,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: const Color(0xFF717171),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Menu Items
            const SizedBox(height: 8),
            _buildSectionHeader("HELP & FEEDBACK"),
            _buildMenuItem(
              icon: Icons.star_outline_rounded,
              title: "Reviews & Ratings",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReviewsScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: "How to Use the App",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HowToUseScreen()),
                );
              },
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader("LEGAL & PRIVACY"),
            _buildMenuItem(
              icon: Icons.lock_outline_rounded,
              title: "Privacy Policy",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                );
              },
            ),
            
            const SizedBox(height: 80),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (_) => const LoginScreen()),
                         (route) => false,
                       );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F1),
                    foregroundColor: const Color(0xFFFF4B4B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF9E9E9E),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1B1B25), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1B1B25),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD), size: 20),
    );
  }
}
