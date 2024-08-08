import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ink_wander/api_key.dart';

class HomePromptGenerator {
  static Future<String?> generatePrompt(BuildContext context) async {
    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: API_KEY);
    final content = [
      Content.text(
          '''I'm making an app to show random trending topic for users for them to be creative.
             The options I'm giving them are: Fiction, Poetry, Non-fiction, Speechwriting, Playwriting, Romance, Mystery and Screenwriting.
             Write me one common and creative short prompt where users will use to write more creatively for any of the genres mentioned.
             Don't show ##Prompt:. Only 1 sentence.''')
    ];

    try {
      final response = await model.generateContent(content);
      return response.text;
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating prompt: $error'),
        ),
      );

      return null; // Or provide a fallback message
    }
  }
}
