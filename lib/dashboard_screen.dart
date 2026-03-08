import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'store_items_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'widgets/custom_widgets.dart';
import 'widgets/voice_search_overlay.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<dynamic> _chatHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _apiService.fetchChatHistory();
      if (mounted) {
        setState(() {
          // Sort by date descending (newest first)
          history.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['last_message_at'] ?? a['created_at'] ?? a['updated_at'] ?? '') ?? DateTime(1970);
            DateTime dateB = DateTime.tryParse(b['last_message_at'] ?? b['created_at'] ?? b['updated_at'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });
          _chatHistory = history.take(5).toList(); // Only show top 5 on dashboard
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
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
                      backgroundColor: const Color(0xFFF0F4FF),
                      child: const Icon(Icons.person, color: Color(0xFF4A6CF7)),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.logout_rounded, color: isDark ? Colors.white70 : Colors.redAccent.withOpacity(0.8), size: 20),
                          onPressed: _handleLogout,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                      color: const Color(0xFF4A6CF7).withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
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
                          suffixIcon: IconButton(
                            icon: Icon(Icons.mic_rounded, color: const Color(0xFF4A6CF7).withOpacity(0.8)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (context) => VoiceSearchOverlay(
                                  onResult: (text) {
                                    setState(() {
                                      _searchController.text = text;
                                    });
                                    _navigateToSearch();
                                  },
                                ),
                              );
                            },
                          ),
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
                        padding: const EdgeInsets.all(12),
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
              
              // Store Cards Row
              Row(
                children: [
                   Expanded(
                    child: _buildStoreCard(
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
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStoreCard(
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
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Chats Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Chats',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A6CF7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : _chatHistory.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text(
                              'No recent chats',
                              style: GoogleFonts.outfit(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _chatHistory.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _chatHistory[index];
                            return _buildChatHistoryCard(
                              title: item['title'] ?? 'Untitled Chat',
                              date: _formatDate(item['last_message_at'] ?? item['created_at']),
                              sessionId: item['session_id'],
                              isDark: isDark,
                            );
                          },
                        ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Recently';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final itemDate = DateTime(date.year, date.month, date.day);
      final diffInDays = today.difference(itemDate).inDays;
      
      if (diffInDays == 0) {
        return 'Today';
      } else if (diffInDays == 1) {
        return 'Yesterday';
      } else if (diffInDays < 7) {
        return '$diffInDays days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildChatHistoryCard({
    required String title,
    required String date,
    required String sessionId,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(initialSessionId: sessionId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF4A6CF7),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1B1B25),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(String name, String subtext, String logoAsset, Color accentColor, VoidCallback onTap) {
    return PremiumCard(
      height: 320,
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
                color: accentColor.withOpacity(0.06),
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
                    color: accentColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withOpacity(0.1),
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
