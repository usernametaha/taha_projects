import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppliedSports extends StatefulWidget {
  const MyAppliedSports({super.key});

  @override
  State<MyAppliedSports> createState() => _MyAppliedSportsState();
}

class _MyAppliedSportsState extends State<MyAppliedSports> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Registrations", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: http.get(Uri.parse('https://skcubetech.site/sport_api/get_my_registrations.php?user_id=$userId')),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasData) {
                  List data = json.decode(snapshot.data!.body);
                  
                  if (data.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      String status = data[index]['status'];
                      
                      // UI Styles based on Status
                      Color statusColor;
                      IconData statusIcon;
                      if (status == 'selected') {
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle_outline;
                      } else if (status == 'Rejected') {
                        statusColor = Colors.red;
                        statusIcon = Icons.error_outline;
                      } else {
                        statusColor = Colors.orange;
                        statusIcon = Icons.pending_actions;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Left colored indicator
                                Container(width: 6, color: statusColor),
                                const SizedBox(width: 15),
                                // Main Content
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[index]['sport_name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        const SizedBox(height: 5),
                                        Text("Roll No: ${data[index]['roll_no'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                        Text("Semester: ${data[index]['semester'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_month, size: 14, color: Colors.grey[400]),
                                            const SizedBox(width: 5),
                                            Text(data[index]['applied_at'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Status Tag
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(statusIcon, color: statusColor, size: 28),
                                      const SizedBox(height: 5),
                                      Text(
                                        status,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                
                return const Center(child: Text("Unable to load data."));
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_rounded, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "No Active Registrations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          const Text("Go to Home to apply for latest sports events."),
        ],
      ),
    );
  }
}