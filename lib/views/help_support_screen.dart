import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Brand Colors
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyYellowGradient = Color(0xFFFFF9C4);

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
          "Help & Support",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [frovyGreen, frovyYellowGradient], // Green to Yellow gradient
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Contact Us Section
              const Text("Contact Us", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildContactTile(Icons.chat_bubble_outline, "Live Chat", "Available 9am - 6pm EST"),
                    const Divider(height: 30),
                    _buildContactTile(Icons.email_outlined, "Email Support", "support@fro-vy.com"),
                    const Divider(height: 30),
                    _buildContactTile(Icons.phone_outlined, "Phone Support", "1-800-FRO-VY-HELP"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Quick Help Section
              const Text("Quick Help", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildNavTile(Icons.menu_book_outlined, "User Guide"),
                    const Divider(height: 24),
                    _buildNavTile(Icons.play_circle_outline, "Video Tutorials"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. FAQ Section (Interactive)
              const Text("Frequently Asked Questions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFAQTile("How accurate is the ingredient analysis?", 
                        "Our analysis uses a comprehensive database of ingredients and their potential health impacts. However, always consult a medical professional."),
                    _buildFAQTile("Can I scan products in any language?", 
                        "Currently, Fro-vy supports ingredient labels in English. We are working on adding support for Sinhala and Tamil in upcoming updates."),
                    _buildFAQTile("How do I update my health profile?", 
                        "You can update your allergies and medical conditions anytime from your Account Details page."),
                    _buildFAQTile("Is my health data private?", 
                        "Absolutely. Your health information is encrypted and never shared with third parties. You can request data deletion at any time."),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Feedback Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Have Feedback?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        onPressed: () {
                          // TODO: Open Feedback Form
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: frovyGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Send Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
            ),
          ),
        ),
      );
    }

    // --- Helper Widgets ---

    Widget _buildContactTile(IconData icon, String title, String subtitle) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: frovyGreen.withOpacity(0.8), // Slightly darker circle bg
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      );
    }

    Widget _buildNavTile(IconData icon, String title) {
      return InkWell(
        onTap: () {},
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      );
    }

    Widget _buildFAQTile(String question, String answer) {
      return Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          iconColor: frovyGreen,
          textColor: frovyGreen,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }
}