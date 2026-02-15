import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          "Privacy Policy",
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
              "1. Introduction",
              "At Niyogen Market, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.",
            ),
            _buildSection(
              "2. Information We Collect",
              "We collect minimal information required to provide our services:\n\n• Account Information: Name and email address when you create an account.\n• Usage Data: Information about how you interact with our app, such as search queries and viewed products.\n• Device Information: Basic device details to ensure app stability and performance.",
            ),
            _buildSection(
              "3. How We Use Your Information",
              "We use the collected data to:\n\n• Provide and maintain our service.\n• Personalize your experience and product recommendations.\n• Analyze usage patterns to improve app functionality.\n• Communicate with you regarding account updates or support.",
            ),
            _buildSection(
              "4. Data Security",
              "The security of your data is important to us. We implement industry-standard security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.",
            ),
            _buildSection(
              "5. Third-Party Services",
              "Our app may display content from third-party supermarkets (like Coles and Woolworths). We do not share your personal data with these third parties.",
            ),
            _buildSection(
              "6. Contact Us",
              "If you have any questions about this Privacy Policy, please contact us at support@niyogen.com.",
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
