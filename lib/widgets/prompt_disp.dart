import 'package:flutter/material.dart';

class PromptDisplay extends StatelessWidget {
  final String prompt;
  final bool isDarkMode;

  const PromptDisplay(
      {super.key, required this.prompt, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: isDarkMode
              ? [Colors.white, Colors.white70]
              : [Colors.black, Colors.black87],
        ).createShader(bounds);
      },
      child: Text(
        prompt,
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Lora',
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
