import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/models/prompts.dart';

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

  static Future<void> removeFromFavorites(BuildContext context, String userId, String generatedId) async {
    final docRef = firestore.collection('prompts').doc(generatedId);

    try {
      await docRef.delete();

      if (userId == FirebaseAuth.instance.currentUser?.uid) {
        // Assuming you have a way to update the _isFavorited state in your widget
        // (consider using a state management solution like Provider or BLoC)
        // setState(() => _isFavorited = false);
      }

      // Show success snackbar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt removed from favorites!'),
        ),
      );
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
