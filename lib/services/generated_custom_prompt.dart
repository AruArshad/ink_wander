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
        Craft a compelling narrative inspired by:

        * **Prompt:** $prompt (Visual reference: $imageUrl)
        * **Genre:** $genre
        * **Word Count:** $wordCount

        Deliver a captivating story that:

        * Adheres to the specified genre.
        * Effectively utilizes the provided prompt or image.
        * Meets the exact word count requirement.

        Output will always include:

        * Genre: $genre
        * Word Count: $wordCount
        * Prompt: $prompt
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
