import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  // 1. Initialize the Google ML Kit Text Recognizer
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// This function takes the photo file, reads the text, and returns a single string of ingredients
  Future<String?> processImageForText(File imageFile) async {
    try {
      // 2. Convert the Flutter File into an ML Kit InputImage
      final inputImage = InputImage.fromFile(imageFile);

      // 3. Process the image and extract the text
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 4. Combine all the extracted text into one string
      String extractedText = recognizedText.text;
      
      // Optional: Clean up the text (remove newlines, extra spaces)
      extractedText = extractedText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

      if (extractedText.isEmpty) {
        return null; // Return null if no text was found
      }

      return extractedText;
      
    } catch (e) {
      print("OCR Error: $e");
      return null;
    }
  }

  /// IMPORTANT: Always dispose of the recognizer when done to prevent memory leaks!
  void dispose() {
    _textRecognizer.close();
  }
}