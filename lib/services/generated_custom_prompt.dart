import 'dart:io';
import 'package:http/http.dart' as http;

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

    Uint8List? imageData;
    if (imageUrl != null) {
      if (kIsWeb) {
        // For web, fetch the image data using http
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            imageData = response.bodyBytes;
          } else {
            debugPrint('Failed to load image: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Error fetching image: $e');
        }
      } else {
        // For mobile, read the file
        try {
          imageData = await File(imageUrl).readAsBytes();
        } catch (e) {
          debugPrint('Error reading image file: $e');
        }
      }
    }

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

    List<Part> content = [finalprompt];
    if (imageData != null) {
      content.add(DataPart('image/jpeg', imageData));
    }

    try {
      final response = await model.generateContent([Content.multi(content)]);
      return response.text;
    } catch (error) {
      if (kDebugMode) {
        print('Error generating prompt: $error');
      }
      return null;
    }
  }
}
