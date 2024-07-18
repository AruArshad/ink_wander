import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink_wander/services/favorites_firestore.dart';
import 'package:ink_wander/services/theme_provider.dart';
import 'package:provider/provider.dart';

class TextDisplay extends StatefulWidget {
  const TextDisplay(
      {super.key,
      required this.prompt,
      required this.category,
      this.isFavorite = false});

  final String prompt;
  final String category;
  final bool isFavorite;

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorite;
  }

  void _onFavoriteButtonPressed() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      if (_isFavorited) {
        // User wants to unfavorite - show confirmation dialog
        final shouldRemove = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Favorite?'),
            content: const Text(
                'Are you sure you want to remove these texts from your favorites?'),
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
          final favoritesFirestore = FavoritesFirestore();
          // ignore: use_build_context_synchronously
          await favoritesFirestore.deleteFavoritePrompt(context, userId);

          // ignore: use_build_context_synchronously
          // await FavoritesFirestore.removeFromFavorites(context, userId, _generatedId);

          //  await FavoritesFirestore.removeFromFavorites(context, userId, _generatedId);
          setState(() {
            _isFavorited = false;
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Texts removed from favorites!'),
            ),
          );
        }
      } else {
        if (!_isFavorited) {
          await FavoritesFirestore.addToFavorites(
              userId, widget.prompt, widget.category);
        }

        setState(() {
          _isFavorited = true;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Texts saved to favorites!'),
          ),
        );
      }
    } else {
      // Handle case where user is not signed in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save texts!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final toggleTheme = Provider.of<ThemeProvider>(context).toggleTheme;
    final Color backgroundColor =
        isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          "Ink Wander",
          style: GoogleFonts.margarine(
            textStyle: TextStyle(color: textColor), // Use dynamic text color
          ),
        ),
        leading: IconButton(
          // Change back button color
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorited ? Icons.star : Icons.star_border,
                color: textColor),
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
                  content: Text('Texts copied to clipboard!'),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Make the body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            widget.prompt,
            style: GoogleFonts.sora(
              textStyle: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
