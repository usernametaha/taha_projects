import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final bool fromSignup;
  final VoidCallback? onAgree;

  const AboutScreen({
    super.key,
    this.fromSignup = false,
    this.onAgree,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          fromSignup ? "Terms & Conditions" : "About UniSports",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00A99D),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: fromSignup
            ? [
                TextButton(
                  onPressed: onAgree,
                  child: const Text(
                    "I AGREE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF00A99D).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.sports_score,
                size: 50,
                color: Color(0xFF00A99D),
              ),
            ),
            
            const Text(
              "UniSports Management System",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A99D),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 5),
            
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 30),
            
            if (fromSignup) ...[
              // Terms & Conditions Content
              _buildSectionTitle("Terms & Conditions"),
              const SizedBox(height: 15),
              
              _buildTermItem(
                "1. Eligibility",
                "You must be a registered student of the university with a valid roll number to use this platform.",
              ),
              
              _buildTermItem(
                "2. Account Responsibility",
                "You are responsible for maintaining the confidentiality of your account and password.",
              ),
              
              _buildTermItem(
                "3. Sports Selection",
                "Students can register for maximum 2 sports categories. Final selection is subject to admin approval.",
              ),
              
              _buildTermItem(
                "4. Code of Conduct",
                "All participants must maintain sportsman spirit and follow university rules during events.",
              ),
              
              _buildTermItem(
                "5. Data Privacy",
                "Your personal information will be used only for sports management purposes.",
              ),
              
              _buildTermItem(
                "6. Cancellation Policy",
                "Once registered, cancellation requests must be submitted at least 48 hours before the event.",
              ),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "⚠️ Important Note:",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "By creating an account, you agree to abide by all university sports policies and rules. Violation may lead to account suspension.",
                      style: TextStyle(color: Color.fromARGB(255, 214, 47, 47)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // I Agree Button (for signup flow)
              if (fromSignup && onAgree != null)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onAgree,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A99D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "I AGREE TO TERMS & CONDITIONS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ] else ...[
              // Original About Content (without Card UI)
              _buildSectionTitle("About UniSports"),
              const SizedBox(height: 15),
              
              const Text(
                "UniSports is a professional university sports management portal that digitalizes the registration process between students and admins for various sports activities and events.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              
              const SizedBox(height: 30),
              
              _buildSectionTitle("Key Features"),
              const SizedBox(height: 15),
              
              _buildFeatureItem(Icons.category, "Categorized Sports", "Separate management for Outdoor and Indoor sports activities."),
              _buildFeatureItem(Icons.app_registration, "Easy Registration", "Instant apply with Roll No and Semester details."),
              _buildFeatureItem(Icons.notifications_active, "Real-time Notifications", "Immediate notification for admin approval or rejection."),
              _buildFeatureItem(Icons.person_search, "Role Based Access", "Different interfaces for Students and Admins."),
              _buildFeatureItem(Icons.history, "Application Tracking", "Live status check for all applied sports."),
              _buildFeatureItem(Icons.security, "Secure Platform", "Protected user data with secure authentication."),
            ],
            
            const SizedBox(height: 40),
            
            const Divider(),
            
            const SizedBox(height: 10),
            
            const Text(
              "© 2024 University Sports Management System",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 5),
            
            const Text(
              "Developed for University Sports Gala 2026",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00A99D),
        ),
      ),
    );
  }

  Widget _buildTermItem(String number, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 12),
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF00A99D),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00A99D), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 92, 92, 92),
                    fontSize: 14,
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