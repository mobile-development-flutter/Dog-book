// screens/auth_screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 2), () {
      context.go('/onboard');
    }
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
  
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF38B6FF),
      body: SafeArea( 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.8, 
                  maxHeight: screenHeight * 0.5, 
                ),
                child: AspectRatio(
                  aspectRatio: 1, 
                  child: Image.asset(
                    'assets/logos/petplus_logo.jpg',
                    fit: BoxFit.contain, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
