import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../services/ocr_service.dart';
import '../util/platform_config.dart';
import '../services/prefs_service.dart';
import 'result_screen.dart';
import 'manual_entry_screen.dart';
import '../util/app_colors.dart';
import '../util/page_transitions.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  List<String> _userAllergies = [];
  String _userMedicalConditions = "";

  static const Color frovyGreen = AppColors.frovyGreen;

  @override
  void initState() {
    super.initState();
    _loadHealthProfile();
    if (widget.cameras.isNotEmpty) {
      controller = CameraController(widget.cameras[0], ResolutionPreset.high);
      controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isCameraInitialized = true);
      }).catchError((e) => debugPrint('Camera init error: $e'));
    }
  }

  Future<void> _loadHealthProfile() async {
    final healthProfile = await PrefsService.getHealthProfile();
    if (!mounted) return;
    setState(() {
      _userAllergies = healthProfile.allergies;
      _userMedicalConditions = healthProfile.medicalConditions;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _processImage(String imagePath) async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      final OCRService ocrService = OCRService();
      final String? extractedIngredients =
          await ocrService.processImageForText(File(imagePath));
      ocrService.dispose();

      if (extractedIngredients != null && extractedIngredients.isNotEmpty) {
        final url = Uri.parse(PlatformConfig.getBackendUrl());
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'extractedText': extractedIngredients,
            'allergies': _userAllergies,
            'medicalConditions': _userMedicalConditions,
          }),
        ).timeout(PlatformConfig.getHttpTimeout());

        if (!mounted) return;
        if (response.statusCode == 200) {
          Navigator.push(
            context,
            PageTransitions.fade(ResultScreen(analysisResult: response.body)),
          );
        } else {
          _showError("server_error".tr(namedArgs: {'code': response.statusCode.toString()}));
        }
      } else {
        _showError("ocr_failed".tr());
      }
    } catch (e) {
      _showError('upload_failed'.tr());
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.frovyRed,
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _processImage(image.path);
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || controller == null) return;
    final XFile image = await controller!.takePicture();
    await _processImage(image.path);
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
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
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
          // ── Camera preview card ─────────────────────
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
                      child: _isCameraInitialized && controller != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(controller!),
                                // Focus frame
                                Center(
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Corner accents
                                        _corner(Alignment.topLeft),
                                        _corner(Alignment.topRight),
                                        _corner(Alignment.bottomLeft),
                                        _corner(Alignment.bottomRight),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_isProcessing)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF5F5F5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      size: 40,
                                      color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text("camera_preview".tr(),
                                      style: TextStyle(color: Colors.grey[400])),
                                ],
                              ),
                            ),
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
                            onPressed: _isProcessing ? null : _takePhoto,
                            icon: const Icon(Icons.camera_alt_rounded, size: 18),
                            label: Text("take_photo".tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: frovyGreen,
                              foregroundColor: Colors.white,
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
                          onPressed: _isProcessing ? null : _pickFromGallery,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: frovyGreen.withValues(alpha: 0.6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Icon(Icons.photo_library_outlined,
                              color: frovyGreen, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom sheet-style tip + manual entry ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F7F2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                                  color: AppColors.frovyGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.lightbulb_outline_rounded,
                                    color: frovyGreen, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "how_to_scan".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : AppColors.frovyText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildTipRow("scan_instruction_1".tr(), isDark),
                          _buildTipRow("scan_instruction_2".tr(), isDark),
                          _buildTipRow("scan_instruction_3".tr(), isDark),
                          _buildTipRow("scan_instruction_4".tr(), isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Manual entry card
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.slideRight(const ManualEntryScreen()),
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
                                color: AppColors.frovyGreen.withValues(alpha: 0.12),
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
                                      color: isDark ? Colors.white : AppColors.frovyText,
                                    ),
                                  ),
                                  Text(
                                    "cant_scan_label".tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
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

  Widget _corner(Alignment alignment) {
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    return Align(
      alignment: alignment,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: frovyGreen, width: 3) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: frovyGreen, width: 3) : BorderSide.none,
            left: isLeft ? const BorderSide(color: frovyGreen, width: 3) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: frovyGreen, width: 3) : BorderSide.none,
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
              color: frovyGreen,
              shape: BoxShape.circle,
            ),
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