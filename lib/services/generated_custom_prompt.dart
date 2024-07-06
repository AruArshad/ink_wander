import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class CustomPromptGenerator {
  final String apiKey;

  CustomPromptGenerator({required this.apiKey});

  Future<String?> generateCustomPrompt(String prompt, String genre, int wordCount) async {

    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    ];

    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey, safetySettings: safetySettings);
    final content = [
      Content.text('''Write a creative text based on the user input: 

      $prompt and use the $genre genre.

      Always display the information below in the output:

      Genre: $genre

      Word count: $wordCount

      ''')
    ];

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
