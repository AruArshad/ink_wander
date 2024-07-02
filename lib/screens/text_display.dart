import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_wander/models/prompts.dart';

class TextDisplay extends StatefulWidget {
  final String prompt;
  final String category;

  const TextDisplay({super.key, required this.prompt, required this.category});

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  bool _isFavorited = false;

  void _onFavoriteButtonPressed() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      if (_isFavorited) {
        // User wants to unfavorite - show confirmation dialog
        final shouldRemove = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Prompt'),
            content: const Text('Are you sure you want to remove this prompt from your favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Remove
                child: const Text('Remove'),
              ),
            ],
          ),
        );

        if (shouldRemove ?? false) {
          // User confirmed removal
         removeFromFavorites(userId, _generatedId);
          setState(() {
            _isFavorited = false;
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prompt removed from favorites!'),
            ),
          );
        }
      } else {

        addToFavorites(userId, widget.prompt, widget.category);

        setState(() {
          _isFavorited = true;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt saved to favorites!'),
          ),
        );
      }
    } else {
      // Handle case where user is not signed in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save prompts!'),
        ),
      );
    }
  }

  late String _generatedId;

  Future<void> addToFavorites(String userId, String promptText, String category) async {
    final prompt = Prompt(
      prompt: promptText,
      category: category,
      userId: userId,
      createdAt: DateTime.now(),
      isFavorite: true,
    );

    final firestore = FirebaseFirestore.instance;
    final docRef = await firestore.collection('prompts').add(prompt.toMap());

    _generatedId = docRef.id;
    if (kDebugMode) {
      print('Generated document ID: $_generatedId');
    }
  }

  Future<void> removeFromFavorites(String userId, String generatedId) async {
    final firestore = FirebaseFirestore.instance;

    // Construct the document reference based on the generated ID
    final docRef = firestore.collection('prompts').doc(generatedId);

    try {
      // Delete the document from Firestore
      await docRef.delete();

      // Update local state (optional)
      if (userId == FirebaseAuth.instance.currentUser?.uid) {
        // Assuming you have a way to update the _isFavorited state in your widget
        // (consider using a state management solution like Provider or BLoC)
        // setState(() => _isFavorited = false);
        if (kDebugMode) {
          print('Prompt removed from favorites locally (update UI if needed).');
        }
      }

      // Show success snackbar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt removed from favorites!'),
        ),
      );
    } on FirebaseException catch (e) {
      // Handle potential errors during deletion
      if (kDebugMode) {
        print('Error removing prompt from favorites: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ink Wander"), // Use a constant title
        actions: [
          IconButton(
            icon: Icon(_isFavorited ? Icons.star : Icons.star_border),
            onPressed: _onFavoriteButtonPressed,
          ),
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () async {
              // Use clipboard package to copy text
              await Clipboard.setData(ClipboardData(text: widget.prompt));
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prompt copied to clipboard!'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Make the body scrollable
        child: Center(
          child: Text(widget.prompt),
        ),
      ),
    );
  }
}
