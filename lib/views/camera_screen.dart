import 'dart:io';
import 'dart:convert'; // Required for jsonEncode
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:easy_localization/easy_localization.dart'; // IMPORT FOR .tr()
import 'package:http/http.dart' as http; // IMPORT FOR BACKEND REQUESTS
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
  final ImagePicker _picker = ImagePicker(); // For Gallery Uploads

  // User health data loaded from PrefsService
  List<String> _userAllergies = [];
  String _userMedicalConditions = "";

  // Define Fro-vy Brand Colors based on your design
  static const Color frovyGreen = AppColors.frovyGreen;
  static const Color frovyBeige = AppColors.frovyBeige;
  static const Color frovyText = AppColors.frovyText;

  @override
  void initState() {
    super.initState();
    _loadHealthProfile();
    // Initialize Camera
    if (widget.cameras.isNotEmpty) {
      controller = CameraController(widget.cameras[0], ResolutionPreset.high);
      controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }).catchError((e) {
        debugPrint('Camera initialization error: $e');
      });
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

  // --- LOGIC: Process the Image Locally & Send to Backend ---
  Future<void> _processImage(String imagePath) async {
    if (!mounted) return;
    
    // 1. Show Loading UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('processing_image'.tr())),
    );

    try {
      // 2. Extract Text using Google ML Kit LOCALLY on the phone
      OCRService ocrService = OCRService();
      String? extractedIngredients = await ocrService.processImageForText(File(imagePath));
      
      // Close the ML kit recognizer to free up memory
      ocrService.dispose();

      if (extractedIngredients != null && extractedIngredients.isNotEmpty) {
        
        // --- 3. SEND TEXT TO BACKEND API ---
        
        final url = Uri.parse(PlatformConfig.getBackendUrl());

        try {
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Uncomment when Auth is ready
            },
            body: jsonEncode({
              'extractedText': extractedIngredients,
              'allergies': _userAllergies,
              'medicalConditions': _userMedicalConditions,
            }),
          ).timeout(PlatformConfig.getHttpTimeout());

          if (response.statusCode == 200) {
            // Success! Pass the real JSON from the backend directly to the Result Screen
            if (!mounted) return;
            Navigator.push(
              context,
              PageTransitions.fade(ResultScreen(analysisResult: response.body)),
            );
          } else {
            // Server error (e.g., 404 Not Found, or 500 Internal Server Error)
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Server error: ${response.statusCode}. Please check backend connection."),
              ),
            );
            debugPrint("Backend Error: ${response.statusCode} - ${response.body}");
          }
        } on SocketException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Network error: ${e.message}. Check internet connection."),
            ),
          );
          debugPrint("Socket Error: $e");
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('upload_failed'.tr())),
          );
          debugPrint("Network/Processing Error: $e");
        }

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not read any text. Please try again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // This catches network connection errors (like if the backend isn't turned on)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('upload_failed'.tr())),
      );
      debugPrint("Network/Processing Error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _processImage(image.path);
    }
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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(), 
        ),
        title: Text(
          "scan_ingredients".tr(), 
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 1. The Camera Card Container
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Camera Preview Window
                    Container(
                      height: 300, 
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _isCameraInitialized && controller != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(controller!),
                                // The Green Focus Frame
                                Center(
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.8),
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
                                  const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text("camera_preview".tr(), style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),

                    // "Take Photo" Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text("take_photo".tr(), style: const TextStyle(fontSize: 16)),
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

                    // "Upload from Gallery" Button 
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.file_upload_outlined, color: frovyGreen),
                        label: Text("upload_from_gallery".tr(), style: const TextStyle(fontSize: 16, color: frovyGreen)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: frovyGreen.withValues(alpha: 0.5)),
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

              // 2. "How to scan" Instructional Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : frovyBeige, 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "how_to_scan".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : frovyText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint("scan_instruction_1".tr(), isDark),
                    _buildBulletPoint("scan_instruction_2".tr(), isDark),
                    _buildBulletPoint("scan_instruction_3".tr(), isDark),
                    _buildBulletPoint("scan_instruction_4".tr(), isDark),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Footer Links
              Text(
                "cant_scan_label".tr(),
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransitions.slideRight(const ManualEntryScreen()),
                  );
                },
                child: Text(
                  "try_manual_entry".tr(),
                  style: const TextStyle(color: frovyGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the bullet points
  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: frovyGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : frovyText,
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