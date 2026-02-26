import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // Platform detection ke liye
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Messaging import
import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      print("🔥 Initializing Firebase Messaging in Login Screen...");
      
      // Request notification permission
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      print('🔥 Notification Permission Status: ${settings.authorizationStatus}');
      
      // Get token (will be used after successful login)
      String? token = await messaging.getToken();
      print("🔥 Initial FCM Token in Login: $token");
      
      // Save token temporarily for later use
      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_fcm_token', token);
        print("✅ FCM Token saved temporarily");
      }
      
    } catch (e) {
      print("🔥 Firebase Messaging Initialization Error: $e");
    }
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool('rememberMe') ?? false;
    if (remember && mounted) {
      setState(() {
        _rememberMe = remember;
        _loginController.text = prefs.getString('savedLogin') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      });
    }
  }

  // Function to update FCM token on server after successful login
  Future<void> _updateFCMTokenOnServer(String userId) async {
    try {
      print("🔄 Updating FCM Token for user: $userId");
      
      // Get FCM token from Firebase
      String? token = await FirebaseMessaging.instance.getToken();
      
      if (token == null) {
        print("❌ No FCM token available");
        return;
      }
      
      print("📡 Sending FCM token to server: ${token.substring(0, 30)}...");
      
      // Send token to server
      final response = await http.post(
        Uri.parse('https://skcubetech.site/sport_api/update_token.php'),
        body: {
          'user_id': userId,
          'fcm_token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      
      print("📡 Token Update Response Status: ${response.statusCode}");
      print("📡 Token Update Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            print("✅ FCM Token updated successfully on server!");
            
            // Also save token locally
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('fcm_token', token);
            print("✅ FCM Token saved locally");
          } else {
            print("❌ Server error while updating token: ${data['message']}");
          }
        } catch (e) {
          print("❌ JSON Parse Error in token update: $e");
        }
      } else {
        print("❌ HTTP Error in token update: ${response.statusCode}");
      }
    } catch (e) {
      print("🔥 Error updating FCM token: $e");
    }
  }

  // Updated Login Logic with FCM Token Update
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Save remember me preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedLogin', _loginController.text.trim());
      await prefs.setString('savedPassword', _passwordController.text.trim());
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('savedLogin');
      await prefs.remove('savedPassword');
    }

    final url = Uri.parse('https://skcubetech.site/sport_api/login.php');

    try {
      final response = await http.post(
        url,
        body: {
          "identifier": _loginController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['user'] != null) {
          print('✅ Login successful!');
          
          // Save user data
          final userData = data['user'];
          final userId = userData['id']?.toString() ?? '';
          final userName = userData['name']?.toString() ?? "User";
          final userEmail = userData['email']?.toString() ?? "";
          final userPhone = userData['phone']?.toString() ?? "";
          final userImage = userData['image']?.toString() ?? "";
          final userRole = data['role']?.toString() ?? 'user';

          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('role', userRole);
          await prefs.setString('userId', userId);
          await prefs.setString('userName', userName);
          await prefs.setString('userEmail', userEmail);
          await prefs.setString('userPhone', userPhone);
          await prefs.setString('userImage', userImage);
          await prefs.setString('my_id', userId);
          await prefs.setString('user_id', userId);
          await prefs.setString('original_user_id', userId);

          await prefs.reload();

          // UPDATE FCM TOKEN ON SERVER AFTER SUCCESSFUL LOGIN
          await _updateFCMTokenOnServer(userId);

          _showSnackBar("Login Successful!", Colors.green);
          
          await Future.delayed(const Duration(milliseconds: 800));
          if (!mounted) return;
          
          if (userRole == 'admin') {
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
          String errorMsg = data['message'] ?? "Invalid login credentials";
          _showSnackBar(errorMsg, Colors.orangeAccent);
        }
      } else {
        _showSnackBar("Login failed. Please try again.", Colors.redAccent);
      }
    } catch (e) {
      print('Network Error: $e');
      _showSnackBar("Network error. Please check your internet connection.", Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          message,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool showEyeIcon = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: const Color(0xFF00A99D)),
        suffixIcon: showEyeIcon
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00A99D), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // University Logo
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: Image.asset(
                        'assets/logobgnuco.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A99D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.school,
                              size: 60,
                              color: Color(0xFF00A99D),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // App Title
                  const Center(
                    child: Text(
                      "UniSports",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A99D),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Center(
                    child: Text(
                      "University Sports Portal",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login Title
                  const Text(
                    "Login to your account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A99D),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Email/Phone/Username Field
                  _buildTextField(
                    controller: _loginController,
                    label: "Email, Phone or Username",
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter email or phone";
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field with Eye Icon
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    isPassword: true,
                    showEyeIcon: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter password";
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF00A99D),
                      ),
                      const Text(
                        "Remember Me",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Forgot Password functionality
                          _showSnackBar("Forgot Password feature coming soon!", Colors.blue);
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF00A99D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A99D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF00A99D).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "LOGIN NOW",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF00A99D),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Debug Info (Optional - Remove in production)
                  const SizedBox(height: 20),
                  if (_isLoading)
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Setting up notifications...",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "FCM Token will be saved after login",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}