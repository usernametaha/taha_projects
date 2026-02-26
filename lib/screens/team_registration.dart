import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeamRegistrationScreen extends StatefulWidget {
  final String sportId, sportName;
  const TeamRegistrationScreen({super.key, required this.sportId, required this.sportName});

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final List<String> departments = ["CS", "IT", "BBA", "EE", "ME", "Psychology", "Fine Arts", "Commerce", "Maths", "Physics", "English", "Economics"];
  String? selectedDept;
  final TextEditingController teamNameController = TextEditingController();
  List<TextEditingController> playerControllers = [TextEditingController()]; 

  void _addPlayerField() {
    if (playerControllers.length < 11) { 
      setState(() => playerControllers.add(TextEditingController()));
    }
  }

  Future<void> _submitTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    List<String> playerRollNos = playerControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (selectedDept == null || teamNameController.text.isEmpty || playerRollNos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields!")));
      return;
    }

    // API Call
    final response = await http.post(
      Uri.parse('https://skcubetech.site/sport_api/register_team.php'),
      body: {
        'sport_id': widget.sportId,
        'captain_id': userId,
        'department': selectedDept,
        'team_name': teamNameController.text,
        'players': json.encode(playerRollNos),
      },
    );

    final data = json.decode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
    if (data['status'] == 'success') Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Team Register: ${widget.sportName}"), 
        backgroundColor: const Color(0xFF00A99D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: teamNameController,
              decoration: const InputDecoration(labelText: "Team Name (e.g. CS Tigers)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => selectedDept = val as String,
              decoration: const InputDecoration(labelText: "Select Your Department", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Add Players (Roll Numbers)", style: TextStyle(fontWeight: FontWeight.bold)),
            ...playerControllers.map((controller) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter Player Roll No")),
            )),
            TextButton.icon(onPressed: _addPlayerField, icon: const Icon(Icons.add, color: Color(0xFF00A99D)), label: const Text("Add More Players")),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D), padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _submitTeam,
                child: const Text("SUBMIT TEAM FOR APPROVAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}