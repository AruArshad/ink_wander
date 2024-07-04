import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
    required this.isDarkMode
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isSelected
        ? (isDarkMode ? Colors.blueAccent.shade700 : const Color.fromARGB(255, 96, 144, 221))
        : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                title,
                style: GoogleFonts.josefinSans(
                  textStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                ),
              ),
            ),
            Icon(
              icon,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
