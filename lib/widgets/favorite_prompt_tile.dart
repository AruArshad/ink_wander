import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink_wander/models/prompts.dart';

class FavoritePromptTile extends StatelessWidget {
  final Prompt prompt;
  final Function() onTap;
  final bool isDarkMode;

  const FavoritePromptTile({
    super.key,
    required this.prompt,
    required this.onTap, 
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack( // Stack allows layering content
        children: [
          ListTile(
            tileColor: isDarkMode
                ? const Color.fromARGB(255, 47, 81, 99) // Dark mode tile color
                : const Color.fromARGB(255, 200, 220, 230), // Light mode tile color
            leading: Icon(
              prompt.isFavorite ? Icons.star : Icons.star_border_outlined,
              color: isDarkMode ? Colors.white : Colors.black, // Icon color based on darkMode
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: prompt.prompt,
                    style: GoogleFonts.sora(
                      textStyle: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? Colors.white : Colors.black, // Text color based on darkMode
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '\n\nCategory: ${prompt.category}',
                    style: GoogleFonts.margarine(
                      textStyle: TextStyle(
                        fontSize: 17.0,
                        color: isDarkMode ? Colors.white : Colors.black, // Text color based on darkMode
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
