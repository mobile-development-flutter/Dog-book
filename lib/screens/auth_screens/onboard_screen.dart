// screens/auth_screens/onboard_screen.dart

// screens/onboard_screen.dart
import 'package:dog_book/screens/auth_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardData = [
    {
      'image': 'assets/images/onboard_image1.jpg',
      'title': 'Welcome to the \nPet Plus',
      'description': 'Your Pet’s Health, Our Priority',
    },
    {
      'image': 'assets/images/onboard_image2.jpg',
      'title': 'Pet Care Made Simple',
      'description':
          'The world would be nicer if everyone had the ability to love as unconditionally as a dog',
    },
    {
      'image': 'assets/images/onboard_image3.jpg',
      'title': 'Join Our App!',
      'description':
          "Saving one pet won't change the world, but surely the world will change for that one pet.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Responsive PageView
          PageView.builder(
            controller: _pageController,
            itemCount: onboardData.length,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(onboardData[index]['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, // 5% of screen width
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.12), // 12% from top
                      Text(
                        onboardData[index]['title']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.08, // 7% of screen width
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.025), // 2.5% spacing
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1, // 10% padding
                        ),
                        child: Text(
                          onboardData[index]['description']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05, // 4% of screen width
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Responsive Page Indicator
          Positioned(
            bottom: screenHeight * 0.25, // 10% from bottom
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: onboardData.length,
                effect: WormEffect(
                  dotHeight: screenHeight * 0.008, // 1% of screen height
                  dotWidth: screenHeight * 0.03,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ),

          // Responsive Navigation Button
          Positioned(
            bottom: screenHeight * 0.05, // 5% from bottom
            right: screenWidth * 0.08, // 8% from right
            child: TextButton(
              onPressed: () {
                if (_currentPage < onboardData.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              child: Text(
                _currentPage == onboardData.length - 1 ? 'Get Started' : 'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045, // 4.5% of width
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
