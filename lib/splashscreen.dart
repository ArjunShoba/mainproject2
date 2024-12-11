import 'package:flutter/material.dart';
import 'package:mainproject_2/homescreen.dart';  

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeIn();  
    _navigateToHomeScreen();  
  }

  
  void _fadeIn() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;  
      });
    });
  }


  void _navigateToHomeScreen() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),  
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, 
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,  
          duration: const Duration(seconds: 1),  
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
              const Icon(
                Icons.newspaper,  
                size: 100,
                color: Colors.white,  
              ),
              const SizedBox(height: 20),
              const Text(
                'NewsApp',  
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

