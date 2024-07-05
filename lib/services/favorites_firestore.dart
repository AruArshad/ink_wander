import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink_wander/models/prompts.dart';
import 'package:ink_wander/screens/text_display.dart';
import 'package:ink_wander/widgets/favorite_prompt_tile.dart';

class FavoritesFirestore {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String> addToFavorites(String userId, String promptText, String category) async {
    final prompt = Prompt(
      prompt: promptText,
      category: category,
      userId: userId,
      createdAt: DateTime.now(),
      isFavorite: true,
    );

    final docRef = await firestore.collection('prompts').add(prompt.toMap());
    final generatedId = docRef.id;

    return generatedId;
  }

  Future<void> showFavoritePromptsDialog(BuildContext context, bool isDarkMode) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Handle case where user is not signed in
      return;
    }

    final fullPrompt = await _getFullPromptByUser(userId);

    if (fullPrompt == '') {
      // Handle case where user has no favorites
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have no favorited prompts yet!'),
        ),
      );
      return;
    }

    final favorites = await _getFavoritePrompts(userId);

    // Sort prompts alphabetically (optional)
    favorites.sort((a, b) => a.prompt.compareTo(b.prompt));

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 650,
            child: Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Your Favorites',
                      style: GoogleFonts.satisfy(
                        textStyle: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final prompt = favorites[index];
                        final favPrompt = fullPrompt;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: FavoritePromptTile(
                            prompt: prompt,
                            isDarkMode: isDarkMode,
                            onTap: () async {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TextDisplay(
                                    prompt: favPrompt,
                                    category: prompt.category,
                                    isFavorite: prompt.isFavorite,
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: 100.0, // Adjust width as desired
                      height: 50.0, // Adjust height as desired
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode? const Color.fromARGB(255, 179, 53, 53) : const Color.fromARGB(255, 230, 19, 19),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
          ),
        );
      },
    );
  }

  Future<List<Prompt>> _getFavoritePrompts(String userId) async {
    final querySnapshot = await FavoritesFirestore.firestore
        .collection('prompts')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .get();

    final favorites = querySnapshot.docs.map((doc) {
      final promptData = doc.data();
      final prompt = Prompt.fromMap(promptData);
      final oneLinePrompt = prompt.prompt.substring(0, 120) + (prompt.prompt.length > 120 ? '...' : ''); // Truncate with ellipsis
      return prompt.copyWith(prompt: oneLinePrompt, ); // Update prompt with truncated version
    }).toList();

    return favorites;
  }

  Future<String> _getFullPromptByUser(String userId) async {
    final querySnapshot = await FavoritesFirestore.firestore
      .collection('prompts')
      .where('userId', isEqualTo: userId)
      .where('isFavorite', isEqualTo: true)
      .limit(1) // Limit to 1 document
      .get();

    if (querySnapshot.docs.isEmpty) {
      return ''; // Or return a default value as needed
    }

    final docSnapshot = querySnapshot.docs.first;
    final promptData = docSnapshot.data();

    final fullPrompt = promptData['prompt'] as String;
    return fullPrompt;
  }

  Future<void> deleteFavoritePrompt(BuildContext context, userId) async {
    // Validate user ID presence
    if (userId.isEmpty) {
      throw Exception('Missing user ID');
    }

    try {
      // Build the query based on user ID and favorite flag
      final querySnapshot = await FavoritesFirestore.firestore
        .collection('prompts')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .limit(1)
        .get();

      // Check if any documents were found
      if (querySnapshot.docs.isEmpty) {
        // print('No favorite prompt found for this user.');
        return; // Handle case where no matching prompt is found
      }

      // Get the document snapshot and ID
      final docSnapshot = querySnapshot.docs.first;
      docSnapshot.id;

      // Delete the document
      await docSnapshot.reference.delete();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt removed from favorites!'),
        ),
      );

      // print('Favorite prompt (document ID: $documentId) deleted successfully.');
    } on FirebaseException catch (e) {
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
        ),
      );
    }
  }

}
