import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // Set at build time: --dart-define=GEMINI_API_KEY=your_key_here
  // or add to secrets.json and use --dart-define-from-file=secrets.json
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Two stable model endpoints tried in parallel — whichever responds first wins.
  // This eliminates the old behaviour of trying 5 endpoints one-by-one sequentially.
  static const List<String> _endpoints = [
    '/v1beta/models/gemini-2.0-flash:generateContent',
    '/v1beta/models/gemini-1.5-flash:generateContent',
  ];

  static const Duration _timeout = Duration(seconds: 20);

  Future<List<String>> getPersonalisedWarnings({
    required String userName,
    required String gender,
    required String dob,
    required List<String> conditions,
    required List<String> foodAllergies,
    required List<String> avoidIngredients,
    required List<String> cautionIngredients,
    required List<String> allIngredients,
  }) async {
    if (_apiKey.isEmpty) {
      return [
        'Gemini API key is missing. '
        'Run with --dart-define=GEMINI_API_KEY=<your_key> '
        'or add it to secrets.json.',
      ];
    }

    final age = _calculateAge(dob);
    final prompt = _buildPrompt(
      userName: userName,
      age: age,
      gender: gender,
      conditions: conditions,
      foodAllergies: foodAllergies,
      allIngredients: allIngredients,
      avoidIngredients: avoidIngredients,
      cautionIngredients: cautionIngredients,
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {'temperature': 0.1},
    });

    // Fire both endpoints in parallel — take the first successful response.
    final futures = _endpoints.map((endpoint) => _callEndpoint(endpoint, body));

    try {
      // completer lets us resolve as soon as ANY future succeeds
      final completer = Completer<List<String>>();
      int failures = 0;
      String lastError = '';

      for (final future in futures) {
        future.then((result) {
          if (!completer.isCompleted) completer.complete(result);
        }).catchError((e) {
          lastError = e.toString();
          failures++;
          if (failures == _endpoints.length && !completer.isCompleted) {
            completer.completeError(lastError);
          }
        });
      }

      return await completer.future;
    } catch (e) {
      debugPrint('GeminiService error: $e');
      return ['Could not generate personalised analysis. Please try again later.'];
    }
  }

  Future<List<String>> _callEndpoint(String endpoint, String body) async {
    final url = Uri.https(
      'generativelanguage.googleapis.com',
      endpoint,
      {'key': _apiKey},
    );

    final response = await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final String rawText =
        data['candidates'][0]['content']['parts'][0]['text'] as String;

    try {
      final List<dynamic> list = jsonDecode(rawText.trim());
      return list.cast<String>();
    } catch (_) {
      // Model returned plain text instead of JSON — wrap it
      return [rawText.trim()];
    }
  }

  String _buildPrompt({
    required String userName,
    required int age,
    required String gender,
    required List<String> conditions,
    required List<String> foodAllergies,
    required List<String> allIngredients,
    required List<String> avoidIngredients,
    required List<String> cautionIngredients,
  }) {
    return '''
You are a health and nutrition advisor for an app called Fro-vy.

User Profile:
- Name: $userName
- Age: $age years old
- Gender: $gender
- Medical conditions: ${conditions.isEmpty ? 'None reported' : conditions.join(', ')}
- Food allergies / intolerances: ${foodAllergies.isEmpty ? 'None reported' : foodAllergies.join(', ')}

Ingredients in this product:
All: ${allIngredients.join(', ')}
Flagged AVOID: ${avoidIngredients.isEmpty ? 'None' : avoidIngredients.join(', ')}
Flagged CAUTION: ${cautionIngredients.isEmpty ? 'None' : cautionIngredients.join(', ')}

Instructions:
- Check if any flagged ingredients specifically interact with this user's conditions or allergies.
- Write one warning per issue, 2-3 sentences each.
- Maximum 5 warnings total.
- If no issues found, return exactly: ["No specific concerns found for your health profile."]
- Friendly tone. Not alarmist.
- Return ONLY a valid JSON array of strings. No markdown, no code blocks, no preamble.

Example: ["Warning about ingredient X.", "Warning about ingredient Y."]
''';
  }

  int _calculateAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }
}
