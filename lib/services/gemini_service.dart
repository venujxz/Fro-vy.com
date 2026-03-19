import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Using environment variable for API key - set with --dart-define
  static const String _apiKey = String.fromEnvironment(
    'api_key',
    defaultValue: '',
  );

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
    // 1. THE FIX: The 'if' check must be INSIDE the function body, not the parameter list.
    if (_apiKey.isEmpty) {
      return [
        'Error: Gemini API key is missing. Ensure you run with --dart-define-from-file=secrets.json',
      ];
    }

    final age = _calculateAge(dob);

    final prompt =
        '''
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

    // Model endpoints
    final endpoints = [
      '/v1beta/models/gemini-2.5-flash:generateContent',
      '/v1/models/gemini-2.5-flash:generateContent',
      // 1. Try the most stable current alias
      '/v1beta/models/gemini-1.5-flash:generateContent',
      // 2. Try the general "latest" alias (often fixes 404s)
      '/v1beta/models/gemini-flash-latest:generateContent',
      // 3. Try the stable v1 version
      '/v1/models/gemini-1.5-flash:generateContent',
    ];

    String lastError = '';

    for (var endpoint in endpoints) {
      try {
        final url = Uri.https('generativelanguage.googleapis.com', endpoint, {
          'key': _apiKey,
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {'temperature': 0.1},
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String rawText =
              data['candidates'][0]['content']['parts'][0]['text'];

          try {
            final List<dynamic> list = jsonDecode(rawText.trim());
            return list.cast<String>();
          } catch (e) {
            return [rawText]; // Fallback to raw text if JSON parse fails
          }
        } else {
          lastError = 'Status ${response.statusCode}: ${response.body}';
          continue;
        }
      } catch (e) {
        lastError = e.toString();
      }
    }

    return ['Error: $lastError'];
  }

  int _calculateAge(String dob) {
    try {
      DateTime birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}
