import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'team_registration.dart'; // Nayi file import karein

class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  State<SportListScreen> createState() => _SportListScreenState();
}

class _SportListScreenState extends State<SportListScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  _checkRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() { userRole = prefs.getString('role'); });
  }

  Future<List> _fetchSports() async {
    final response = await http.get(Uri.parse('https://skcubetech.site/sport_api/get_sports.php'));
    return json.decode(response.body);
  }

  Future<void> _deleteSport(String id) async {
    await http.post(
      Uri.parse('https://skcubetech.site/sport_api/delete_sport.php'),
      body: {'id': id},
    );
    setState(() {}); 
  }

  void _showSportDetails(Map sport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(sport['sport_name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A99D))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.location_on, "Venue", sport['venue']),
              _infoRow(Icons.category, "Category", sport['category'] ?? "General"),
              const Divider(),
              const Text("Rules & Regulations:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(sport['rules'] ?? "No rules specified for this sport yet.", style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? "N/A"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("University Sports List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A99D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: userRole == 'admin' 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF00A99D),
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () { /* Yahan Add Sport ka page open hoga */ },
          ) 
        : null,
      body: FutureBuilder<List>(
        future: _fetchSports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No sports found."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var sport = snapshot.data![index];
              
              // Team based sports ki list (Inhein Captain handle karega)
              bool isTeamSport = (sport['sport_name'] == 'Cricket' || 
                                 sport['sport_name'] == 'Football' || 
                                 sport['sport_name'] == 'Volleyball' ||
                                 sport['sport_name'] == 'Hockey' ||
                                 sport['sport_name'] == 'Basketball' ||
                                 sport['sport_name'] == 'Tug of War');

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00A99D).withOpacity(0.1),
                    child: const Icon(Icons.sports_basketball, color: Color(0xFF00A99D)),
                  ),
                  title: Text(sport['sport_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("Venue: ${sport['venue']}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      // Rules Button
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Color(0xFF00A99D)),
                        onPressed: () => _showSportDetails(sport),
                      ),

                      // Agar Team Sport hai to "Team Reg" button
                      if (isTeamSport && userRole != 'admin')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamRegistrationScreen(
                                  sportId: sport['id'].toString(),
                                  sportName: sport['sport_name'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: const StadiumBorder()),
                          child: const Text("Team Reg", style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),

                      // Delete/Edit Icons only for Admin
                      if (userRole == 'admin') ...[
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSport(sport['id'].toString())),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}