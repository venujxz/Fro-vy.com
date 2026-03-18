import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/history_service.dart';
import 'result_screen.dart';

class _StatusStyle {
  final String label;
  final Color pill;
  final Color pillText;
  final Color cardTint;
  final Color cardBorder;
  final IconData icon;

  const _StatusStyle({
    required this.label,
    required this.pill,
    required this.pillText,
    required this.cardTint,
    required this.cardBorder,
    required this.icon,
  });
}

const Map<String, _StatusStyle> _kStatus = {
  'SAFE': _StatusStyle(
    label: 'Safe',
    pill: Color(0xFF2D7A45),
    pillText: Colors.white,
    cardTint: Color(0xFFF0FAF3),
    cardBorder: Color(0xFFB7E5C5),
    icon: Icons.verified_rounded,
  ),
  'CAUTION': _StatusStyle(
    label: 'Caution',
    pill: Color(0xFFCA8A04),
    pillText: Colors.white,
    cardTint: Color(0xFFFFFBEB),
    cardBorder: Color(0xFFFDE68A),
    icon: Icons.info_outline_rounded,
  ),
  'UNSAFE': _StatusStyle(
    label: 'Avoid',
    pill: Color(0xFFDC2626),
    pillText: Colors.white,
    cardTint: Color(0xFFFFF1F1),
    cardBorder: Color(0xFFFECACA),
    icon: Icons.block_rounded,
  ),
};

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  static const Color _bgTop = Color(0xFF5B9E49);
  static const Color _bgBottom = Color(0xFFD4C94A);
  static const Color _surface = Colors.white;
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);

  final HistoryService _historyService = HistoryService();
  late final AnimationController _headerCtrl;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  void _deleteItem(String scanId, String productName) {
    HapticFeedback.lightImpact();
    _historyService.deleteScan(scanId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$productName removed"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  void _clearAllHistory() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: _surface,
        title: const Text(
          "Clear history?",
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 19, color: _textDark),
        ),
        content: const Text(
          "This will permanently remove your ingredient analysis history.",
          style: TextStyle(color: _textMuted, height: 1.5),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: const Text("Cancel",
                style: TextStyle(
                    color: _textDark, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              _historyService.clearAllHistory();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Clear All",
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _navigateToResult(Map<String, dynamic> item) {
    final resultData = {
      "productName": item['productName'],
      "status": item['status'],
      "ingredients": item['ingredients'],
      "warnings": item['warnings'],
    };
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
    ResultScreen(analysisResult: jsonEncode(resultData)),
transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
  child: child,
),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgTop,
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_bgTop, Color(0xFF8EC56E), _bgBottom],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -60,
              child: _Blob(
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: 120,
              left: -40,
              child: _Blob(
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.06)),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _historyService.streamHistory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Could not load history.\nPlease try again.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.8)),
                            ),
                          );
                        }
                        final items = snapshot.data ?? [];
                        if (items.isEmpty) return _buildEmptyState();

                        final totalScans = items.length;
                        final safeCount = items
                            .where((i) => i['status'] == 'SAFE')
                            .length;
                        final attentionCount = items
                            .where((i) => i['status'] != 'SAFE')
                            .length;

                        return _buildList(
                          items: items,
                          totalScans: totalScans,
                          safeCount: safeCount,
                          attentionCount: attentionCount,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return FadeTransition(
      opacity: _headerCtrl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            _GlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.maybePop(context),
            ),
            const Spacer(),
            const Text(
              "Analysis History",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 19,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required List<Map<String, dynamic>> items,
    required int totalScans,
    required int safeCount,
    required int attentionCount,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        FadeTransition(
          opacity: _headerCtrl,
          child: _buildSummaryCard(
            totalScans: totalScans,
            safeCount: safeCount,
            attentionCount: attentionCount,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Text(
              "Recent Scans",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$totalScans",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < items.length; i++) ...[
          _buildHistoryCard(items[i]),
          if (i < items.length - 1) const SizedBox(height: 14),
        ],
        const SizedBox(height: 22),
        _ClearAllButton(onTap: _clearAllHistory),
      ],
    );
  }

  Widget _buildSummaryCard({
    required int totalScans,
    required int safeCount,
    required int attentionCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: Color(0xFF2D7A45), size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Overview",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textDark)),
                  Text("Ingredient check summary",
                      style:
                          TextStyle(fontSize: 12, color: _textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                _SummaryTile(
                    value: totalScans,
                    label: "Total Scans",
                    color: _textDark,
                    icon: Icons.qr_code_scanner_rounded),
                _VerticalDivider(),
                _SummaryTile(
                    value: safeCount,
                    label: "Safe",
                    color: const Color(0xFF2D7A45),
                    icon: Icons.verified_rounded),
                _VerticalDivider(),
                _SummaryTile(
                    value: attentionCount,
                    label: "Needs Review",
                    color: const Color(0xFFDC2626),
                    icon: Icons.flag_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final String statusKey = item['status'] as String;
    final _StatusStyle style = _kStatus[statusKey] ?? _kStatus['CAUTION']!;
    final List ingredients = item['ingredients'] ?? [];
    final String scanId = item['id'] ?? '';
    final String productName = item['productName'] ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _navigateToResult(item),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: style.cardBorder, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: style.pill.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: style.cardTint,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: style.cardBorder, width: 1.5),
                      ),
                      child:
                          Icon(style.icon, color: style.pill, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(productName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                  height: 1.2)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 13, color: _textMuted),
                              const SizedBox(width: 4),
                              Text(item['date'] ?? '',
                                  style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(style: style),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: style.cardTint,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: style.cardBorder, width: 1),
                  ),
                  child: Text(
                    _getStatusMessage(item),
                    style: TextStyle(
                        color: style.pill,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                  ),
                ),
              ),
              if (ingredients.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (int i = 0;
                          i < math.min(3, ingredients.length);
                          i++)
                        _Chip(label: ingredients[i] as String),
                      if (ingredients.length > 3)
                        _Chip(
                            label: "+${ingredients.length - 3} more",
                            faded: true),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 10, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded,
                        size: 14, color: _textMuted),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text("Tap to view full analysis",
                          style: TextStyle(
                              color: _textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500)),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _deleteItem(scanId, productName),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626), size: 18),
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: const Icon(Icons.history_rounded,
                  size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text("No history yet",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              "Your scanned ingredient analyses will appear here once you start using Fro-vy.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(Map<String, dynamic> item) {
    final String status = item['status'] as String;
    final List warnings = item['warnings'] ?? [];
    final List ingredients = item['ingredients'] ?? [];
    switch (status) {
      case 'SAFE':
        return "✓ All ${ingredients.length} ingredients reviewed — looks great!";
      case 'UNSAFE':
        return "⚠ ${warnings.length} flagged issue${warnings.length == 1 ? '' : 's'} — best to avoid this product.";
      default:
        return "ℹ ${warnings.length} ingredient${warnings.length == 1 ? '' : 's'} need your attention.";
    }
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final _StatusStyle style;
  const _StatusPill({required this.style});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: style.pill,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
              color: style.pill.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.pillText, size: 15),
          const SizedBox(width: 5),
          Text(style.label,
              style: TextStyle(
                  color: style.pillText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final IconData icon;
  const _SummaryTile(
      {required this.value,
      required this.label,
      required this.color,
      required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text("$value",
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        color: const Color(0xFFE5E7EB));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool faded;
  const _Chip({required this.label, this.faded = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: faded ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: faded
                ? const Color(0xFFE5E7EB)
                : const Color(0xFFE9EBF0),
            width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              color: faded
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF374151),
              fontSize: 11.5,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.35), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ClearAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearAllButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_sweep_rounded,
                color: Color(0xFFDC2626), size: 20),
            SizedBox(width: 8),
            Text("Clear All History",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}