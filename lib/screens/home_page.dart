import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink_wander/api_key.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/screens/text_display.dart';
import 'package:ink_wander/services/category_prompt.dart';
import 'package:ink_wander/services/favorites_firestore.dart';
import 'package:ink_wander/services/generated_custom_prompt.dart';
import 'package:ink_wander/services/home_prompt_generator.dart';
import 'package:ink_wander/widgets/category_card.dart';
import 'package:ink_wander/widgets/custom_prompt_form.dart';
import 'package:ink_wander/widgets/user_info_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isDarkMode = true;
  String _selectedCategory = '';
  String? _generatedPrompt = '';
  // ignore: unused_field
  bool _isRefreshing = false;
  bool _isLoading = false;

  void _showUserInfoPopup() {
    showDialog(
      context: context,
      builder: (context) => UserInfoPopup(user: FirebaseAuth.instance.currentUser!, isDarkMode: _isDarkMode), // Pass current user
    );
  }

  void _showGeneratedPrompt() async {
    setState(() {
      _generatedPrompt = null; // Reset to null, but with a delay
    });
    await Future.delayed(const Duration(milliseconds: 200)); // Introduce a delay
    // ignore: use_build_context_synchronously
    final String? prompt = await HomePromptGenerator.generatePrompt(context);
    if (prompt != null) {
      setState(() {
        _generatedPrompt = prompt;
      });
    } else {
      // Handle potential error or display a fallback message
      if (kDebugMode) {
          print("Error generating prompt!");
        }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true; // Set flag to show progress indicator
      _generatedPrompt = ''; // Reset prompt for refresh
    });
    _showGeneratedPrompt(); // Re-fetch prompt
    setState(() {
      _isRefreshing = false; // Reset flag after refresh
    });
  }

  void _onCategoryTap(String category, String prompt) async {
    setState(() {
      _selectedCategory = category;
    });

    // Show a circular progress indicator while generating the prompt
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing while loading
      builder: (BuildContext context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Generate the prompt asynchronously
    final generatedPrompt = await CategoryPrompt.generatePrompt(category, prompt);

    // Dismiss the progress dialog after generation
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Close the dialog

    if (generatedPrompt != null) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => TextDisplay(prompt: generatedPrompt, category: _selectedCategory, isDarkMode: _isDarkMode),
        ),
      );
    } else {
      // Handle cases where prompt generation fails (optional)
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt generation failed. Please try again later.'),
        ),
      );
    }
  }

  void _showConfirmationDialog(String category, String prompt) {

    final Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    final Color textColor = _isDarkMode ? Colors.white : Colors.black;

    setState(() {
      _selectedCategory = category;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: textColor),
          backgroundColor: backgroundColor,
          content: Text(
            'Are you sure you want to write based on the selected category: $_selectedCategory?', 
            style: TextStyle(fontSize: 16.0, color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () { 
                setState(() {
                  _selectedCategory = '';
                });
                Navigator.pop(context, false); // Cancel
              },
              child: Text('Cancel', style: TextStyle(fontSize: 17.0, color: textColor),),
            ),
            TextButton(
              onPressed: () { 
                Navigator.pop(context, true); // Confirm
              },
              child: Text('Write', style: TextStyle(fontSize: 17.0, color: textColor),),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        // Call your _onCategoryTap function to handle prompt generation and navigation
        _onCategoryTap(category, prompt); // Assuming you have a default empty prompt
        setState(() {
          _selectedCategory = '';
        });
      }
    });
  }

  void _onCustomPromptGenerated(String prompt, String genre, int wordCount) async {
    final promptGenerator = CustomPromptGenerator(apiKey: API_KEY);
    final generatedPrompt = await promptGenerator.generateCustomPrompt(prompt, genre, wordCount);
    if (generatedPrompt != null) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => TextDisplay(
            prompt: generatedPrompt,
            category: genre,
            isDarkMode: _isDarkMode,
          ),
        ),
      );
    } else {
      // Handle cases where prompt generation fails (optional)
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt generation failed. Please try again later.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _showGeneratedPrompt();
  }

  @override
  Widget build(BuildContext context) {
    
    final Color backgroundColor = _isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = _isDarkMode ? Colors.white : Colors.black; // Dynamic text color for accessibility
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return; // Avoid unnecessary processing if pop wasn't attempted
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: backgroundColor,
            titleTextStyle: TextStyle(color: textColor, fontSize: 23, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: textColor, fontSize: 19),
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit Ink Wander?'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                onPressed: () => Navigator.pop(context, false), // Cancel exit
                child: const Text('Cancel', style: TextStyle(fontSize: 17),),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                onPressed: () => Navigator.pop(context, true), // Confirm exit
                child: const Text('Yes', style: TextStyle(fontSize: 17),),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          exitApp(); // Exit the app if confirmed
        }
      },
      child: Scaffold(
        backgroundColor: _isDarkMode ? CustomColors.firebaseNavy : Colors.white,
        appBar: AppBar(
        title: Text(
          'Ink Wander',
          style: GoogleFonts.margarine(
            textStyle: TextStyle(color: textColor), // Use dynamic text color
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
          color: textColor,
          onPressed:() {
            setState(() {
              _isDarkMode = !_isDarkMode;
            });
          },
        ),
        actions: [
          IconButton(
            icon: 
            _isLoading ? 
               CircularProgressIndicator(  
                valueColor: AlwaysStoppedAnimation(textColor),
                strokeWidth: 2.0,) 
            : const Icon(Icons.favorite),
            color: textColor,
            onPressed: () async {
              setState(() { 
                _isLoading = true;
              });
              final favoritesFirestore = FavoritesFirestore();
              await favoritesFirestore.showFavoritePromptsDialog(context, _isDarkMode);
              setState(() { 
                _isLoading = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_2_rounded), // Replace with your desired icon
            color: textColor,
            onPressed: _showUserInfoPopup,
          ),
        ],
        backgroundColor: backgroundColor, // Use dynamic background color
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: PopScope(
            canPop: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section with Daily Prompt (dummy for now)
                    Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/hero_background.jpeg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.multiply), // Subtle darkening effect
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay for a more modern look
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _isDarkMode
                                ? [
                                    const Color(0xFF2196F3).withOpacity(0.6), // Deep Purple Accent
                                    const Color(0xFF1976D2).withOpacity(0.6), // Indigo Accent
                                  ]
                                : [
                                    Colors.lightBlueAccent.withOpacity(0.7),
                                    Colors.lightGreenAccent.withOpacity(0.7),
                                  ],
                            ),
                          ),
                        ),
                        Center(
                          child: _generatedPrompt == null
                              ? CircularProgressIndicator(color: textColor) // Show progress indicator
                              : Text(
                                _generatedPrompt!,
                                style: GoogleFonts.lora(
                                  textStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: _isDarkMode ? FontWeight.bold : FontWeight.w600, // Adjust font weight for dark/light mode
                                    color: _isDarkMode ? Colors.white : Colors.black87, // Adjust text color for dark/light mode
                                    shadows: [
                                        Shadow(
                                            offset: const Offset(2.0, 2.0),
                                            blurRadius: 4.0,
                                            color: Colors.black.withOpacity(0.2), // Adjust shadow color for dark mode
                                        ),
                                    ],
                                  ),
                                ),
                                textAlign: TextAlign.center,
                            ),
                        ),
                        Positioned(
                          bottom: 10.0,
                          right: 8.0, 
                          child: IconButton(
                            icon: Icon(Icons.content_copy, color: textColor),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: _generatedPrompt!));
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Prompt copied to clipboard!'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  // Category Cards
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CategoryCard(
                              title: 'Fiction',
                              icon: Icons.book,
                              isSelected: _selectedCategory == 'Fiction',
                              onTap: () => _showConfirmationDialog('Fiction', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: CategoryCard(
                              title: 'Poetry',
                              icon: Icons.edit,
                              isSelected: _selectedCategory == 'Poetry',
                              onTap: () => _showConfirmationDialog('Poetry', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: CategoryCard(
                              title: 'Speechwriting',
                              icon: Icons.speaker,
                              isSelected: _selectedCategory == 'Speechwriting',
                              onTap: () => _showConfirmationDialog('Speechwriting', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: CategoryCard(
                              title: 'Playwriting',
                              icon: Icons.play_arrow,
                              isSelected: _selectedCategory == 'Playwriting',
                              onTap: () => _showConfirmationDialog('Playwriting', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: CategoryCard(
                              title: 'Non-Fiction',
                              icon: Icons.newspaper,
                              isSelected: _selectedCategory == 'Non-Fiction',
                              onTap: () => _showConfirmationDialog('Non-Fiction', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: CategoryCard(
                              title: 'Screenwriting',
                              icon: Icons.theaters,
                              isSelected: _selectedCategory == 'Screenwriting',
                              onTap: () => _showConfirmationDialog('Screenwriting', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: CategoryCard(
                              title: 'Romance',
                              icon: Icons.favorite_border_outlined,
                              isSelected: _selectedCategory == 'Romance',
                              onTap: () => _showConfirmationDialog('Romance', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: CategoryCard(
                              title: 'Mystery',
                              icon: Icons.question_mark,
                              isSelected: _selectedCategory == 'Mystery',
                              onTap: () => _showConfirmationDialog('Mystery', _generatedPrompt!),
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                 CustomPromptForm(
                    onGenerate: _onCustomPromptGenerated,
                    isDarkMode: _isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void exitApp() async {
      // Implement app exit logic here (e.g., close connections, save data)
      Navigator.of(context).popUntil((route) => route.isFirst);
      SystemNavigator.pop(); // Explicitly pop app from system
  }

}


