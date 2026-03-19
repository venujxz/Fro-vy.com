import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/ingredient_checker_service.dart';
import '../../services/gemini_service.dart';
import '../../models/ingredient_model.dart';

class OutputScreen extends StatefulWidget {
  final List<String> ingredients;
  final bool isProductSearch;
  final String? productName;
  final String? brandName;
  final Map<String, dynamic>? testUserData;

  const OutputScreen({
    super.key,
    required this.ingredients,
    required this.isProductSearch,
    this.productName,
    this.brandName,
    this.testUserData,
  });

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  // ── State variables ────────────────────────────────────────────────────────
  CheckResult? _result;
  bool _loading = true;
  String? _loadError;

  bool _aiLoading = false;
  List<String>? _aiWarnings;

  int? _touchedIndex; // which pie slice is currently tapped

  Map<String, dynamic>? _userData; // user profile from Firestore

  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color _beneficialColor = Color(0xFF4CAF50);
  static const Color _cautionColor = Color(0xFFFFC107);
  static const Color _avoidColor = Color(0xFFF44336);
  static const Color _unknownColor = Color(0xFF9E9E9E);
  static const Color _aiColor = Color(0xFF5C6BC0);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── STEP A: Load ingredient DB from Firestore, run the check ──────────────
  Future<void> _loadData() async {
    try {
      final db = FirestoreService();

      // 1. Fetch all ingredients from Firestore (with error handling)
      Map<String, IngredientModel> ingredientDb = {};
      try {
        ingredientDb = await db.getAllIngredients();
      } catch (firebaseError) {
        debugPrint('Firebase getAllIngredients error: $firebaseError');
        // If Firestore fails, continue with empty DB
        // Unknown ingredients will be marked as such
        ingredientDb = {};
      }

      // 2. Run the checker
      final result = IngredientCheckerService().checkIngredients(
        widget.ingredients,
        ingredientDb,
      );

      // 3. Load user profile (use test data if provided, else from Firestore)
      if (widget.testUserData != null) {
        _userData = widget.testUserData;
      } else {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final user = await db.getUser(uid);
          _userData = user?.toMap();

          // 4. Save to search history (only if real user)
          try {
            await db.addToSearchHistory(uid, {
              'productName': widget.productName ?? 'Manual / Scan Entry',
              'brandName': widget.brandName ?? '',
              'ingredients': widget.ingredients,
              'timestamp': DateTime.now().toIso8601String(),
              'beneficialCount': result.beneficial.length,
              'cautionCount': result.caution.length,
              'avoidCount': result.avoid.length,
              'unknownCount': result.unknown.length,
            });
          } catch (_) {
            // History save failing should not crash the screen
          }
        }
      }

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load ingredient data: $e';
        _loading = false;
      });
    }
  }

  // ── STEP B: Call Gemini and get personalised warnings ─────────────────────
  Future<void> _loadAiWarnings() async {
    setState(() => _aiLoading = true);

    // Build user context — use empty/defaults if user not logged in (test mode)
    final warnings = await GeminiService().getPersonalisedWarnings(
      userName: _userData?['name'] ?? 'User',
      gender: _userData?['gender'] ?? 'Unknown',
      dob: _userData?['dob'] ?? '2000-01-01',
      conditions: List<String>.from(_userData?['conditions'] ?? []),
      foodAllergies: List<String>.from(_userData?['foodAllergies'] ?? []),
      avoidIngredients: _result!.avoid.map((e) => e.name).toList(),
      cautionIngredients: _result!.caution.map((e) => e.name).toList(),
      allIngredients: widget.ingredients,
    );

    setState(() {
      _aiWarnings = warnings;
      _aiLoading = false;
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F9F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: _beneficialColor),
              const SizedBox(height: 20),
              Text(
                'Analysing ${widget.ingredients.length} ingredients...',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _loadData();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final r = _result!;

    // Build pie sections — only include categories that have > 0 ingredients
    final pieSections = <_PieSlice>[
      if (r.beneficial.isNotEmpty)
        _PieSlice('Beneficial', r.beneficial.length, _beneficialColor),
      if (r.caution.isNotEmpty)
        _PieSlice('Caution', r.caution.length, _cautionColor),
      if (r.avoid.isNotEmpty) _PieSlice('Avoid', r.avoid.length, _avoidColor),
      if (r.unknown.isNotEmpty)
        _PieSlice('Unknown', r.unknown.length, _unknownColor),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        title: const Text(
          'Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6AA15E),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────────────────────────────────────────
            // SECTION 1: Product card (only when coming from product search)
            // ─────────────────────────────────────────────────────────────────
            if (widget.isProductSearch) ...[
              _buildProductCard(),
              const SizedBox(height: 20),
            ],

            // ─────────────────────────────────────────────────────────────────
            // SECTION 2: Pie chart
            // ─────────────────────────────────────────────────────────────────
            const Text(
              'Ingredient Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${r.total} ingredients found',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildPieChartCard(pieSections, r),

            const SizedBox(height: 24),

            // ─────────────────────────────────────────────────────────────────
            // SECTION 3: Ingredient table (expandable dropdowns)
            // ─────────────────────────────────────────────────────────────────
            const Text(
              'Ingredient Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCategoryDropdown(
              emoji: '',
              label: 'Beneficial | Supports health & wellbeing.',
              items: r.beneficial,
              color: _beneficialColor,
            ),
            _buildCategoryDropdown(
              emoji: '',
              label:
                  'Caution | Generally safe, but frequent or large doses may be harmful.',
              items: r.caution,
              color: _cautionColor,
            ),
            _buildCategoryDropdown(
              emoji: '',
              label: 'Avoid | Strongly linked to negative health effects.',
              items: r.avoid,
              color: _avoidColor,
            ),
            if (r.unknown.isNotEmpty) _buildUnknownDropdown(r.unknown),

            const SizedBox(height: 28),

            // ─────────────────────────────────────────────────────────────────
            // SECTION 4: AI personalised results button + cards
            // ─────────────────────────────────────────────────────────────────
            if (_aiWarnings == null) _buildAiButton(),

            if (_aiWarnings != null) ...[
              _buildAiResultsHeader(),
              const SizedBox(height: 12),
              ..._aiWarnings!.map((w) => _buildAiWarningCard(w)),
            ],
          ],
        ),
      ),
    );
  }

  // ── WIDGET BUILDERS ───────────────────────────────────────────────────────

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _aiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: _aiColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.brandName ?? '',
                  style: const TextStyle(color: _aiColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(List<_PieSlice> sections, CheckResult r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── The chart itself ──
          SizedBox(
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = null;
                            return;
                          }
                          final index = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                          // Fix for index out of range crash (common on Web hover)
                          if (index < 0 || index >= sections.length) {
                            _touchedIndex = null;
                          } else {
                            _touchedIndex = index;
                          }
                        });
                      },
                    ),
                    sections: sections.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      final isTouched = _touchedIndex == i;
                      final pct = (s.count / r.total * 100).round();

                      return PieChartSectionData(
                        value: s.count.toDouble(),
                        color: s.color,
                        radius: isTouched ? 80 : 60,
                        title: '$pct%',
                        titleStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTouched ? 14 : 12,
                        ),
                        badgeWidget: isTouched
                            ? _PieBadge(s.label, s.color)
                            : null,
                        badgePositionPercentageOffset: 1.3,
                      );
                    }).toList(),
                    centerSpaceRadius: 55,
                    sectionsSpace: 3,
                  ),
                ),
                // Centre label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${r.total}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'total',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tapped slice detail card ──
          if (_touchedIndex != null &&
              _touchedIndex! >= 0 &&
              _touchedIndex! < sections.length) ...[
            const SizedBox(height: 8),
            _buildTappedSliceDetail(sections[_touchedIndex!], r),
          ],

          const SizedBox(height: 16),

          // ── Legend ──
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: sections.map((s) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${s.label} (${s.count})',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Shows a small numbered list when a pie slice is tapped
  Widget _buildTappedSliceDetail(_PieSlice slice, CheckResult r) {
    List<String> names = [];
    if (slice.label == 'Beneficial') {
      names = r.beneficial.map((e) => e.name).toList();
    } else if (slice.label == 'Caution') {
      names = r.caution.map((e) => e.name).toList();
    } else if (slice.label == 'Avoid') {
      names = r.avoid.map((e) => e.name).toList();
    } else {
      names = r.unknown;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: slice.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: slice.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slice.label,
            style: TextStyle(
              color: slice.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...names
              .take(6)
              .toList()
              .asMap()
              .entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${e.key + 1}. ${e.value}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
          if (names.length > 6)
            Text(
              '+ ${names.length - 6} more — see details below',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    );
  }

  /// Expandable dropdown row for beneficial / caution / avoid
  Widget _buildCategoryDropdown({
    required String emoji,
    required String label,
    required List<IngredientModel> items,
    required Color color,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          title: Text(
            '$emoji  $label  (${items.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
          children: items
              .map((ing) => _buildIngredientRow(ing, color))
              .toList(),
        ),
      ),
    );
  }

  /// A single ingredient row inside the dropdown
  Widget _buildIngredientRow(IngredientModel ing, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ing.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ing.reason,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown for ingredients not in the database
  Widget _buildUnknownDropdown(List<String> unknowns) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: _unknownColor,
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            'Not in Database  (${unknowns.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _unknownColor,
              fontSize: 15,
            ),
          ),
          children: unknowns.map((name) {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.12)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: _unknownColor,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'This ingredient is not yet in our database — we\'re working on adding more.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAiButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _aiLoading ? null : _loadAiWarnings,
        icon: _aiLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          _aiLoading ? 'Generating...' : 'Get Personalised Results',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _aiColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: _aiColor.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildAiResultsHeader() {
    return Row(
      children: [
        const Text(
          'Personalised Analysis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _aiColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'AI',
            style: TextStyle(
              color: _aiColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiWarningCard(String warning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _aiColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _aiColor.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _aiColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 13, color: _aiColor),
                    SizedBox(width: 5),
                    Text(
                      'For You',
                      style: TextStyle(
                        color: _aiColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Warning text
          Text(warning, style: const TextStyle(fontSize: 14, height: 1.6)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          // AI disclaimer
          const Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: Colors.grey),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'This result is AI-generated and for informational purposes only. Always consult a qualified healthcare professional.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper classes ────────────────────────────────────────────────────────────

class _PieSlice {
  final String label;
  final int count;
  final Color color;
  _PieSlice(this.label, this.count, this.color);
}

/// Small floating badge that appears on the tapped pie slice
class _PieBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PieBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
