import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink_wander/services/theme_provider.dart';
import 'package:ink_wander/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoard {
  final String image;
  final String title;
  final String description;

  OnBoard({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;
  Timer? _timer;

  final List<OnBoard> demoData = [
    OnBoard(
      image: "assets/images/onboarding1.jpeg",
      title: "Embark on a Journey of Words",
      description:
          "Welcome to Ink Wander, your daily muse for creative writing. Unleash your imagination with a variety of prompts, story ideas, and poetry themes designed to inspire and overcome writer’s block. Ready to explore? Let’s begin your adventure in ink.",
    ),
    OnBoard(
      image: "assets/images/onboarding2.jpeg",
      title: "Discover Daily Inspiration",
      description:
          "Every day brings a new prompt to spark your creativity. Whether you're into fiction, non-fiction, or poetry, start your writing journey with fresh and engaging topics that ignite your passion for words.",
    ),
    OnBoard(
      image: "assets/images/onboarding3.jpeg",
      title: "Craft Your Story",
      description:
          "Explore a plethora of story ideas and genres. From romance to mystery, fiction to non-fiction, Ink Wander offers a rich tapestry of themes to weave your narrative masterpiece.",
    ),
    OnBoard(
      image: "assets/images/onboarding4.jpeg",
      title: "Poetry at Your Fingertips",
      description:
          "Dabble in the art of poetry with a variety of themes and forms. Let Ink Wander be your guide through sonnets, haikus, free verse, and more. Express your emotions and thoughts in poetic harmony.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Automatic scroll behavior (change duration as needed)
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageIndex < demoData.length - 1) {
        _pageIndex++;
      } else {
        _pageIndex = 0;
      }
      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _goToSignIn() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final toggleTheme = Provider.of<ThemeProvider>(context).toggleTheme;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Adjust height if needed
        child: MyAppBar(
          isDarkMode: isDarkMode,
          onToggleDarkMode: toggleTheme,
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _pageIndex = page;
              });
            },
            itemCount: demoData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          15.0), // Adjust the radius for desired curvature
                      child: Image.asset(
                        demoData[index].image,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit
                            .cover, // Ensures the image covers the space, you can adjust this as needed
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      demoData[index].title,
                      style: GoogleFonts.lobster(
                        textStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      demoData[index].description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.slabo27px(
                        textStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 07, // Increase the bottom padding to give more space
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_pageIndex != 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      textStyle: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold), // Text color
                    ),
                    child: Text('Prev',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black)),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_pageIndex == demoData.length - 1) {
                      SharedPreferences.getInstance().then(
                          (prefs) => prefs.setBool('isFirstLaunch', false));
                      _goToSignIn();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Background color for 'Next'/'Finish'
                    textStyle: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold), // Text color
                  ),
                  child: Text(
                      _pageIndex == demoData.length - 1 ? 'Finish' : 'Next',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black)),
                ),
                if (_pageIndex != demoData.length - 1)
                  TextButton(
                    onPressed: _goToSignIn,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      textStyle: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold), // Text color for 'Skip'
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
