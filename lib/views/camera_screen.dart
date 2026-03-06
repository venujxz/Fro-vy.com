import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this to pubspec.yaml if missing
import '../services/ocr_service.dart';
import 'result_screen.dart';
import 'manual_entry_screen.dart'; // CONNECTED: Added for manual entry navigation

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
    _initializeCamera();
  }

  void _initializeCamera() {
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
        // CONNECTED: Navigate to ResultScreen with the OCR data
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
      debugPrint("OCR Error: $e");
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
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
              // 1. Camera Viewfinder Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                    children: [
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
                                _buildFocusFrame(),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator(color: frovyGreen)),
                    ),
                    const SizedBox(height: 20),
                    _buildButton("Take Photo", Icons.camera_alt, _takePhoto, isPrimary: true),
                    const SizedBox(height: 12),
                    _buildButton("Upload from Gallery", Icons.file_upload_outlined, _pickFromGallery, isPrimary: false),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Instructions
              _buildInstructionBox(),

              const SizedBox(height: 24),

              // 3. Footer Link to Manual Entry
              Text("Can't scan the label?", style: TextStyle(color: Colors.grey[600])),
              TextButton(
                onPressed: () {
                  // CONNECTED: Navigate to manual entry screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
                  );
                },
                child: const Text(
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

  // --- UI Helper Methods ---

  Widget _buildFocusFrame() {
    return Center(
      child: Container(
        width: 220,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed, {required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label, style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: frovyGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: frovyGreen),
              label: Text(label, style: const TextStyle(fontSize: 16, color: frovyGreen)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: frovyGreen.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: frovyBeige, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("How to scan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: frovyText)),
          const SizedBox(height: 12),
          _buildBulletPoint("Position the ingredient list within the frame"),
          _buildBulletPoint("Ensure good lighting for best results"),
          _buildBulletPoint("Hold your device steady when capturing"),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 6.0), child: Icon(Icons.circle, size: 6, color: frovyGreen)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: frovyText, fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}