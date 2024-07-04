import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final Function() onToggleDarkMode;

  const MyAppBar({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = isDarkMode ? Colors.white : Colors.black; // Dynamic text color for accessibility

    return AppBar(
      title: Text(
        'Ink Wander',
        style: GoogleFonts.margarine(
          textStyle: TextStyle(color: textColor), // Use dynamic text color
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
        color: textColor,
        onPressed: onToggleDarkMode,
      ),
      backgroundColor: backgroundColor, // Use dynamic background color
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
