import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/ocr_service.dart';
import 'result_screen.dart';
import 'widgets/language_switcher.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();

  // Fro-vy colors
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyBeige = Color(0xFFEEE8D6);
  static const Color frovyText = Color(0xFF2C3E28);

  @override
  void initState() {
    super.initState();

    if (widget.cameras.isNotEmpty) {
      controller = CameraController(widget.cameras[0], ResolutionPreset.high);

      controller.initialize().then((_) {
        if (!mounted) return;

        setState(() {
          _isCameraInitialized = true;
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Process image (Camera + Gallery)
  Future<void> _processImage(String imagePath) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('processing_image'.tr())),
    );

    try {
      OCRService ocrService = OCRService();

      String? result = await ocrService.uploadImage(File(imagePath));

      if (result != null) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(analysisResult: result),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('upload_failed'.tr())),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _processImage(image.path);
    }
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized) return;

    final XFile image = await controller.takePicture();

    await _processImage(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: Text(
          'scan_ingredients'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: const [
          LanguageSwitcher(),
        ],
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              // Camera Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    // Camera preview
                    Container(
                      height: 300,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),

                      clipBehavior: Clip.hardEdge,

                      child: _isCameraInitialized
                          ? Stack(
                              fit: StackFit.expand,
                              children: [

                                CameraPreview(controller),

                                Center(
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.8),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            )

                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'camera_preview'.tr(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Take photo button
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,

                        icon: const Icon(Icons.camera_alt),

                        label: Text(
                          'take_photo'.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: frovyGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Upload gallery button
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,

                        icon: Icon(
                          Icons.file_upload_outlined,
                          color: frovyGreen,
                        ),

                        label: Text(
                          'upload_from_gallery'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: frovyGreen,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: frovyGreen.withOpacity(0.5),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------- HOW TO SCAN ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: frovyBeige,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      'how_to_scan'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: frovyText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildBulletPoint('scan_instruction_1'.tr()),
                    _buildBulletPoint('scan_instruction_2'.tr()),
                    _buildBulletPoint('scan_instruction_3'.tr()),
                    _buildBulletPoint('scan_instruction_4'.tr()),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Footer
              Text(
                'cant_scan_label'.tr(),
                style: TextStyle(color: Colors.grey[600]),
              ),

              TextButton(
                onPressed: () {},

                child: Text(
                  'try_manual_entry'.tr(),
                  style: TextStyle(
                    color: frovyGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bullet point helper
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: frovyGreen),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: frovyText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}