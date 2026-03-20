// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Brand Colors
  static const Color frovyGreen          = Color(0xFF6AA15E);
  static const Color frovyYellowGradient = Color(0xFFFFF9C4);

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: frovyGreen,
      appBar: AppBar(
        backgroundColor: frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [frovyGreen, frovyYellowGradient],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Contact Us'),
              const SizedBox(height: 12),
              _buildContactCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Quick Help'),
              const SizedBox(height: 12),
              _buildQuickHelpCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Frequently Asked Questions'),
              const SizedBox(height: 12),
              _buildFAQCard(context),
              const SizedBox(height: 24),
              _buildFeedbackCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Section Widgets
  // ─────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return _buildCard(
      child: Column(
        children: [
          _buildContactTile(
            Icons.chat_bubble_outline,
            'Live Chat',
            'Available 9am - 6pm EST',
          ),
          const Divider(height: 30),
          _buildContactTile(
            Icons.email_outlined,
            'Email Support',
            'support@fro-vy.com',
          ),
          const Divider(height: 30),
          _buildContactTile(
            Icons.phone_outlined,
            'Phone Support',
            '1-800-FRO-VY-HELP',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpCard() {
    return _buildCard(
      child: Column(
        children: [
          _buildNavTile(Icons.menu_book_outlined, 'User Guide'),
          const Divider(height: 24),
          _buildNavTile(Icons.play_circle_outline, 'Video Tutorials'),
        ],
      ),
    );
  }

  Widget _buildFAQCard(BuildContext context) {
    return _buildCard(
      child: Column(
        children: [
          _buildFAQTile(
            context,
            question: 'How accurate is the ingredient analysis?',
            answer:
                'Our analysis uses a comprehensive database of ingredients and their potential health impacts. However, always consult a medical professional.',
          ),
          _buildFAQTile(
            context,
            question: 'Can I scan products in any language?',
            answer:
                'Currently, Fro-vy supports ingredient labels in English. We are working on adding support for Sinhala and Tamil in upcoming updates.',
          ),
          _buildFAQTile(
            context,
            question: 'How do I update my health profile?',
            answer:
                'You can update your allergies and medical conditions anytime from your Account Details page.',
          ),
          _buildFAQTile(
            context,
            question: 'Is my health data private?',
            answer:
                'Absolutely. Your health information is encrypted and never shared with third parties. You can request data deletion at any time.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have Feedback?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "We'd love to hear your thoughts on how we can improve Fro-vy!",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (null),
              style: ElevatedButton.styleFrom(
                backgroundColor: frovyGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Feedback',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Shared Card Wrapper
  // ─────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────
  // Helper Widgets
  // ─────────────────────────────────────────

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: frovyGreen.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile(IconData icon, String title) {
    return InkWell(
      onTap: null, 
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  // Fixed: uses Theme.of(context).copyWith() instead of ThemeData().copyWith()
  Widget _buildFAQTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        iconColor: frovyGreen,
        textColor: frovyGreen,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}