import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/screens/text_display.dart';
import 'package:ink_wander/services/category_prompt.dart';
import 'package:ink_wander/services/favorites_firestore.dart';
import 'package:ink_wander/services/home_prompt_generator.dart';
import 'package:ink_wander/widgets/category_card.dart';
import 'package:ink_wander/widgets/user_info_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isDarkMode = true;
  String _selectedCategory = 'All';
  String? _generatedPrompt = '';
  // ignore: unused_field
  bool _isRefreshing = false;

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
    final String? prompt = await HomePromptGenerator.generatePrompt();
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
          builder: (context) => TextDisplay(prompt: generatedPrompt, category: _selectedCategory),
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
          style: TextStyle(color: textColor), // Use dynamic text color
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
            icon: const Icon(Icons.favorite), // Replace with your desired icon
            color: textColor,
            onPressed: () async {
              final favoritesFirestore = FavoritesFirestore();
              favoritesFirestore.showFavoritePromptsDialog(context);
            } 
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/hero_background.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Semi-transparent overlay
                      Container(
                        color: _isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.5), // Adjust opacity as needed
                      ),
                      Center(
                        child: _generatedPrompt == null
                            ? CircularProgressIndicator(color: textColor) // Show progress indicator
                            : Text(
                                _generatedPrompt!,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(height: 20),
          
                  // Category Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        CategoryCard(
                          title: 'Fiction',
                          icon: Icons.book,
                          isSelected: _selectedCategory == 'Fiction',
                          onTap: () => _onCategoryTap('Fiction', _generatedPrompt!),
                          isDarkMode: _isDarkMode,
                        ),
                        CategoryCard(
                          title: 'Poetry',
                          icon: Icons.edit,
                          isSelected: _selectedCategory == 'Poetry',
                          onTap: () => _onCategoryTap('Poetry', _generatedPrompt!),
                          isDarkMode: _isDarkMode,
                        ),
                        CategoryCard(
                          title: 'Non-Fiction',
                          icon: Icons.newspaper,
                          isSelected: _selectedCategory == 'Non-Fiction',
                          onTap: () => _onCategoryTap('Non-Fiction', _generatedPrompt!),
                          isDarkMode: _isDarkMode,
                        ), // Add more category cards as needed
                        CategoryCard(
                          title: 'Speechwriting',
                          icon: Icons.speaker,
                          isSelected: _selectedCategory == 'Speechwriting',
                          onTap: () => _onCategoryTap('Speechwriting', _generatedPrompt!),
                          isDarkMode: _isDarkMode,
                        ),
                        CategoryCard(
                          title: 'Playwriting',
                          icon: Icons.play_arrow,
                          isSelected: _selectedCategory == 'Playwriting',
                          onTap: () => _onCategoryTap('Playwriting', _generatedPrompt!),
                          isDarkMode: _isDarkMode,
                        ),
                        CategoryCard(
                          title: 'Screenwriting',
                          icon: Icons.theaters,
                          isSelected: _selectedCategory == 'Screenwriting',
                          onTap: () => _onCategoryTap('Screenwriting', _generatedPrompt!),
                          isDarkMode: _isDarkMode,
                        ),
                      ],
                    ),
                  ),   
                  // Featured Prompts List
                  // FeaturedPromptsList(
                  //   prompts: prompts,
                  //   onFavoriteToggle: toggleFavorite,
                  //   isDarkMode: _isDarkMode, // Pass the callback function
                  // ),
          
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


