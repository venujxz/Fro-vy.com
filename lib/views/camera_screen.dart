// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  // Nullable so we can safely check before disposing
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  // Fro-vy Brand Colors
  static const Color frovyGreen = Color(0xFF6AA15E);
  static const Color frovyBeige = Color(0xFFEEE8D6);
  static const Color frovyText  = Color(0xFF2C3E28);

  // ─────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;

    final controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    // Safe: only disposes if controller was successfully created
    _controller?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // Image Processing
  // ─────────────────────────────────────────

  Future<void> _processImage(String imagePath) async {
    if (!mounted || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final String? result = await OCRService().uploadImage(File(imagePath));

if (!mounted) return; // ← check mounted BEFORE using context
if (result != null) {
  final String analysisResult = result; // extract to non-nullable local
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResultScreen(analysisResult: analysisResult),
    ),
  );
} else {
  _showSnackBar('Upload failed. Please check your connection.');
}
    } catch (e) {
      debugPrint('Image processing error: $e');
      if (mounted) _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) await _processImage(image.path);
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      if (mounted) _showSnackBar('Could not open gallery. Please try again.');
    }
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _isProcessing || _controller == null) return;

    try {
      final XFile image = await _controller!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      debugPrint('Take photo error: $e');
      if (mounted) _showSnackBar('Could not take photo. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

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
          'Scan Ingredients',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildCameraCard(),
              const SizedBox(height: 24),
              _buildInstructionsBox(),
              const SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────

  Widget _buildCameraCard() {
    return Container(
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
          _buildCameraPreview(),
          const SizedBox(height: 20),
          _buildTakePhotoButton(),
          const SizedBox(height: 12),
          _buildGalleryButton(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.hardEdge,
      child: _isCameraInitialized && _controller != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                // Focus frame overlay
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
                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
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
                  Text(
                    'Camera preview',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTakePhotoButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _takePhoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Take Photo', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: frovyGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: frovyGreen.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : _pickFromGallery,
        icon: const Icon(Icons.file_upload_outlined, color: frovyGreen),
        label: const Text(
          'Upload from Gallery',
          style: TextStyle(fontSize: 16, color: frovyGreen),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: frovyGreen.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: frovyBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to scan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: frovyText,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Position the ingredient list within the frame'),
          _buildBulletPoint('Ensure good lighting for best results'),
          _buildBulletPoint('Hold your device steady when capturing'),
          _buildBulletPoint('The text should be clear and readable'),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Can't scan the label?",
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
          },
          child: const Text(
            'Try manual entry instead',
            style: TextStyle(
              color: frovyGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
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
              style: const TextStyle(color: frovyText, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}