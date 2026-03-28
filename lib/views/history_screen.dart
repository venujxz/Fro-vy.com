import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../util/app_colors.dart';
import '../services/history_service.dart';
import 'output/output_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _items = [];
  bool _isLoading = true;
  String? _error;

  // ── Stat counters ─────────────────────────────────────────────────────────
  int get _totalScans => _items.length;
  int get _productSearchCount =>
      _items.where((i) => i.analysisType == 'product_search').length;
  int get _manualEntryCount =>
      _items.where((i) => i.analysisType != 'product_search').length;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ── Fetch from Firestore subcollection ────────────────────────────────────
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
        return;
      }
      final items = await HistoryService.fetchItems(uid);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load history. Check your connection.';
        _isLoading = false;
      });
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> _deleteItem(int index) async {
    final item = _items[index];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _items.removeAt(index));
    await HistoryService.deleteItem(uid, item.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("item_deleted".tr()),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Clear all ─────────────────────────────────────────────────────────────
  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("clear_history_q".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("clear_history_desc".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("cancel".tr(),
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              setState(() => _items = []);
              await HistoryService.clearAll(uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frovyRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("clear_all".tr()),
          ),
        ],
      ),
    );
  }

  // ── Navigate to OutputScreen using cached data (no new API call) ──────────
  void _replayItem(HistoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutputScreen(
          // Pass the ingredient list so OutputScreen can display the count
          ingredients: item.ingredients,
          isProductSearch: item.analysisType == 'product_search',
          productName:
              item.productName.isEmpty ? null : item.productName,
          brandName: item.brandName.isEmpty ? null : item.brandName,
          analysisType: item.analysisType,
          // Cached data — skips all network calls and rebuilds instantly
          cachedCheckResult: item.checkResult,
          cachedAiWarnings: item.aiWarnings,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgTop =
        isDark ? AppColors.darkBackground : AppColors.frovyGreen;
    final bgBody = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F7F2);

    return Scaffold(
      backgroundColor: bgTop,
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
          "analysis_history".tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (_items.isNotEmpty)
            GestureDetector(
              onTap: _clearAllHistory,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_sweep_outlined,
                    color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(
              children: [
                _statPill(
                    '$_totalScans', 'Total', Icons.history_rounded, isDark),
                const SizedBox(width: 10),
                _statPill('$_productSearchCount', 'Products',
                    Icons.search_rounded, isDark),
                const SizedBox(width: 10),
                _statPill('$_manualEntryCount', 'Manual',
                    Icons.edit_note_rounded, isDark),
              ],
            ),
          ),

          // ── Scrollable list ──────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgBody,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: _buildBody(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.frovyGreen));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!,
                style:
                    TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh_rounded),
              label: Text("try_again".tr()),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.frovyGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.frovyGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: _items.length,
        itemBuilder: (_, i) => _buildHistoryCard(_items[i], i, isDark),
      ),
    );
  }

  // ── History card — conditional layout per spec ────────────────────────────
  Widget _buildHistoryCard(HistoryItem item, int index, bool isDark) {
    final isProductSearch = item.analysisType == 'product_search';
    final typeColor = isProductSearch
        ? const Color(0xFF5C6BC0) // indigo for product search
        : AppColors.frovyGreen;   // green for manual/scan

    final typeIcon = isProductSearch
        ? Icons.search_rounded
        : item.analysisType == 'product_scan'
            ? Icons.qr_code_scanner_rounded
            : Icons.edit_note_rounded;

    return GestureDetector(
      onTap: () => _replayItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: type icon + type label (large) + delete ──────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── LARGE PROMINENT TYPE LABEL ──────────────────
                        Text(
                          item.typeLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.frovyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // ── DATE & TIME ─────────────────────────────────
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12,
                                color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedDateTime,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _deleteItem(index),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.frovyRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.frovyRed, size: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(
                  height: 1, color: Colors.grey.withValues(alpha: 0.15)),
              const SizedBox(height: 12),

              // ── Row 2: product name OR ingredient preview ────────────
              if (isProductSearch) ...[
                // Product Search: show product name prominently
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.productName.isNotEmpty
                            ? item.productName
                            : 'Unknown Product',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : AppColors.frovyText,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.brandName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        item.brandName,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF5C6BC0)),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Manual Entry / Product Scan: show truncated ingredient preview
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.science_outlined,
                        size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.ingredientPreview.isNotEmpty
                            ? item.ingredientPreview
                            : '${item.ingredients.length} ingredient(s)',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // ── Footer: ingredient count badge + tap hint ────────────
              Row(
                children: [
                  // Ingredient count
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.ingredients.length} ingredient'
                      '${item.ingredients.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          fontSize: 11,
                          color: typeColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (item.aiWarnings != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 11, color: Color(0xFF5C6BC0)),
                          SizedBox(width: 3),
                          Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5C6BC0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        "tap_to_view_analysis".tr(),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat pill ─────────────────────────────────────────────────────────────
  Widget _statPill(
      String value, String label, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.frovyGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off_rounded,
                size: 56,
                color: AppColors.frovyGreen.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            "no_scan_history".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.frovyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "scan_to_see_here".tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}