import 'package:flutter/material.dart';
import 'package:ink_wander/models/prompts.dart';

class FeaturedPromptsList extends StatelessWidget {
  final List<Prompt> prompts;
  final Function(Prompt) onFavoriteToggle;

  const FeaturedPromptsList({
    super.key,
    required this.prompts, required this.onFavoriteToggle, required this.isDarkMode
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {

    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Featured Prompts',
              style: TextStyle(
                color: textColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for single-column view
            itemCount: prompts.length,
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              return PromptListItem(prompt: prompt, onFavoriteToggle: onFavoriteToggle, isDarkMode: isDarkMode,);
            },
          ),
        ],
      ),
    );
  }
}

class PromptListItem extends StatelessWidget {
  final Prompt prompt;
  final Function(Prompt) onFavoriteToggle;

  const PromptListItem({super.key, required this.prompt, required this.onFavoriteToggle, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {

    final Color backgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional: Add a small genre icon based on prompt.category
          Icon(Icons.lightbulb_outline, size: 20.0, color: textColor),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              prompt.prompt,
              style: TextStyle(color: textColor, fontSize: 16.0),
            ),
          ),
          // Optional: Add functionality and icon for favoriting prompts
          IconButton(
            icon: Icon(
              prompt.isFavorite ? Icons.star : Icons.star_border,
              color: textColor,
            ),
            onPressed: () => onFavoriteToggle(prompt)
          ),
        ],
      ),
    );
  }
}
