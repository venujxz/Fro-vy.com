import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import '../util/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Brand Colors
  static const Color frovyGreen = AppColors.frovyGreen;
  static const Color frovyYellowGradient = AppColors.frovyYellowGradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? null : frovyGreen,
      appBar: AppBar(
        backgroundColor: isDark ? null : frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "help_support".tr(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark
            ? null
            : const BoxDecoration(
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
              // 1. Contact Us Section
              Text("contact_us".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
              Text("quick_help".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
              Text("faq_title".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFAQTile("faq_q1".tr(), "faq_a1".tr(), context),
                    _buildFAQTile("faq_q2".tr(), "faq_a2".tr(), context),
                    _buildFAQTile("faq_q3".tr(), "faq_a3".tr(), context),
                    _buildFAQTile("faq_q4".tr(), "faq_a4".tr(), context),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Feedback Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                          _showFeedbackForm(context);
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

    // --- Feedback Form Logic ---

    void _showFeedbackForm(BuildContext context) {
      final TextEditingController feedbackController = TextEditingController();
      int selectedRating = 0;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  24, 24, 24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "feedback_form_title".tr(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "feedback_form_subtitle".tr(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // Star Rating
                    Text("feedback_rating_label".tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              index < selectedRating ? Icons.star : Icons.star_border,
                              color: frovyGreen,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Text Field
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "feedback_hint".tr(),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (feedbackController.text.trim().isEmpty && selectedRating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("feedback_empty_error".tr())),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("feedback_thank_you".tr())),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: frovyGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("feedback_submit".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    // --- Helper Widgets ---

    Widget _buildContactTile(IconData icon, String title, String subtitle) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: frovyGreen.withValues(alpha: 0.8), // Slightly darker circle bg
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

    Widget _buildFAQTile(String question, String answer, BuildContext context) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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