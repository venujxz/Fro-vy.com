import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()

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
        title: Text(
          "help_support".tr(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
              Text("contact_us".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    _buildContactTile(Icons.chat_bubble_outline, "live_chat".tr(), "available_time".tr()),
                    const Divider(height: 30),
                    _buildContactTile(Icons.email_outlined, "email_support".tr(), "support@fro-vy.com"), // Email stays hardcoded
                    const Divider(height: 30),
                    _buildContactTile(Icons.phone_outlined, "phone_support".tr(), "1-800-FRO-VY-HELP"), // Phone stays hardcoded
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Quick Help Section
              Text("quick_help".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    _buildNavTile(Icons.menu_book_outlined, "user_guide".tr()),
                    const Divider(height: 24),
                    _buildNavTile(Icons.play_circle_outline, "video_tutorials".tr()),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. FAQ Section (Interactive)
              Text("faq_title".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    _buildFAQTile("faq_q1".tr(), "faq_a1".tr()),
                    _buildFAQTile("faq_q2".tr(), "faq_a2".tr()),
                    _buildFAQTile("faq_q3".tr(), "faq_a3".tr()),
                    _buildFAQTile("faq_q4".tr(), "faq_a4".tr()),
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
                    Text("have_feedback".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      "feedback_subtitle".tr(),
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
                        child: Text("send_feedback".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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