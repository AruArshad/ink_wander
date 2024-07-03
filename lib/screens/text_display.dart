import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_wander/models/prompts.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/services/favorites_firestore.dart';

class TextDisplay extends StatefulWidget {

  const TextDisplay({super.key, required this.prompt, required this.category});

  final String prompt;
  final String category;
  
  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  late String _generatedId;
  bool _isFavorited = false;
  bool _isDarkMode = true;

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
        //  removeFromFavorites(userId, _generatedId);
         // ignore: use_build_context_synchronously
         await FavoritesFirestore.removeFromFavorites(context, userId, _generatedId);
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

        // addToFavorites(userId, widget.prompt, widget.category);
        _generatedId = await FavoritesFirestore.addToFavorites(userId, widget.prompt, widget.category);

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

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Ink Wander", style: TextStyle(color: textColor),),
        leading: IconButton(  // Change back button color
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorited ? Icons.star : Icons.star_border, color: textColor),
            onPressed: _onFavoriteButtonPressed,
          ),
          IconButton(
            icon: Icon(Icons.content_copy, color: textColor),
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
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: textColor,),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),
      body: SingleChildScrollView( // Make the body scrollable
      padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            widget.prompt, 
            style: TextStyle(color: textColor, 
            fontSize: 17,
            fontFamily: 'OpenSans',)),
        ),
      ),
    );
  }
}
