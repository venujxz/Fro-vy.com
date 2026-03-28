import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';
import 'manual_entry_screen.dart';
import 'output/output_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  /// Multi-step processing state — drives the UI label
  _ScanStep _step = _ScanStep.idle;

  final ImagePicker _picker = ImagePicker();
  static const Color frovyGreen = AppColors.frovyGreen;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;
    try {
      _controller =
          CameraController(widget.cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
      // Camera failing to init is non-fatal — gallery picker still works
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ── Image capture entry points ────────────────────────────────────────────

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _controller == null) {
      _showError('Camera is not ready. Please try the gallery instead.');
      return;
    }
    if (_step != _ScanStep.idle) return;
    try {
      final XFile image = await _controller!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      _showError('Could not capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_step != _ScanStep.idle) return;
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _processImage(image.path);
  }

  // ── Core OCR pipeline ─────────────────────────────────────────────────────
  //
  // Step 1 — OCR: ML Kit extracts raw text from the label image
  // Step 2 — Parse: raw text is cleaned and split into an ingredient list
  // Step 3 — Navigate: hand the list to OutputScreen (same path as manual entry)
  //
  // OutputScreen handles:
  //   • Running IngredientCheckerService against the Firestore DB
  //   • Saving the result to users/{uid}/history with analysisType='product_scan'
  //   • Showing the Gemini AI button
  //
  Future<void> _processImage(String imagePath) async {
    if (!mounted) return;

    // ── Step 1: OCR ───────────────────────────────────────────────────────
    setState(() => _step = _ScanStep.extractingText);

    String rawText = '';
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final recognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final RecognizedText recognized =
            await recognizer.processImage(inputImage);
        rawText = recognized.text;
      } finally {
        // Always close — even if processImage threw
        await recognizer.close();
      }
    } catch (e) {
      debugPrint('ML Kit OCR error: $e');
      if (mounted) setState(() => _step = _ScanStep.idle);
      _showError('ocr_failed'.tr());
      return;
    }

    if (rawText.trim().isEmpty) {
      if (mounted) setState(() => _step = _ScanStep.idle);
      _showError('ocr_failed'.tr());
      return;
    }

    // ── Step 2: Parse raw OCR text → ingredient list ──────────────────────
    setState(() => _step = _ScanStep.parsingIngredients);

    final List<String> ingredients = _parseIngredients(rawText);

    if (ingredients.isEmpty) {
      if (mounted) setState(() => _step = _ScanStep.idle);
      _showError(
        'Could not detect an ingredient list in the image. '
        'Try Manual Entry for better results.',
      );
      return;
    }

    // ── Step 3: Navigate to OutputScreen ─────────────────────────────────
    // Reset state BEFORE pushing so the camera screen is clean when popped
    if (mounted) setState(() => _step = _ScanStep.idle);

    if (!mounted) return;
    Navigator.push(
      context,
      PageTransitions.fade(
        OutputScreen(
          ingredients: ingredients,
          isProductSearch: false,
          productName: null,
          brandName: null,
          analysisType: 'product_scan',
        ),
      ),
    );
  }

  // ── Ingredient parser ─────────────────────────────────────────────────────
  //
  // OCR returns a long block of text from the whole label. We need to isolate
  // the ingredient section and split it into individual items.
  //
  // Strategy:
  //   1. Find the "Ingredients:" section header (case-insensitive)
  //   2. If found, take everything after it until a likely section break
  //   3. Split on commas and semicolons, clean each token
  //   4. If no header is found, treat the whole text as a comma-separated list
  //
  static List<String> _parseIngredients(String rawText) {
    String working = rawText;

    // Try to find the ingredients section
    final headerRe = RegExp(
      r'ingredients?\s*[:\-]?\s*',
      caseSensitive: false,
    );
    final headerMatch = headerRe.firstMatch(working);

    if (headerMatch != null) {
      working = working.substring(headerMatch.end);
      // Trim at common section-ending keywords
      final stopRe = RegExp(
        r'\b(contains|may contain|allergen|nutrition|serving|calories|'
        r'storage|best before|manufactured|distributed|net weight|'
        r'per serving|amount per)\b',
        caseSensitive: false,
      );
      final stopMatch = stopRe.firstMatch(working);
      if (stopMatch != null) {
        working = working.substring(0, stopMatch.start);
      }
    }

    // Normalise whitespace introduced by OCR line breaks
    working = working.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    // Split on commas or semicolons
    final tokens = working.split(RegExp(r'[,;]'));

    final ingredients = tokens
        .map((t) {
          // Remove bracketed sub-ingredients markers like "(contains milk)"
          // and stray punctuation except letters, digits, spaces, hyphens
          String clean = t
              .replaceAll(RegExp(r'\([^)]*\)'), '')
              .replaceAll(RegExp(r"[^\w\s\-'.]"), ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          return clean;
        })
        .where((t) => t.length >= 2 && t.length <= 80)
        .toList();

    return ingredients;
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.frovyRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isProcessing = _step != _ScanStep.idle;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.frovyGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
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
          "scan_ingredients".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Camera preview card ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Preview window
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: _isCameraInitialized && _controller != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_controller!),
                                // Focus frame overlay
                                Center(
                                  child: Container(
                                    width: 220,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                        width: 2,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Stack(
                                      children: [
                                        _corner(Alignment.topLeft),
                                        _corner(Alignment.topRight),
                                        _corner(Alignment.bottomLeft),
                                        _corner(Alignment.bottomRight),
                                      ],
                                    ),
                                  ),
                                ),
                                // Processing overlay with step label
                                if (isProcessing)
                                  Container(
                                    color:
                                        Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            _stepLabel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : _buildCameraPlaceholder(isDark, isProcessing),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isProcessing ? null : _takePhoto,
                            icon: isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt_rounded,
                                    size: 18),
                            label: Text(
                              isProcessing
                                  ? _stepLabel
                                  : "take_photo".tr(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: frovyGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  frovyGreen.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: isProcessing ? null : _pickFromGallery,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: frovyGreen.withValues(alpha: 0.6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Icon(Icons.photo_library_outlined,
                              color: isProcessing
                                  ? Colors.grey
                                  : frovyGreen,
                              size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tips + manual entry ──────────────────────────────────────
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tips card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
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
                                  color: frovyGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: frovyGreen,
                                    size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "how_to_scan".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.frovyText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildTipRow("scan_instruction_1".tr(), isDark),
                          _buildTipRow("scan_instruction_2".tr(), isDark),
                          _buildTipRow("scan_instruction_3".tr(), isDark),
                          _buildTipRow("scan_instruction_4".tr(), isDark),
                          // Extra tip specific to ingredient scanning
                          _buildTipRow(
                              'Point the camera at the "Ingredients" section of the label for best results.',
                              isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Manual entry shortcut
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.slideRight(
                            const ManualEntryScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: frovyGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.edit_outlined,
                                  color: frovyGreen, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "try_manual_entry".tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.frovyText,
                                    ),
                                  ),
                                  Text(
                                    "cant_scan_label".tr(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step label for UI ─────────────────────────────────────────────────────

  String get _stepLabel {
    switch (_step) {
      case _ScanStep.extractingText:
        return 'Reading label text…';
      case _ScanStep.parsingIngredients:
        return 'Identifying ingredients…';
      case _ScanStep.idle:
        return '';
    }
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _buildCameraPlaceholder(bool isDark, bool isProcessing) {
    return Container(
      color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isProcessing) ...[
            const CircularProgressIndicator(color: frovyGreen),
            const SizedBox(height: 12),
            Text(_stepLabel,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ] else ...[
            Icon(Icons.camera_alt_outlined,
                size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text("camera_preview".tr(),
                style: TextStyle(color: Colors.grey[400])),
          ],
        ],
      ),
    );
  }

  Widget _corner(Alignment alignment) {
    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    return Align(
      alignment: alignment,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: frovyGreen, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: frovyGreen, width: 3)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: frovyGreen, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: frovyGreen, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: frovyGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white70 : AppColors.frovyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Processing step enum ───────────────────────────────────────────────────────

enum _ScanStep { idle, extractingText, parsingIngredients }