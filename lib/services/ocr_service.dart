import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class OCRService {
  // This URL will point to Thisal's backend.
  // For iOS Simulator, 'localhost' works.
  // For Android Emulator, use '10.0.2.2'.
  final String _baseUrl = 'http://localhost:3000';

  // ─────────────────────────────────────────
  // 1. Compress the image to meet NFR-01 (Speed)
  // ─────────────────────────────────────────

  Future<File?> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(tempDir.path, 'temp_scan.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,    // Reduce quality to 70% to save bandwidth
      minWidth: 1080, // Resize to a standard width
      minHeight: 1920,
    );

    debugPrint('Original size: ${file.lengthSync()} bytes');
    debugPrint('Compressed size: ${await result?.length()} bytes');

    return result != null ? File(result.path) : null;
  }

  // ─────────────────────────────────────────
  // 2. Upload the image (Sequence Diagram Step 9)
  // ─────────────────────────────────────────

  Future<String?> uploadImage(File imageFile) async {
    // A. Compress first
    final File? processedFile = await compressImage(imageFile);
    if (processedFile == null) return null;

    // B. Prepare the POST request
    final uri = Uri.parse('$_baseUrl/analyze-image');
    final request = http.MultipartRequest('POST', uri);

    // C. Attach the file
    final stream = http.ByteStream(processedFile.openRead());
    final length = await processedFile.length();
    final multipartFile = http.MultipartFile(
      'image', // This must match the key Thisal uses in his backend
      stream,
      length,
      filename: p.basename(processedFile.path),
    );

    request.files.add(multipartFile);

    // D. Send and wait for response
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return responseData; // JSON with "Safe/Unsafe"
      } else {
        debugPrint('Failed to upload: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error sending image: $e');
      return null;
    }
  }
}