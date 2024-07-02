import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ink_wander/api_key.dart';

class HomePromptGenerator {
  static Future<String?> generatePrompt() async {
    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: API_KEY);
    final content = [Content.text('I\'m making an app to show random trending topic for users for them to be creative. \n'
                                  'The options I\'m giving them are: Fiction, Poetry, Non-fiction, Speechwriting, Playwriting and Screenwriting. \n'
                                  'Write me one common short prompt where users will use to write more creatively for any of the genres mentioned. \n'
                                  'Don\'t show ##Prompt:. Only 1 sentence')];

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
