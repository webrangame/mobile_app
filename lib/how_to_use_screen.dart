import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/custom_widgets.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

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
          "How to Use",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1B1B25),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep(
              number: "1",
              title: "Search for Products",
              description: "Use the search bar on the dashboard to find products across Coles and Woolworths. You can also ask our AI assistant anything!",
              icon: Icons.search_rounded,
            ),
            const SizedBox(height: 16),
            _buildStep(
              number: "2",
              title: "Compare Prices",
              description: "View the latest prices and deals from different supermarkets to find the best value for your money.",
              icon: Icons.compare_arrows_rounded,
            ),
            const SizedBox(height: 16),
            _buildStep(
              number: "3",
              title: "Explore Catalogues",
              description: "Click on shop cards to view specific store deals and featured items directly in the chat.",
              icon: Icons.menu_book_rounded,
            ),
            const SizedBox(height: 16),
            _buildStep(
              number: "4",
              title: "Chat with AI",
              description: "Our AI assistant can help you compare products, find specific items, and give you shopping tips.",
              icon: Icons.chat_bubble_outline_rounded,
            ),
            const SizedBox(height: 32),
            PremiumCard(
              color: const Color(0xFFF8FAFF),
              child: Column(
                children: [
                  const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF4A6CF7), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    "Pro Tip",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1B25),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ask for 'best deals on ice cream' or 'cheapest milk this week' to see the power of our AI search!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: const Color(0xFF717171),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4A6CF7), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STEP $number",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A6CF7),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B1B25),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF717171),
                    height: 1.5,
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
