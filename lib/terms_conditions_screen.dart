import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          "Terms & Conditions",
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
            Text(
              "Last Updated: February 14, 2026",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              "1. Acceptance of Terms",
              "By accessing or using the Price Comparison AI application, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the service.",
            ),
            _buildSection(
              "2. Use of Service",
              "Our application is a price comparison and information tool. You agree to use the service only for lawful purposes and in a way that does not infringe the rights of others.",
            ),
            _buildSection(
              "3. Accuracy of Information",
              "While we strive to provide accurate and up-to-date pricing information from various supermarkets, we cannot guarantee the complete accuracy, completeness, or reliability of any content. Prices provided should be treated as estimates and may vary by location.",
            ),
            _buildSection(
              "4. User Accounts",
              "You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.",
            ),
            _buildSection(
              "5. Intellectual Property",
              "All content, logos, and trademarks displayed in the app are the property of their respective owners. You may not use, reproduce, or distribute any content without permission.",
            ),
            _buildSection(
              "6. Limitation of Liability",
              "Price Comparison AI and its affiliates shall not be liable for any indirect, incidental, special, or consequential damages resulting from the use or inability to use the service.",
            ),
            _buildSection(
              "7. Changes to Terms",
              "We reserve the right to modify these terms at any time. Your continued use of the application after changes constitute acceptance of the new terms.",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B1B25),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
