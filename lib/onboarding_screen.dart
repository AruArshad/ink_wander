import 'dart:async';
import 'package:flutter/material.dart';

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
          "Welcome to InkWander, your daily muse for creative writing. Unleash your imagination with a variety of prompts, story ideas, and poetry themes designed to inspire and overcome writer’s block. Ready to explore? Let’s begin your adventure in ink.",
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
          "Explore a plethora of story ideas and genres. From romance to mystery, historical to sci-fi, InkWander offers a rich tapestry of themes to weave your narrative masterpiece.",
    ),
    OnBoard(
      image: "assets/images/onboarding4.jpeg",
      title: "Poetry at Your Fingertips",
      description:
          "Dabble in the art of poetry with a variety of themes and forms. Let InkWander be your guide through sonnets, haikus, free verse, and more. Express your emotions and thoughts in poetic harmony.",
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
    Navigator.pushReplacementNamed(context, '/signin');
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
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
                          borderRadius: BorderRadius.circular(15.0), // Adjust the radius for desired curvature
                          child: Image.asset(
                            demoData[index].image,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover, // Ensures the image covers the space, you can adjust this as needed
                          ),
                        ),
                  const SizedBox(height: 20),
                  Text(
                    demoData[index].title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    demoData[index].description,
                    textAlign: TextAlign.center,
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
                    textStyle: const TextStyle(color: Colors.white), // Text color
                  ),
                  child: const Text('Prev'),
                ),
              ElevatedButton(
                onPressed: () {
                  if (_pageIndex == demoData.length - 1) {
                    _goToSignIn();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color for 'Next'/'Finish'
                  textStyle: const TextStyle(color: Colors.white), // Text color
                ),
                child: Text(_pageIndex == demoData.length - 1 ? 'Finish' : 'Next'),
              ),
              if (_pageIndex != demoData.length - 1)
                TextButton(
                  onPressed: _goToSignIn,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(color: Colors.red), // Text color for 'Skip'
                  ),
                  child: const Text('Skip'),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

