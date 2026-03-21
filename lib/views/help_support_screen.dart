import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'frovy.app@gmail.com';
  static const String _supportPhone = '+94712262866';

  // ── URL helpers ──────────────────────────────────────

  Future<void> _launchEmail(BuildContext context,
      {String? subject, String? body}) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not open email app. Please email us at $_supportEmail'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.frovyRed,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final Uri uri = Uri(scheme: 'tel', path: _supportPhone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not open dialler. Please call $_supportPhone'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.frovyRed,
          ),
        );
      }
    }
  }

  // ── Coming-soon dialog ───────────────────────────────

  void _showComingSoon(BuildContext context, String featureName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.frovyGreen, Color(0xFF8FC47F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.frovyText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$featureName is on its way! We\'re working hard to bring you this feature very soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.frovyGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Got it!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── User Guide modal ─────────────────────────────────

  void _showUserGuide(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle + header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.frovyGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book_rounded,
                              color: AppColors.frovyGreen, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fro-vy User Guide',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.white : AppColors.frovyText,
                              ),
                            ),
                            Text(
                              'Everything you need to get started',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.withValues(alpha: 0.15)),
                  ],
                ),
              ),

              // Scrollable guide content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    _guideSection(
                      isDark: isDark,
                      step: '01',
                      icon: Icons.qr_code_scanner_rounded,
                      iconColor: AppColors.frovyGreen,
                      title: 'Scanning a Product',
                      steps: [
                        'Tap the Scan button on the Home screen.',
                        'Point your camera at the ingredients label on any food product.',
                        'Keep the label inside the green focus frame and hold steady.',
                        'Tap Take Photo — Fro-vy will read the text automatically.',
                        'Alternatively, tap the gallery icon to upload a photo from your phone.',
                      ],
                      tip:
                          'Make sure the label is well-lit and in focus for the best results.',
                    ),
                    _guideSection(
                      isDark: isDark,
                      step: '02',
                      icon: Icons.edit_note_rounded,
                      iconColor: Colors.indigo,
                      title: 'Manual Ingredient Entry',
                      steps: [
                        'On the Scan screen, scroll down and tap "Try Manual Entry".',
                        'Type or paste the ingredient list from the product.',
                        'Separate each ingredient with a comma (e.g. Sugar, Milk, Salt).',
                        'Tap Analyze to get your results.',
                      ],
                      tip:
                          'Manual entry is great when the label is too small or damaged to scan.',
                    ),
                    _guideSection(
                      isDark: isDark,
                      step: '03',
                      icon: Icons.analytics_outlined,
                      iconColor: Colors.teal,
                      title: 'Understanding Your Results',
                      steps: [
                        'Results are grouped into three categories:',
                        'Beneficial — ingredients that are generally good for you.',
                        'Caution — ingredients you should be mindful of.',
                        'Avoid — ingredients flagged against your health profile (allergies or medical conditions).',
                        'Tap any category card to expand and see the full ingredient list.',
                      ],
                      tip:
                          'Results are personalised based on the allergies and conditions set in your profile.',
                    ),
                    _guideSection(
                      isDark: isDark,
                      step: '04',
                      icon: Icons.manage_search_rounded,
                      iconColor: Colors.orange,
                      title: 'Searching Products',
                      steps: [
                        'Tap the Search icon on the Home screen.',
                        'Type a product name to find it in the database.',
                        'Filter by category using the chips at the top (Dairy, Snacks, etc.).',
                        'Tap a product card to see its full ingredient breakdown.',
                      ],
                      tip:
                          'Suggest a missing product via the Send Feedback button in Help & Support.',
                    ),
                    _guideSection(
                      isDark: isDark,
                      step: '05',
                      icon: Icons.history_rounded,
                      iconColor: Colors.purple,
                      title: 'Your Scan History',
                      steps: [
                        'All past scans are saved automatically in History.',
                        'Tap any card to view the full analysis again.',
                        'Tap the delete icon on a card to remove that entry.',
                        'Tap "Clear All History" to remove everything at once.',
                      ],
                      tip:
                          'History is stored locally on your device — it won\'t sync between phones.',
                    ),
                    _guideSection(
                      isDark: isDark,
                      step: '06',
                      icon: Icons.favorite_border_rounded,
                      iconColor: AppColors.frovyRed,
                      title: 'Managing Your Health Profile',
                      steps: [
                        'Go to Profile → Edit Profile → Health Profile tab.',
                        'Select your known food allergies from the chip list.',
                        'Add any medical conditions in the text field below.',
                        'Tap Save — your profile updates instantly.',
                        'All future scans will reflect your updated health profile.',
                      ],
                      tip:
                          'Keeping your profile accurate gives you the most relevant ingredient warnings.',
                    ),
                    _guideSection(
                      isDark: isDark,
                      step: '07',
                      icon: Icons.workspace_premium_rounded,
                      iconColor: AppColors.frovyGold,
                      title: 'Subscription Plans',
                      steps: [
                        'Free — 10 scans per month with basic analysis.',
                        'Pro — unlimited scans, barcode & OCR scanning, detailed insights.',
                        'Premium — everything in Pro plus AI recommendations and dietitian consultations.',
                        'To upgrade, go to Profile → Subscription.',
                      ],
                      tip: 'You can downgrade back to Free at any time.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guideSection({
    required bool isDark,
    required String step,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> steps,
    required String tip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkBackground
              : const Color(0xFFF8FAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.frovyText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Steps list
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: steps.asMap().entries.map((entry) {
                  final isIntro =
                      entry.key == 0 && entry.value.endsWith(':');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isIntro) ...[
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ] else
                          const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: isIntro
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tip box
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 15, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white60 : Colors.grey[600],
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
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

  // ── Feedback bottom sheet ────────────────────────────

  void _showFeedbackForm(BuildContext context, bool isDark) {
    final TextEditingController feedbackController = TextEditingController();
    int selectedRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                24, 24, 24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.frovyGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.feedback_outlined,
                            color: AppColors.frovyGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "feedback_form_title".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.frovyText,
                            ),
                          ),
                          Text(
                            'Sent directly to our team',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Star rating
                  Text("feedback_rating_label".tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setModalState(
                            () => selectedRating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            index < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: AppColors.frovyGold,
                            size: 34,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Message field
                  TextField(
                    controller: feedbackController,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.frovyText,
                    ),
                    decoration: InputDecoration(
                      hintText: "feedback_hint".tr(),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit → opens email client
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final feedbackText = feedbackController.text.trim();
                        final rating = selectedRating;
                        Navigator.pop(context);

                        final String subject =
                            'Fro-vy App Feedback${rating > 0 ? ' (${'⭐' * rating})' : ''}';
                        final String body =
                            '${rating > 0 ? 'Rating: ${'★' * rating}${'☆' * (5 - rating)}\n\n' : ''}'
                            '${feedbackText.isNotEmpty ? feedbackText : '(No message provided)'}';

                        await _launchEmail(context,
                            subject: subject, body: body);
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text("feedback_submit".tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.frovyGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Opens your email app to $_supportEmail',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
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

  // ── Main build ───────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.frovyGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: Colors.white, size: 28),
          ),
        ),
        title: Text(
          "help_support".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF2F7F2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    // ── Contact us ──────────────────
                    _buildSectionHeader("contact_us".tr(), isDark),
                    const SizedBox(height: 10),
                    _buildCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          // Live chat → coming soon
                          _buildTappableRow(
                            icon: Icons.chat_bubble_outline_rounded,
                            iconColor: AppColors.frovyGreen,
                            title: "live_chat".tr(),
                            subtitle: "available_time".tr(),
                            isDark: isDark,
                            onTap: () =>
                                _showComingSoon(context, 'Live Chat'),
                            trailingIcon: Icons.access_time_rounded,
                            trailingColor: Colors.grey[400]!,
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.1),
                              indent: 52),
                          // Email support → open email client
                          _buildTappableRow(
                            icon: Icons.email_outlined,
                            iconColor: Colors.blue,
                            title: "email_support".tr(),
                            subtitle: _supportEmail,
                            isDark: isDark,
                            onTap: () => _launchEmail(context,
                                subject: 'Fro-vy Support Request'),
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.1),
                              indent: 52),
                          // Phone support → open dialler
                          _buildTappableRow(
                            icon: Icons.phone_outlined,
                            iconColor: Colors.orange,
                            title: "phone_support".tr(),
                            subtitle: _supportPhone,
                            isDark: isDark,
                            onTap: () => _launchPhone(context),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Quick help ──────────────────
                    _buildSectionHeader("quick_help".tr(), isDark),
                    const SizedBox(height: 10),
                    _buildCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          // User guide → in-app modal
                          _buildTappableRow(
                            icon: Icons.menu_book_outlined,
                            iconColor: Colors.indigo,
                            title: "user_guide".tr(),
                            subtitle:
                                'Step-by-step guide to using Fro-vy',
                            isDark: isDark,
                            onTap: () => _showUserGuide(context),
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.withValues(alpha: 0.1),
                              indent: 52),
                          // Video tutorials → coming soon
                          _buildTappableRow(
                            icon: Icons.play_circle_outline_rounded,
                            iconColor: Colors.red,
                            title: "video_tutorials".tr(),
                            subtitle: 'Watch how to use the app',
                            isDark: isDark,
                            onTap: () => _showComingSoon(
                                context, 'Video Tutorials'),
                            trailingIcon: Icons.access_time_rounded,
                            trailingColor: Colors.grey[400]!,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── FAQ ─────────────────────────
                    _buildSectionHeader("faq_title".tr(), isDark),
                    const SizedBox(height: 10),
                    _buildCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          _buildFAQTile(
                            'How does ingredient scanning work?',
                            'Fro-vy uses your phone\'s camera and on-device OCR (text recognition) to read the ingredient label. '
                                'The extracted text is then sent to our server which analyses each ingredient against your health profile.',
                            context,
                            isDark,
                          ),
                          _buildFAQTile(
                            'How do I set up my allergies and medical conditions?',
                            'Go to Profile → Edit Profile → Health Profile tab. '
                                'Select your allergies from the chip list and add any medical conditions in the text box, then tap Save.',
                            context,
                            isDark,
                          ),
                          _buildFAQTile(
                            'Why is an ingredient showing as "Caution" for me?',
                            'Caution ingredients are personalised to your health profile. '
                                'An ingredient may be generally fine but could conflict with a condition or sensitivity you have listed.',
                            context,
                            isDark,
                          ),
                          _buildFAQTile(
                            'Is my personal data stored on the cloud?',
                            'Your scan history and profile are stored locally on your device. '
                                'Ingredient analysis requests are processed on our server but your personal health data is never stored there.',
                            context,
                            isDark,
                          ),
                          _buildFAQTile(
                            'What is the difference between Pro and Premium?',
                            'Pro gives you unlimited scans plus barcode and OCR scanning with detailed insights. '
                                'Premium includes everything in Pro plus AI-powered recommendations and access to dietitian consultations.',
                            context,
                            isDark,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Feedback ────────────────────
                    _buildCard(
                      isDark: isDark,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: AppColors.frovyGreen
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.feedback_outlined,
                                      color: AppColors.frovyGreen, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "have_feedback".tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.frovyText,
                                        ),
                                      ),
                                      Text(
                                        'We read every message — really!',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showFeedbackForm(context, isDark),
                                icon: const Icon(Icons.send_rounded, size: 16),
                                label: Text("send_feedback".tr()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.frovyGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ───────────────────────────────────

  Widget _buildSectionHeader(String title, bool isDark) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppColors.frovyText,
          ),
        ),
      );

  Widget _buildCard({required bool isDark, required Widget child}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: child,
      );

  Widget _buildTappableRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.chevron_right_rounded,
    Color? trailingColor,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: isLast ? 4 : 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.frovyText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(trailingIcon,
                color: trailingColor ?? Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(
    String question,
    String answer,
    BuildContext context,
    bool isDark, {
    bool isLast = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : AppColors.frovyText,
          ),
        ),
        iconColor: AppColors.frovyGreen,
        textColor: AppColors.frovyGreen,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              answer,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}