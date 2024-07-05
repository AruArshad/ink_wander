import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPromptForm extends StatefulWidget {
  final Function(String prompt, String genre, int wordCount) onGenerate;
  final bool isDarkMode;

  const CustomPromptForm({
    super.key,
    required this.onGenerate,
    required this.isDarkMode,
  });

  @override
  State<CustomPromptForm> createState() => _CustomPromptFormState();
}

class _CustomPromptFormState extends State<CustomPromptForm> {
  bool _isLoading = false;
  final _promptController = TextEditingController();
  String _selectedGenre = 'Fiction';
  int _wordCount = 100;

  final _genres = ['Fiction', 'Poetry', 'Non-Fiction', 'Speechwriting', 'Playwriting', 'Screenwriting']; // Adjust genres as needed

  Color _textColor(BuildContext context) => widget.isDarkMode ? Colors.white : Colors.black;
  Color _backgroundColor(BuildContext context) => widget.isDarkMode ? Colors.black26 : Colors.grey.shade200;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: _backgroundColor(context),
      ),
      child: Column(
        children: [
          Text(
            'Custom Prompt',
            style: GoogleFonts.bodoniModa( // Set font (optional)
              color: _textColor(context),
              fontSize: 20.0, // Adjust font size as needed
              fontWeight: FontWeight.bold, // Adjust font weight (optional)
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _promptController,
            decoration: InputDecoration(
              labelText: 'Enter your custom prompt:',
              border: const OutlineInputBorder(),
              labelStyle: GoogleFonts.lora( // Set label font
                color: _textColor(context),
                fontSize: 17.0, // Adjust font size as needed
                fontWeight: FontWeight.bold
              ),
              // ... other decoration properties
            ),
            maxLines: 3,
            style: GoogleFonts.lora( // Set text font
              color: _textColor(context),
              fontSize: 16.0, // Adjust font size as needed
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Text(
                'Genre: ',
                style: GoogleFonts.montserrat( // Set font using GoogleFonts
                  color: _textColor(context),
                  fontSize: 17.0, // Adjust font size as needed
                ),
              ),
              const SizedBox(width: 10.0),
              DropdownButton<String>(
                value: _selectedGenre,
                items: _genres.map((genre) => DropdownMenuItem(
                  value: genre,
                  child: Text(genre, style: GoogleFonts.montserrat( // Set font using GoogleFonts
                    color: _textColor(context),
                    fontSize: 17.0, // Adjust font size as needed
                  )),
                )).toList(),
                onChanged: (genre) => setState(() => _selectedGenre = genre!),
                dropdownColor: widget.isDarkMode ? Colors.grey[800] : Colors.white, // Set dropdown background color
                underline: const SizedBox(), // Remove default underline
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded, // Replace with your icon
                  color: _textColor(context) // Set color based on dark mode
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Text(
                'Word Count: ',
                style: GoogleFonts.montserrat( // Set font using GoogleFonts
                  color: _textColor(context),
                  fontSize: 17.0, // Adjust font size as needed
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Slider(
                  value: _wordCount.toDouble(),
                  min: 100,
                  max: 1000,
                  divisions: 10,
                  onChanged: (value) => setState(() => _wordCount = value.toInt()),
                  activeColor: widget.isDarkMode ? Colors.white : Colors.blue, // Set active track color
                  inactiveColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300], // Set inactive track color
                  thumbColor: widget.isDarkMode ? Colors.white : Colors.blue, // Set thumb color
                ),
              ),
              Text(
                '$_wordCount words',
                style: GoogleFonts.montserrat( // Set font using GoogleFonts
                  color: _textColor(context),
                  fontSize: 14.0, // Adjust font size as needed
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true; 
              });

              try {
                await widget.onGenerate(_promptController.text, _selectedGenre, _wordCount);

                setState(() {
                  _isLoading = false;
                  // Update your data-related state variables with generatedData
                });
              } catch (error) {
                if (kDebugMode) {
                  print(error);
                } // For debugging purposes
                setState(() {
                  _isLoading = false; // Hide the progress indicator in case of errors
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isDarkMode ? Colors.blueGrey : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator() // Show progress indicator while loading
                : const Text('Generate'), // Display "Generate" when not loading
          ),
        ],
      ),
    );
  }
}
