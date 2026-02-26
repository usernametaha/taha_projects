import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allRegistrations = [];
  List<dynamic> _filteredRegistrations = [];
  bool _isLoading = true;
  String _selectedSport = 'All Sports';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse('https://skcubetech.site/sport_api/get_all_registrations.php'));
      if (response.statusCode == 200) {
        setState(() {
          _allRegistrations = json.decode(response.body);
          _filteredRegistrations = List.from(_allRegistrations);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error loading registrations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRegistrations() {
    List<dynamic> filtered = List.from(_allRegistrations);

    // Sport ke filter
    if (_selectedSport != 'All Sports') {
      filtered = filtered.where((reg) => reg['sport_name'] == _selectedSport).toList();
    }

    // Status ke filter
    if (_selectedStatus != 'All') {
      filtered = filtered.where((reg) => reg['status'] == _selectedStatus).toList();
    }

    setState(() {
      _filteredRegistrations = filtered;
    });
  }

  List<String> _getAllSports() {
    Set<String> sports = {'All Sports'};
    for (var reg in _allRegistrations) {
      if (reg['sport_name'] != null) {
        sports.add(reg['sport_name']);
      }
    }
    return sports.toList();
  }

  Future<void> _updateStatus(String regId, String status) async {
    try {
      // Convert 'Approved' to 'selected' for PHP
      String phpStatus = status;
      if (status == 'Approved') {
        phpStatus = 'selected';
      }
      // 'Rejected' remains 'rejected'
      
      final response = await http.post(
        Uri.parse('https://skcubetech.site/sport_api/update_status.php'),
        body: {'registration_id': regId, 'status': phpStatus},
      );
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        // Update local data with original status ('Approved'/'Rejected')
        int index = _allRegistrations.indexWhere((reg) => reg['id'].toString() == regId);
        if (index != -1) {
          setState(() {
            _allRegistrations[index]['status'] = status;
          });
          _filterRegistrations();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Application $status successfully!"),
            backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          )
        );
        
        // Check if notification was sent
        if (data['notification_sent'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("📱 Notification sent to user!"),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            )
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${data['message']}"),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update status. Check internet connection."), 
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        )
      );
    }
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A99D),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white), 
            onPressed: _loadRegistrations,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt, color: Colors.white), text: "All"),
            Tab(icon: Icon(Icons.pending_actions, color: Colors.white), text: "Pending"),
            Tab(icon: Icon(Icons.analytics, color: Colors.white), text: "Stats"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSport,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Sport',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _getAllSports().map((sport) {
                      return DropdownMenuItem(
                        value: sport,
                        child: Text(
                          sport,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSport = value!;
                      });
                      _filterRegistrations();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Status')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                      DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                    ].toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                      _filterRegistrations();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Results: ${_filteredRegistrations.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (_selectedSport != 'All Sports' || _selectedStatus != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSport = 'All Sports';
                        _selectedStatus = 'All';
                      });
                      _filterRegistrations();
                    },
                    child: const Text('Clear Filters', style: TextStyle(color: Color(0xFF00A99D))),
                  ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: All Applications
                _buildApplicationsList(_filteredRegistrations),
                
                // Tab 2: Pending Applications
                _buildApplicationsList(
                  _filteredRegistrations.where((reg) => reg['status'] == 'Pending').toList()
                ),
                
                // Tab 3: Statistics
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List registrations) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00A99D)),
            SizedBox(height: 15),
            Text('Loading applications...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 15),
            const Text(
              'No applications found',
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            const Text(
              'Try changing filters or check back later',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: registrations.length,
      itemBuilder: (context, index) {
        var reg = registrations[index];
        Color statusColor;
        IconData statusIcon;
        String displayStatus = reg['status'] ?? 'Pending';
        
        switch (displayStatus) {
          case 'Approved':
          case 'selected':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            displayStatus = 'Approved';
            break;
          case 'Rejected':
          case 'rejected':
            statusColor = Colors.red;
            statusIcon = Icons.cancel;
            displayStatus = 'Rejected';
            break;
          default:
            statusColor = Colors.orange;
            statusIcon = Icons.pending;
            displayStatus = 'Pending';
        }

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              reg['name'] ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reg['sport_name'] ?? 'No Sport',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        displayStatus,
                        style: TextStyle(
                          color: statusColor, 
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.expand_more,
              color: Colors.grey[600],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    _detailRow(Icons.numbers, "Registration ID", reg['id'].toString()),
                    _detailRow(Icons.sports, "Sport", reg['sport_name']),
                    _detailRow(Icons.person, "Full Name", reg['name']),
                    _detailRow(Icons.numbers, "Roll No", reg['roll_no']),
                    _detailRow(Icons.school, "Semester", reg['semester']),
                    _detailRow(Icons.access_time, "Shift", reg['shift']),
                    _detailRow(Icons.phone, "WhatsApp", reg['whatsapp']),
                    _detailRow(Icons.email, "Email", reg['email']),
                    _detailRow(Icons.calendar_today, "Applied Date", reg['applied_date']),
                    
                    const SizedBox(height: 20),
                    
                    if (displayStatus == 'Pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 2,
                            ),
                            onPressed: () => _updateStatus(reg['id'].toString(), 'Approved'),
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text("APPROVE", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 2,
                            ),
                            onPressed: () => _updateStatus(reg['id'].toString(), 'Rejected'),
                            icon: const Icon(Icons.close, size: 20),
                            label: const Text("REJECT", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Application already $displayStatus',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00A99D)));
    }

    // Calculate statistics
    int total = _allRegistrations.length;
    int pending = _allRegistrations.where((reg) => reg['status'] == 'Pending').length;
    int approved = _allRegistrations.where((reg) => reg['status'] == 'Approved' || reg['status'] == 'selected').length;
    int rejected = _allRegistrations.where((reg) => reg['status'] == 'Rejected' || reg['status'] == 'rejected').length;

    // Sports wise statistics
    Map<String, int> sportsCount = {};
    for (var reg in _allRegistrations) {
      String sport = reg['sport_name'] ?? 'Unknown';
      sportsCount[sport] = (sportsCount[sport] ?? 0) + 1;
    }

    // Sort sports by count
    var sortedSports = sportsCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Registration Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
          ),
          const SizedBox(height: 5),
          Text(
            'Total Applications: $total',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          // Overall Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard('Total', total.toString(), Icons.bar_chart, Colors.blue, Icons.groups),
              _buildStatCard('Pending', pending.toString(), Icons.pending, Colors.orange, Icons.hourglass_empty),
              _buildStatCard('Approved', approved.toString(), Icons.check_circle, Colors.green, Icons.verified),
              _buildStatCard('Rejected', rejected.toString(), Icons.cancel, Colors.red, Icons.block),
            ],
          ),
          
          const SizedBox(height: 25),
          const Text(
            '🏆 Sports-wise Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Sports Distribution
          ...sortedSports.map((entry) {
            double percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              child: ListTile(
                leading: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A99D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports, color: Color(0xFF00A99D)),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF00A99D),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '(${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loadRegistrations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A99D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Export feature will be available soon'),
                              duration: Duration(seconds: 2),
                            )
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        icon: const Icon(Icons.download, color: Colors.blue),
                        label: const Text('Export', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Note: When you approve/reject applications, users will receive push notifications.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, IconData mainIcon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(mainIcon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.grey[600], 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not provided',
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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