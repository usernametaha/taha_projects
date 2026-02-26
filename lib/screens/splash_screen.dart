import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // 3 seconds ka delay taake Splash Screen ki animation nazar aaye
    await Future.delayed(const Duration(seconds: 3));
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? role = prefs.getString('role');

    if (!mounted) return;

    if (isLoggedIn) {
      if (role == 'admin') {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const AdminDashboard())
        );
      } else {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      }
    } else {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background white kardia hai
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pehli Image (Main Logo)
            Image.asset(
              'assets/logobgnuco.jpg', // Apni pehli image ka path yahan rakhein
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 20),
            
            // Doosri Image (Sports Logo)
            Image.asset(
              'assets/designForapp.jpg', // Apni doosri image ka path yahan rakhein
              height: 130,
              width: 250,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 30),
            
            // Text with updated styling
            const Text(
              "UniSports",
              style: TextStyle(
                color: Color(0xFF00A99D), // #00A99D color ka use text ke liye
                fontSize: 35, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'Roboto', // Aap apni marzi ki font use kar sakte hain
              ),
            ),
            
            const SizedBox(height: 40),
            
            

            // Option 2: Circle Loader
            const SpinKitCircle(
              color: Color(0xFF00A99D),
              size: 50.0,
            ),
            
            // Option 3: Double Bounce Loader
            // SpinKitDoubleBounce(
            //   color: Color(0xFF00A99D),
            //   size: 50.0,
            // ),
            
          ],
        ),
      ),
    );
  }
}