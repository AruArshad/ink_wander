import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class CustomPromptGenerator {
  final String apiKey;

  CustomPromptGenerator({required this.apiKey});

  Future<String?> generateCustomPrompt(
      String prompt, String genre, int wordCount, String? imageUrl) async {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
    ];

    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        safetySettings: safetySettings);

    final image = imageUrl != null ? await File(imageUrl).readAsBytes() : null;
    // final image = await File(imageUrl).readAsBytes();

    var imageParts = [];

    final finalprompt = TextPart('''
            Write a creative text based on the user input. If user didn't enter anything, give an example:

            * Prompt: $prompt (optional image: $imageUrl)
            * Genre: $genre
            * Word Count: $wordCount

            Output will include:

            * Genre: (displayed text)
            * Word Count: (displayed text)
            ''');
    if (image != null) {
      imageParts = [
        DataPart('image/jpeg', image),
      ];
    } else {
      imageParts = [];
    }

    try {
      final response = await model.generateContent([
        Content.multi([finalprompt, ...imageParts])
      ]);
      // final response = await model.generateContent(content);
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
