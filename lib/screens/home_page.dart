import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_wander/env/env.dart';
import 'package:ink_wander/res/custom_colors.dart';
import 'package:ink_wander/screens/text_display.dart';
// import 'package:ink_wander/services/app_lifecycle_reactor.dart';
import 'package:ink_wander/services/category_prompt.dart';
import 'package:ink_wander/services/favorites_firestore.dart';
import 'package:ink_wander/services/generated_custom_prompt.dart';
import 'package:ink_wander/services/home_prompt_generator.dart';
import 'package:ink_wander/services/theme_provider.dart';
import 'package:ink_wander/widgets/action_button.dart';
// import 'package:ink_wander/widgets/app_open_ad.dart';
// import 'package:ink_wander/widgets/banner_ad.dart';
import 'package:ink_wander/widgets/category_card.dart';
import 'package:ink_wander/widgets/custom_prompt_form.dart';
import 'package:ink_wander/widgets/loading_indic.dart';
import 'package:ink_wander/widgets/particle_bg.dart';
import 'package:ink_wander/widgets/prompt_disp.dart';
// import 'package:ink_wander/widgets/rewarded_ad.dart';
import 'package:ink_wander/widgets/user_info_popup.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _selectedCategory = '';
  String? _generatedPrompt = '';
  // ignore: unused_field
  bool _isRefreshing = false;
  bool _isLoading = false;

  final TextEditingController _promptController = TextEditingController();
  String _selectedGenre = 'Fiction';
  String? _imageUrl;
  // final _rewardedAdWidget = RewardedAdWidget();
  // late AppLifecycleReactor _appLifecycleReactor;

  void _showUserInfoPopup() {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode =
            Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
        return UserInfoPopup(
          user: FirebaseAuth.instance.currentUser!,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  void _showGeneratedPrompt() async {
    setState(() {
      _generatedPrompt = null; // Reset to null, but with a delay
    });
    await Future.delayed(
        const Duration(milliseconds: 200)); // Introduce a delay
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
      _selectedCategory = ''; // Reset category selection
      _promptController.text = ''; // Clear prompt text (optional)
      _selectedGenre = 'Fiction'; // Reset genre (optional)
      _imageUrl = null; // Reset image URL (optional)

      _isRefreshing = false; // Reset flag after refresh
    });
    _showGeneratedPrompt(); // Re-fetch prompt
  }

  void _onCategoryTap(String category, String prompt) async {
    // Show a circular progress indicator while generating the prompt
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing while loading
      builder: (BuildContext context) => const Center(
        child: LoadingIndicator(),
      ),
    );

    // Generate the prompt asynchronously
    final generatedPrompt =
        await CategoryPrompt.generatePrompt(category, prompt);

    // Dismiss the progress dialog after generation
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Close the dialog

    if (generatedPrompt != null) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) =>
              TextDisplay(prompt: generatedPrompt, category: _selectedCategory),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    setState(() {
      _selectedCategory = category;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          titleTextStyle: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: textColor),
          backgroundColor: backgroundColor,
          content: Text(
            'Are you sure you want to write based on the selected category: $category?',
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
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 17.0, color: textColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm
              },
              child: Text(
                'Write',
                style: TextStyle(fontSize: 17.0, color: textColor),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _onCategoryTap(category, prompt);
      }
    });
  }

  void _onCustomPromptGenerated(
      String prompt, String genre, int wordCount, String? imageUrl) async {
    final promptGenerator = CustomPromptGenerator(apiKey: Env.apiKey);
    final generatedPrompt = await promptGenerator.generateCustomPrompt(
        prompt, genre, wordCount, imageUrl);
    if (generatedPrompt != null) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) =>
              TextDisplay(prompt: generatedPrompt, category: genre),
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

  void _copyToClipboard(BuildContext context) async {
    if (_generatedPrompt != null) {
      await Clipboard.setData(ClipboardData(text: _generatedPrompt!));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _showGeneratedPrompt();
    // _rewardedAdWidget.initRewardedAd();
    // AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    // _appLifecycleReactor =
    //     AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    // _appLifecycleReactor.listenToAppStateChanges();
  }

  @override
  void dispose() {
    // _rewardedAdWidget.disposeRewardedAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;
    final toggleTheme = Provider.of<ThemeProvider>(context).toggleTheme;
    final Color backgroundColor =
        isDarkMode ? Colors.black87 : Colors.white; // Dynamic background color
    final Color textColor = isDarkMode
        ? Colors.white
        : Colors.black; // Dynamic text color for accessibility

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: backgroundColor,
            titleTextStyle: TextStyle(
                color: textColor, fontSize: 23, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: textColor, fontSize: 19),
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit Ink Wander?'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                onPressed: () => Navigator.pop(context, false), // Cancel exit
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                onPressed: () => Navigator.pop(context, true), // Confirm exit
                child: const Text(
                  'Yes',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          exitApp(); // Exit the app if confirmed
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          title: Text(
            'Ink Wander',
            style: TextStyle(
                color: textColor,
                fontFamily: 'Margarine'), // Use dynamic text color
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            color: textColor,
            onPressed: toggleTheme,
          ),
          actions: [
            IconButton(
              icon: _isLoading
                  ? const LoadingIndicator()
                  : const Icon(Icons.favorite),
              color: textColor,
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                final favoritesFirestore = FavoritesFirestore();
                await favoritesFirestore.showFavoritePromptsDialog(
                    context, isDarkMode);
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            IconButton(
              icon: const Icon(
                  Icons.person_2_rounded), // Replace with your desired icon
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
                  SizedBox(
                    height: 250, // Increased height for more visual impact
                    child: Stack(
                      children: [
                        // Animated background gradient
                        AnimatedContainer(
                          duration: const Duration(seconds: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDarkMode
                                  ? [
                                      const Color(0xFF1A237E),
                                      const Color(0xFF0D47A1),
                                    ]
                                  : [
                                      const Color(0xFF64B5F6),
                                      const Color(0xFF81C784),
                                    ],
                            ),
                          ),
                        ),
                        // Animated particles effect
                        Positioned.fill(
                          child: ParticleBackground(
                            baseColor: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        // Content
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _generatedPrompt == null
                                ? const LoadingIndicator()
                                : PromptDisplay(
                                    prompt: _generatedPrompt!,
                                    isDarkMode: isDarkMode),
                          ),
                        ),
                        // Action buttons
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ActionButton(
                                icon: Icons.refresh,
                                onPressed: _refreshData,
                                tooltip: 'Generate new prompt',
                              ),
                              ActionButton(
                                icon: Icons.content_copy,
                                onPressed: () => _copyToClipboard(context),
                                tooltip: 'Copy to clipboard',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  // Category Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CategoryCard(
                                title: 'Fiction',
                                icon: Icons.book,
                                isSelected: _selectedCategory == 'Fiction',
                                onTap: () => _showConfirmationDialog(
                                    'Fiction', _generatedPrompt!),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: CategoryCard(
                                title: 'Poetry',
                                icon: Icons.edit,
                                isSelected: _selectedCategory == 'Poetry',
                                onTap: () => _showConfirmationDialog(
                                    'Poetry', _generatedPrompt!),
                                isDarkMode: isDarkMode,
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
                                isSelected:
                                    _selectedCategory == 'Speechwriting',
                                onTap: () => _showConfirmationDialog(
                                    'Speechwriting', _generatedPrompt!),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: CategoryCard(
                                title: 'Playwriting',
                                icon: Icons.play_arrow,
                                isSelected: _selectedCategory == 'Playwriting',
                                onTap: () => _showConfirmationDialog(
                                    'Playwriting', _generatedPrompt!),
                                isDarkMode: isDarkMode,
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
                                onTap: () => _showConfirmationDialog(
                                    'Non-Fiction', _generatedPrompt!),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: CategoryCard(
                                title: 'Screenwriting',
                                icon: Icons.theaters,
                                isSelected:
                                    _selectedCategory == 'Screenwriting',
                                onTap: () => _showConfirmationDialog(
                                    'Screenwriting', _generatedPrompt!),
                                isDarkMode: isDarkMode,
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
                                onTap: () => _showConfirmationDialog(
                                    'Romance', _generatedPrompt!),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: CategoryCard(
                                title: 'Mystery',
                                icon: Icons.question_mark,
                                isSelected: _selectedCategory == 'Mystery',
                                onTap: () => _showConfirmationDialog(
                                    'Mystery', _generatedPrompt!),
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  // const MyBannerAdWidget(),
                  // const SizedBox(height: 10.0),
                  CustomPromptForm(
                    onGenerate: _onCustomPromptGenerated,
                    isDarkMode: isDarkMode,
                    promptController: _promptController,
                    selectedGenre: _selectedGenre,
                    imageUrl: _imageUrl,
                  ),
                  const SizedBox(height: 10.0),
                  // const MyBannerAdWidget(),
                  // const SizedBox(height: 10.0),
                  // ElevatedButton(
                  //   onPressed: () => _rewardedAdWidget.showRewardedAd(),
                  //   child: const Text('Sponsored Video'),
                  // ),
                  // const SizedBox(height: 10.0),
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
