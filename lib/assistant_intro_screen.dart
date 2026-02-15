import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class AssistantIntroScreen extends StatefulWidget {
  const AssistantIntroScreen({super.key});

  @override
  State<AssistantIntroScreen> createState() => _AssistantIntroScreenState();
}

class _AssistantIntroScreenState extends State<AssistantIntroScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _navigateToChat(BuildContext context) {
    if (_searchController.text.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(initialQuery: _searchController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/profile_avatar.png'),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.black87),
                        Positioned(
                          right: 0,
                          top: 0,
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
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hello, Jake!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF717171),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "I’m “Deal Mate”, I help you instantly\nfind the best deals around you.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B25),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Easily compare prices & deals across our\nsupported stores.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717171),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Supermarket Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        _buildStoreCard(
                          name: "Coles",
                          subtitle: "Super Offers",
                          color: const Color(0xFFDE2B20),
                          logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Coles_logo.svg/1024px-Coles_logo.svg.png",
                        ),
                        _buildStoreCard(
                          name: "Woolworths",
                          subtitle: "Fresh Deals",
                          color: const Color(0xFF007A33),
                          logo: "https://upload.wikimedia.org/wikipedia/en/thumb/3/30/Woolworths_Logo.svg/1200px-Woolworths_Logo.svg.png",
                        ),
                        _buildStoreCard(
                          name: "Aldi",
                          subtitle: "Special Buys",
                          color: const Color(0xFF002366),
                          logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/ALDI_logo.svg/1200px-ALDI_logo.svg.png",
                        ),
                        _buildStoreCard(
                          name: "IGA",
                          subtitle: "Local Low Prices",
                          color: const Color(0xFFC4122E),
                          logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/IGA_logo.svg/1200px-IGA_logo.svg.png",
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
            
            // Bottom Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF8FAFF).withAlpha(0),
                    const Color(0xFFF8FAFF),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _navigateToChat(context),
                        decoration: const InputDecoration(
                          hintText: "Ask me anything...",
                          hintStyle: TextStyle(color: Color(0xFFAFAFAF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToChat(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D58E1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard({
    required String name,
    required String subtitle,
    required Color color,
    required String logo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(logo, width: 32, height: 32, errorBuilder: (_, __, ___) => Icon(Icons.store, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF717171), fontSize: 12),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "View Catalogue",
                  style: TextStyle(color: Color(0xFF2D58E1), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 14, color: Color(0xFF2D58E1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
