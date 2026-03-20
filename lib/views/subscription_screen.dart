// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../util/app_colors.dart';
import '../services/prefs_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _currentPlan = "Free";

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final plan = await PrefsService.getCurrentPlan();
    if (!mounted) return;
    setState(() => _currentPlan = plan);
  }

  void _handleUpgrade(String planName, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.frovyGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: AppColors.frovyGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Text("coming_soon".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "coming_soon_desc".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.frovyGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$planName — $price/month',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.frovyGreen,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frovyGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("got_it".tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.frovyGreen,
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
          "premium_plans_title".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Hero text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              children: [
                Text(
                  "upgrade_health_journey".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "choose_perfect_plan".tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

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
                    _buildPlanCard(
                      context,
                      isDark: isDark,
                      title: "free".tr(),
                      price: "\$0",
                      period: "forever".tr(),
                      icon: Icons.star_outline_rounded,
                      iconColor: Colors.grey[500]!,
                      features: [
                        "10_scans_month".tr(),
                        "basic_analysis".tr(),
                        "manual_entry".tr(),
                      ],
                      isCurrent: _currentPlan == "Free",
                      buttonText: _currentPlan == "Free"
                          ? "current_plan".tr()
                          : "downgrade".tr(),
                      accentColor: Colors.grey[400]!,
                      onTap: () async {
                        setState(() => _currentPlan = "Free");
                        await PrefsService.setCurrentPlan("Free");
                      },
                    ),

                    const SizedBox(height: 16),

                    // PRO — featured
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildPlanCard(
                          context,
                          isDark: isDark,
                          title: "pro".tr(),
                          price: "\$2.99",
                          period: "per_month".tr(),
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.frovyGreen,
                          features: [
                            "unlimited_scans".tr(),
                            "barcode_ocr".tr(),
                            "detailed_insights".tr(),
                          ],
                          isCurrent: _currentPlan == "Pro",
                          buttonText: _currentPlan == "Pro"
                              ? "current_plan".tr()
                              : "upgrade_now".tr(),
                          accentColor: AppColors.frovyGreen,
                          onTap: () {
                            if (_currentPlan != "Pro")
                              _handleUpgrade("Pro", "\$2.99");
                          },
                          isFeatured: true,
                        ),
                        Positioned(
                          top: -10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7043),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "most_popular".tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildPlanCard(
                      context,
                      isDark: isDark,
                      title: "premium".tr(),
                      price: "\$6.99",
                      period: "per_month".tr(),
                      icon: Icons.workspace_premium_rounded,
                      iconColor: AppColors.frovyGold,
                      features: [
                        "everything_in_pro".tr(),
                        "ai_recommendations".tr(),
                        "dietitian_consult".tr(),
                      ],
                      isCurrent: _currentPlan == "Premium",
                      buttonText: _currentPlan == "Premium"
                          ? "current_plan".tr()
                          : "upgrade_now".tr(),
                      accentColor: AppColors.frovyGold,
                      onTap: () {
                        if (_currentPlan != "Premium")
                          _handleUpgrade("Premium", "\$6.99");
                      },
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

  Widget _buildPlanCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String price,
    required String period,
    required IconData icon,
    required Color iconColor,
    required List<String> features,
    required String buttonText,
    required VoidCallback onTap,
    required Color accentColor,
    required bool isCurrent,
    bool isFeatured = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent
            ? Border.all(color: accentColor, width: 2)
            : isFeatured
                ? Border.all(
                    color: AppColors.frovyGreen.withValues(alpha: 0.3), width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.frovyText,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
          const SizedBox(height: 14),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.frovyGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 12, color: AppColors.frovyGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey[200] : accentColor,
                foregroundColor:
                    isCurrent ? Colors.black54 : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}