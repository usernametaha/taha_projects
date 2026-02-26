import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("About UniSports", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A99D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo ya Icon
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF00A99D),
              child: Icon(Icons.sports_rounded, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "UniSports Management System",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            // App Description
            const Text(
              "UniSports aik professional university sports management portal hai jo students aur admins ke darmiyan registration ke process ko digitalize karta hai.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),

            // Facilities Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Key Facilities:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),

            _buildFacilityCard(Icons.category, "Categorized Sports", "Outdoor aur Indoor sports ki alag alag management."),
            _buildFacilityCard(Icons.app_registration, "Easy Registration", "Roll No aur Semester ke sath foran apply karne ki saholat."),
            _buildFacilityCard(Icons.notifications_active, "Real-time Notifications", "Admin approval ya rejection ka foran notification."),
            _buildFacilityCard(Icons.person_search, "Role Based Access", "Students aur Admins ke liye alag alag interfaces."),
            _buildFacilityCard(Icons.history, "Application Tracking", "Apni tamam applied sports ka status live check karein."),

            const SizedBox(height: 40),
            const Divider(),
            const Text("Developed for University Sports Gala 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(IconData icon, String title, String desc) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00A99D), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}