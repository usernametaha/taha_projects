import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'about_screen.dart'; // Terms & Conditions ke liye

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  File? _imageFile;

  // Image picker function
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  // Signup API call - Original Logic Same
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar("Please agree to Terms & Conditions", Colors.orange);
      return;
    }

    if (_imageFile == null) {
      _showSnackBar("Please select a profile picture", Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://skcubetech.site/sport_api/signup.php')
      );

      // Add text fields
      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['phone'] = "03${_phoneController.text.trim()}";
      request.fields['password'] = _passwordController.text.trim();

      // Add image file
      var imageStream = http.ByteStream(_imageFile!.openRead());
      var imageLength = await _imageFile!.length();
      
      var multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: _imageFile!.path.split('/').last,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (jsonResponse['status'] == 'success') {
          // Save basic user info
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', _nameController.text.trim());
          await prefs.setString('userEmail', _emailController.text.trim());
          await prefs.setString('userPhone', _phoneController.text.trim());

          

          _showSnackBar("Signup Successful! Verify E-mail to login", Colors.green);
          
          // Navigate to login
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          String errorMsg = jsonResponse['message'] ?? "Signup failed";
          _showSnackBar(errorMsg, Colors.red);
        }
      } else {
        _showSnackBar("Registration Failed!", Colors.red);
      }
    } catch (e) {
      print("Signup Error: $e");
      if (!mounted) return;
      _showSnackBar("Network Error: Connection Timed Out", Colors.red);
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

  Widget _buildImageSelector() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _imageFile == null ? Colors.grey[100] : null,
              border: Border.all(color: const Color(0xFF00A99D), width: 3),
              image: _imageFile != null
                  ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        "Add Photo",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        if (_imageFile != null)
          TextButton.icon(
            onPressed: _removeImage,
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            label: const Text(
              "Remove Photo",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isPassword = false,
  bool showEyeIcon = false,
  bool isPhone = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword && !(showEyeIcon ? _isPasswordVisible : _isConfirmPasswordVisible),
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.black87, fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: const Color(0xFF00A99D)),
      prefixText: isPhone ? '03 ' : null, // CHANGE: +03 se +92 karein
      prefixStyle: const TextStyle(color: Color(0xFF00A99D), fontWeight: FontWeight.bold), // Color bhi change karein
      suffixIcon: showEyeIcon
          ? IconButton(
              icon: Icon(
                (isPassword ? _isPasswordVisible : _isConfirmPasswordVisible) 
                    ? Icons.visibility 
                    : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  if (isPassword) {
                    _isPasswordVisible = !_isPasswordVisible;
                  } else {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  }
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
                  // App Logo - Asset se load karein (Back Button REMOVED)
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: Image.asset(
                        'assets/designForapp.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A99D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.sports_score,
                              size: 60,
                              color: Color(0xFF00A99D),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 0),
                  
                  // Title
                  const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A99D),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  Center(
                    child: Text(
                      "Join UniSports Community",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                 // Profile Picture aur Full Name ek saath
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Profile Picture (Left side)
    Container(
      margin: const EdgeInsets.only(top: 5, right: 5),
      child: _buildImageSelector(),
    ),
    
    // Expanded Column for both fields
    Expanded(
      child: Column(
        children: [
          // Full Name Field with Container for height
          SizedBox(
            height: 55, // Fixed height
            child: _buildTextField(
              controller: _nameController,
              label: "Full Name",
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                  return 'Only alphabets allowed';
                }
                return null;
              },
            ),
          ),
          
          // AB AAP YAHAN SPACING CONTROL KAR SAKTE HAIN
          const SizedBox(height: 15), // Kam spacing
          // const SizedBox(height: 25), // Medium spacing  
          // const SizedBox(height: 35), // Zyada spacing
          
          // Email Field with Container for height
          SizedBox(
            height: 55, // Same height as Full Name
            child: _buildTextField(
              controller: _emailController,
              label: "Email Address",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ),
  ],
),
                  const SizedBox(height: 15),
                  
                  // Phone
                 

                  // Phone Field ko update karein
_buildTextField(
  controller: _phoneController,
  label: "Phone Number",
  icon: Icons.phone,
  isPhone: true,
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Enter phone number';
    }
    
    // Remove +92 prefix for validation
    String numbersOnly = value.replaceAll('+03', '');
    
    if (numbersOnly.length != 9) {
      return 'Enter 10 digits (3XX XXXXXXX)';
    }
    
    return null;
  },
),
                  
                  const SizedBox(height: 15),
                  
                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    isPassword: true,
                    showEyeIcon: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 8) {
                        return 'Min 8 characters required';
                      }
                      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
                        return 'Use Alphanumeric password';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00A99D)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms & Conditions Checkbox
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF00A99D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AboutScreen(
                                        fromSignup: true,
                                        onAgree: () {
                                          setState(() {
                                            _agreeToTerms = true;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "I agree to the ",
                                        style: TextStyle(color: Color.fromARGB(255, 95, 95, 95)),
                                      ),
                                      TextSpan(
                                        text: "Terms & Conditions",
                                        style: TextStyle(
                                          color: _agreeToTerms ? Colors.grey[700] : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Please read and agree to continue",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          if (!_agreeToTerms) {
                            _showSnackBar("Please agree to Terms & Conditions", Colors.red);
                            return;
                          }
                          registerUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agreeToTerms ? const Color(0xFF00A99D) : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: _agreeToTerms ? const Color(0xFF00A99D).withOpacity(0.3) : Colors.transparent,
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
                          : Text(
                              _agreeToTerms ? "REGISTER NOW" : "AGREE TERMS TO CONTINUE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _agreeToTerms ? Colors.white : Colors.grey[600],
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Login",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}