import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:image_picker/image_picker.dart';

class CustomPromptForm extends StatefulWidget {
  final Function(String prompt, String genre, int wordCount, String? imageUrl) onGenerate;
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
  String? _imageUrl;

  final _genres = ['Fiction', 'Poetry', 'Non-Fiction', 'Speechwriting', 'Playwriting', 'Screenwriting', 'Romance', 'Mystery']; // Adjust genres as needed

  Color _textColor(BuildContext context) => widget.isDarkMode ? Colors.white : Colors.black;

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
        color: widget.isDarkMode ? Colors.grey[800] : Colors.grey.shade200,
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
              fillColor: widget.isDarkMode ? CustomColors.firebaseNavy : Colors.white, 
              filled: true,
            ),
            maxLines: 3,
            style: GoogleFonts.lora( // Set text font
              color: _textColor(context),
              fontSize: 16.0, // Adjust font size as needed
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Image: ',
                style: GoogleFonts.montserrat(
                  color: _textColor(context),
                  fontSize: 17.0,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? Colors.blueGrey : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (_imageUrl != null) 
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: SizedBox(
              width: 200.0,
              height: 150.0,
              child: Image.file(
                File(_imageUrl!), // Replace with your actual image path
                fit: BoxFit.cover, // Adjust as needed
              ),
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
                dropdownColor:widget.isDarkMode ? CustomColors.firebaseNavy : Colors.white,
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
                                controller: TextEditingController(text: '$_wordCount'), // Pre-fill with current value
                                keyboardType: TextInputType.number, // Set keyboard type for numbers
                                onChanged: (value) {
                                  int? parsedValue = int.tryParse(value);
                                  if (parsedValue != null && parsedValue >= 100 && parsedValue <= 1000) {
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
                style: GoogleFonts.montserrat(
                  color: _textColor(context),
                  fontSize: 14.0,
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
              
              await widget.onGenerate(_promptController.text, _selectedGenre, _wordCount, _imageUrl?.toString());
                
              setState(() {
                _isLoading = false;
                _promptController.clear();
                _imageUrl = null;
              });
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

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() => _imageUrl = pickedImage.path);
    } else {
      setState(() => _imageUrl = null); // Set to null if no image selected
    }
  }

}
