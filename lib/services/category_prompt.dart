import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ink_wander/api_key.dart';

class CategoryPrompt {
  static Future<String?> generatePrompt(String category, String prompt) async {

    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    ];

    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: API_KEY, safetySettings: safetySettings);
    final content = [Content.text('Use $prompt as context and $category as genre and write me a few creative texts.')];

    try {
      final response = await model.generateContent(content);
      return response.text;
    } catch (error) {
      if (kDebugMode) {
        print('Error generating prompt: $error');
      }
      // Handle errors gracefully (optional)
      return null; // Or provide a fallback message
    }
  }
}
