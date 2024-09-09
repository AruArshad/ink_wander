import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ink_wander/widgets/loading_indic.dart';

// ignore: must_be_immutable
class CustomPromptForm extends StatefulWidget {
  final Function(String prompt, String genre, int wordCount, String? imageUrl)
      onGenerate;
  final bool isDarkMode;

  final TextEditingController promptController; // Pass controller from HomePage
  String selectedGenre; // Pass selected genre from HomePage
  String? imageUrl; // Pass image URL (optional) from HomePage

  CustomPromptForm({
    super.key,
    required this.onGenerate,
    required this.isDarkMode,
    required this.promptController,
    required this.selectedGenre,
    this.imageUrl,
  });

  @override
  State<CustomPromptForm> createState() => _CustomPromptFormState();
}

class _CustomPromptFormState extends State<CustomPromptForm> {
  bool _isLoading = false;
  int _wordCount = 100;

  final _genres = [
    'Fiction',
    'Poetry',
    'Non-Fiction',
    'Speechwriting',
    'Playwriting',
    'Screenwriting',
    'Romance',
    'Mystery'
  ]; // Adjust genres as needed

  Color _textColor(BuildContext context) =>
      widget.isDarkMode ? Colors.white : Colors.black;

  @override
  void dispose() {
    super.dispose();
    widget.promptController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: widget.isDarkMode
            ? const Color.fromARGB(255, 26, 25, 25)
            : Colors.grey.shade200,
      ),
      child: Column(
        children: [
          Text(
            'Custom Prompt',
            style: TextStyle(
                // Set font (optional)
                color: _textColor(context),
                fontSize: 20.0, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Adjust font weight (optional)
                fontFamily: 'BodoniModa'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: widget.promptController,
            decoration: InputDecoration(
              labelText: 'Enter your custom prompt:',
              border: const OutlineInputBorder(),
              labelStyle: TextStyle(
                  // Set label font
                  color: _textColor(context),
                  fontSize: 17.0, // Adjust font size as needed
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lora'),
              fillColor: widget.isDarkMode
                  ? const Color.fromARGB(255, 41, 41, 43)
                  : Colors.white,
              filled: true,
            ),
            maxLines: 3,
            style: TextStyle(
                // Set text font
                color: _textColor(context),
                fontSize: 16.0, // Adjust font size as needed
                fontFamily: 'Lora'),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Image: ',
                style: TextStyle(
                    color: _textColor(context),
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode
                      ? const Color.fromARGB(255, 55, 58, 59)
                      : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (widget.imageUrl != null)
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 100.0,
                    height: 100.0,
                    child: kIsWeb
                        ? Image.network(widget.imageUrl!)
                        : Image.file(
                            File(widget.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 10.0),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        widget.imageUrl = null;
                      });
                    },
                    icon: const Icon(Icons.delete),
                    color: widget.isDarkMode ? Colors.white : Colors.blue,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Text(
                'Genre: ',
                style: TextStyle(
                    color: _textColor(context),
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(width: 10.0),
              DropdownButton<String>(
                value: widget.selectedGenre,
                items: _genres
                    .map((genre) => DropdownMenuItem(
                          value: genre,
                          child: Text(genre,
                              style: TextStyle(
                                  // Set font using GoogleFonts
                                  color: _textColor(context),
                                  fontSize: 17.0,
                                  fontFamily: 'Montserrat')),
                        ))
                    .toList(),
                onChanged: (genre) =>
                    setState(() => widget.selectedGenre = genre!),
                dropdownColor: widget.isDarkMode
                    ? CustomColors.firebaseNavy
                    : Colors.white,
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
                style: TextStyle(
                    color: _textColor(context),
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Slider(
                  value: _wordCount.toDouble(),
                  min: 100,
                  max: 1000,
                  divisions: 10,
                  onChanged: (value) =>
                      setState(() => _wordCount = value.toInt()),
                  activeColor: widget.isDarkMode
                      ? Colors.white
                      : Colors.blue, // Set active track color
                  inactiveColor: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300], // Set inactive track color
                  thumbColor: widget.isDarkMode
                      ? Colors.white
                      : Colors.blue, // Set thumb color
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit), // Edit icon
                color: widget.isDarkMode ? Colors.white : Colors.blue,
                onPressed: () {
                  // Show dialog for manual entry
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Enter Word Count'),
                        content: TextField(
                          controller: TextEditingController(
                              text:
                                  '$_wordCount'), // Pre-fill with current value
                          keyboardType: TextInputType
                              .number, // Set keyboard type for numbers
                          onChanged: (value) {
                            int? parsedValue = int.tryParse(value);
                            if (parsedValue != null &&
                                parsedValue >= 100 &&
                                parsedValue <= 1000) {
                              setState(() => _wordCount = parsedValue);
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Text(
                '$_wordCount words',
                style: TextStyle(
                    color: _textColor(context),
                    fontSize: 14.0,
                    fontFamily: 'Montserrat'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              await widget.onGenerate(
                  widget.promptController.text,
                  widget.selectedGenre,
                  _wordCount,
                  widget.imageUrl?.toString());

              setState(() {
                _isLoading = false;
                widget.promptController.clear();
                widget.imageUrl = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isDarkMode
                  ? const Color.fromARGB(255, 55, 58, 59)
                  : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const LoadingIndicator() // Show progress indicator while loading
                : const Text(
                    'Generate',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ), // Display "Generate" when not loading
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() => widget.imageUrl = pickedImage.path);
    } else {
      setState(
          () => widget.imageUrl = null); // Set to null if no image selected
    }
  }
}
