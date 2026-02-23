import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this to pubspec.yaml if missing
import '../services/ocr_service.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker(); // For Gallery Uploads

  // Define Fro-vy Brand Colors based on your design
  static const Color frovyGreen = Color(0xFF6AA15E); // Muted Green button
  static const Color frovyBeige = Color(0xFFEEE8D6); // Instructional box bg
  static const Color frovyText = Color(0xFF2C3E28); // Dark green/grey text

  @override
  void initState() {
    super.initState();
    // Initialize Camera
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

  // --- LOGIC: Process the Image (Used by both Camera & Gallery) ---
  Future<void> _processImage(String imagePath) async {
    if (!mounted) return;
    
    // 1. Show Loading UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing image...')),
    );

    try {
      // 2. Call OCR Service
      OCRService ocrService = OCRService();
      
      // TEMPORARY: Fake delay to show UI, remove when backend is ready
      // await Future.delayed(const Duration(seconds: 2)); 
      // String? result = '{"status": "UNSAFE", "ingredients": ["Peanuts", "Sugar"]}';

      // REAL CODE (Uncomment when backend is ready):
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
          const SnackBar(content: Text('Upload failed. Server might be down.')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(), // Just closes app if it's the only screen
        ),
        title: const Text(
          "Scan Ingredients",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                    // Camera Preview Window
                    Container(
                      height: 300, // Fixed height for the square-ish look
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
                                // The Green Focus Frame
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
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("Camera preview", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 20),

                    // "Take Photo" Button (Solid Green)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Take Photo", style: TextStyle(fontSize: 16)),
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

                    // "Upload from Gallery" Button (Outlined)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: Icon(Icons.file_upload_outlined, color: frovyGreen),
                        label: Text("Upload from Gallery", style: TextStyle(fontSize: 16, color: frovyGreen)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: frovyGreen.withOpacity(0.5)),
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
                  color: frovyBeige, // The beige color from your UI
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How to scan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: frovyText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint("Position the ingredient list within the frame"),
                    _buildBulletPoint("Ensure good lighting for best results"),
                    _buildBulletPoint("Hold your device steady when capturing"),
                    _buildBulletPoint("The text should be clear and readable"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Footer Links
              Text(
                "Can't scan the label?",
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to manual entry screen
                },
                child: Text(
                  "Try manual entry instead",
                  style: TextStyle(color: frovyGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the bullet points
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: frovyGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: frovyText, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}