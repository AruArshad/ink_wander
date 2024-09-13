// import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_wander/services/favorites_firestore.dart';
import 'package:ink_wander/services/theme_provider.dart';
import 'package:ink_wander/widgets/particle_bg.dart';
// import 'package:ink_wander/widgets/banner_ad.dart';
// import 'package:ink_wander/widgets/interstitial_ad.dart';
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
  // bool _canShowAd = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorite;
    // Timer(const Duration(seconds: 5), () {
    //   setState(() {
    //     debugPrint("Timer ended");
    //     _canShowAd = true;
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
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
          style: TextStyle(
              color: textColor,
              fontFamily: 'Margarine'), // Use dynamic text color
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
      body: Stack(
        children: [
          Positioned.fill(
            child: ParticleBackground(
              isDarkMode: isDarkMode,
            ),
          ),
          SingleChildScrollView(
            // Make the body scrollable
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // if (_canShowAd) const InterstitialAdWidget(),
                Center(
                  child: Text(
                    widget.prompt,
                    style: TextStyle(
                        color: textColor, fontSize: 16, fontFamily: 'Sora'),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
          // Fixed Banner Ad at the bottom
          // const Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: MyBannerAdWidget(),
          // ),
        ],
      ),
    );
  }
}
