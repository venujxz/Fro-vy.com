import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // 1. Ensure this is a fresh key from https://aistudio.google.com/
  static const String _apiKey = 'AIzaSyAVYwvlXe8DaPSyyE3PRjfMYzU8mkdfeVI';

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
    final age = _calculateAge(dob);

    final prompt = '''
You are a health and nutrition advisor for an app called Frovy.

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
- Look at the flagged ingredients and check if any of them specifically interact with this user's conditions or allergies.
- For EACH issue you find, write one warning that is 2-3 sentences long.
- Each warning must address ONE specific issue only — do not combine multiple issues in one warning.
- Maximum 5 warnings total.
- If you find no issues specific to this user's profile, return exactly: ["No specific concerns found for your health profile."]
- Write in a friendly, informative tone. Do not be alarmist.
- Return ONLY a valid JSON array of strings. No extra text, no markdown, no code blocks.

Example format:
["Warning about ingredient X for this user.", "Warning about ingredient Y for this user."]

''';

    // We try the most modern model (2.5-flash) across both API versions.
    // Google recently retired many 1.5 aliases, which caused the 404s.
    final endpoints = [
      '/v1beta/models/gemini-2.5-flash:generateContent',
      '/v1/models/gemini-2.5-flash:generateContent',
    ];

    String lastError = '';

    for (var endpoint in endpoints) {
      try {
        final url = Uri.https('generativelanguage.googleapis.com', endpoint, {'key': _apiKey});

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [{'text': prompt}]
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'responseMimeType': 'application/json'
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText = data['candidates'][0]['content']['parts'][0]['text'];

          // Because of responseMimeType, we expect clean JSON.
          final List<dynamic> list = jsonDecode(rawText.trim());
          return list.cast<String>();
        } else {
          lastError = 'Status ${response.statusCode}: ${response.body}';
          // Continue to next endpoint if 404 or 400
          continue;
        }
      } catch (e) {
        lastError = e.toString();
      }
    }

    // If all attempts fail, return the error message for debugging
    return ['Error: $lastError'];
  }

  int _calculateAge(String dob) {
    try {
      DateTime birthDate;
      // Handle both YYYY-MM-DD and DD-MM-YYYY formats
      if (dob.contains('-')) {
        final parts = dob.split('-');
        if (parts[0].length == 4) {
          birthDate = DateTime.parse(dob); // YYYY-MM-DD
        } else {
          birthDate = DateTime(
            int.parse(parts[2]), // Year
            int.parse(parts[1]), // Month
            int.parse(parts[0]), // Day
          );
        }
      } else {
        birthDate = DateTime.parse(dob);
      }

      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      print('Age calculation error: $e');
      return 0;
    }
  }
}