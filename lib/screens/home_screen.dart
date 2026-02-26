import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Platform detection ke liye
import 'package:image_picker/image_picker.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'login_screen.dart';
import 'my_applied_sports.dart';
import 'about.dart'; 
import 'sport_list.dart'; 
import 'outdoor_sports_screen.dart';
import 'indoor_sports_screen.dart';
import 'winners_screen.dart';
import 'university_rules_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName, userEmail, userImage, userId;
  int _currentIndex = 0; // Bottom Navigation Index
  int _bannerIndex = 0; // Banner Indicator Index
  bool _isUpdating = false; 
  bool _isLoadingSports = false; // Sports loading state
  
  // Cache sports data
  List<dynamic> _sportsCache = [];
  DateTime? _lastSportsFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // 5 minutes cache
  
  // 6 Banners List
  final List<String> bannerList = [
    'https://skcubetech.site/sport_api/uploads/banner1.jpg',
    'https://skcubetech.site/sport_api/uploads/banner2.jpg',
    'https://skcubetech.site/sport_api/uploads/banner3.jpg',
    'https://skcubetech.site/sport_api/uploads/banner4.jpg',
    'https://skcubetech.site/sport_api/uploads/banner5.jpg',
    'https://skcubetech.site/sport_api/uploads/banner6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    print("🔄 HomeScreen initState called");
    _loadUserData();
    _initializeFirebase(); // Firebase initialization
    _loadSportsData();
  }

  // Firebase Messaging Initialization
  _initializeFirebase() async {
    print("🔥 Initializing Firebase Messaging...");
    
    try {
      // Request permission
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      print('🔥 Notification Permission: ${settings.authorizationStatus}');
      
      // Get initial token
      String? initialToken = await messaging.getToken();
      print("🔥 Initial FCM Token: $initialToken");
      
      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        print("🔄 FCM Token Refreshed: $newToken");
        if (userId != null) {
          _updateFCMTokenWithToken(newToken);
        }
      });
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔥 Foreground Message Received!');
        print('🔥 Message Title: ${message.notification?.title}');
        print('🔥 Message Body: ${message.notification?.body}');
        print('🔥 Message Data: ${message.data}');
        
        // Show local notification
        _showLocalNotification(message);
      });
      
      // Handle when app is opened from terminated state
      RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        print('🔥 App opened from terminated state with message');
        _handleNotificationClick(initialMessage);
      }
      
      // Handle when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
      
    } catch (e) {
      print("🔥 Firebase Initialization Error: $e");
    }
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Student";
      userEmail = prefs.getString('userEmail') ?? "No Email";
      userImage = prefs.getString('userImage'); 
      userId = prefs.getString('userId');
      
      // Debug prints
      print("👤 User Data Loaded:");
      print("   Name: $userName");
      print("   Email: $userEmail");
      print("   ID: $userId");
      print("   Image: $userImage");
    });
    
    // FCM Token update karein
    if (userId != null) {
      print("🔄 Calling _updateFCMToken for user: $userId");
      _updateFCMToken();
    } else {
      print("❌ User ID is null - cannot update FCM token");
    }
  }

  // Enhanced FCM Token Update Function
  _updateFCMToken() async {
    try {
      print("🔥 FCM Token Update Started...");
      
      // Wait for Firebase to initialize
      await Future.delayed(const Duration(seconds: 1));
      
      // Get FCM Token
      String? token = await FirebaseMessaging.instance.getToken();
      print("🔥 Generated FCM Token: $token");
      
      if (token != null && userId != null) {
        print("📡 Sending token to server for user: $userId");
        
        // Send to server
        final response = await http.post(
          Uri.parse('https://skcubetech.site/sport_api/update_token.php'),
          body: {
            'user_id': userId!, 
            'fcm_token': token,
            'device_type': Platform.isAndroid ? 'android' : 'ios',
          },
        );
        
        print("📡 Server Response Status: ${response.statusCode}");
        print("📡 Server Response Body: ${response.body}");
        
        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            if (data['status'] == 'success') {
              print("✅ FCM Token saved successfully!");
              
              // Also save locally for backup
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('fcm_token', token);
              print("✅ Token saved locally too");
            } else {
              print("❌ Server error: ${data['message']}");
            }
          } catch (e) {
            print("❌ JSON Parse Error: $e");
          }
        } else {
          print("❌ HTTP Error: ${response.statusCode}");
        }
      } else {
        print("❌ No token or user ID available");
        print("Token: $token");
        print("User ID: $userId");
        
        // Try again after 5 seconds if token is null
        if (token == null) {
          print("🔄 Will retry FCM token generation in 5 seconds...");
          Future.delayed(const Duration(seconds: 5), () {
            _updateFCMToken();
          });
        }
      }
    } catch (e) {
      print("🔥 Error in _updateFCMToken: $e");
      
      // Retry after error
      print("🔄 Retrying FCM token update in 10 seconds...");
      Future.delayed(const Duration(seconds: 10), () {
        _updateFCMToken();
      });
    }
  }

  // Helper function for token refresh
  _updateFCMTokenWithToken(String token) async {
    if (userId != null) {
      await http.post(
        Uri.parse('https://skcubetech.site/sport_api/update_token.php'),
        body: {'user_id': userId!, 'fcm_token': token},
      );
      print("✅ Refreshed token saved to server");
    }
  }

  // Local notification show karein
  _showLocalNotification(RemoteMessage message) {
    if (message.notification != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message.notification!.title ?? 'Notification'),
          content: Text(message.notification!.body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Notification click handle karein
  _handleNotificationClick(RemoteMessage message) {
    print('🔥 Notification Clicked!');
    
    // Navigate to appropriate screen based on data
    if (message.data['type'] == 'status_update' && mounted) {
      // My Applied Sports screen par navigate karein
      setState(() {
        _currentIndex = 2; // My Applied tab
      });
    }
  }

  // Load sports data with caching
  Future<void> _loadSportsData() async {
    // Check if cache is still valid
    if (_lastSportsFetchTime != null && 
        DateTime.now().difference(_lastSportsFetchTime!) < _cacheDuration &&
        _sportsCache.isNotEmpty) {
      return; // Use cached data
    }
    
    setState(() {
      _isLoadingSports = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://skcubetech.site/sport_api/get_sports.php'),
        headers: {
          'Cache-Control': 'no-cache',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _sportsCache = data;
          _lastSportsFetchTime = DateTime.now();
          _isLoadingSports = false;
        });
      } else {
        setState(() {
          _isLoadingSports = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading sports: $e");
      setState(() {
        _isLoadingSports = false;
      });
    }
  }
  
  // Function to manually refresh sports data
  Future<void> _refreshSportsData() async {
    await _loadSportsData();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() => _isUpdating = true);
      try {
        var request = http.MultipartRequest('POST', Uri.parse('https://skcubetech.site/sport_api/update_profile.php'));
        request.fields['user_id'] = userId!;
        request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        if (data['status'] == 'success') {
          String newImagePath = data['image_path'] ?? userImage; 
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userImage', newImagePath);
          
          setState(() {
            userImage = newImagePath;
            _isUpdating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Image Updated!")));
        }
      } catch (e) {
        setState(() => _isUpdating = false);
        debugPrint("Upload Error: $e");
      }
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (passController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be 6 characters!")));
                return;
              }
              await http.post(
                Uri.parse('https://skcubetech.site/sport_api/update_profile.php'),
                body: {'user_id': userId, 'password': passController.text},
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated successfully!")));
            }, 
            child: const Text("Update")
          ),
        ],
      ),
    );
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openRegistrationForm(String sportId, String sportName) {
    final TextEditingController rollController = TextEditingController();
    final TextEditingController semesterController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String selectedShift = 'Morning';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              Text("Register for $sportName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00A99D))),
              const SizedBox(height: 20),
              _buildFormFields(rollController, "Roll Number", Icons.badge),
              const SizedBox(height: 15),
              _buildFormFields(semesterController, "Semester (e.g. 3rd)", Icons.school),
              const SizedBox(height: 15),
              _buildFormFields(phoneController, "WhatsApp Phone No", Icons.phone, inputType: TextInputType.phone),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                initialValue: selectedShift,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), labelText: "Shift", prefixIcon: const Icon(Icons.access_time)),
                items: ['Morning', 'Evening'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => selectedShift = val.toString(),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _submitForm(sportId, rollController.text, semesterController.text, phoneController.text, selectedShift),
                  child: const Text("SUBMIT APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: Icon(icon)),
    );
  }

  Future<void> _submitForm(String sId, String roll, String sem, String ph, String shift) async {
    if (roll.isEmpty || sem.isEmpty || ph.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    final response = await http.post(Uri.parse('https://skcubetech.site/sport_api/apply_sport.php'),
        body: {'user_id': userId, 'sport_id': sId, 'roll_no': roll, 'semester': sem, 'phone': ph, 'shift': shift});
    final data = json.decode(response.body);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              setState(() { userName = nameController.text; });
              await http.post(
                Uri.parse('https://skcubetech.site/sport_api/update_profile.php'),
                body: {'user_id': userId, 'name': nameController.text},
              );
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', nameController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
            }, 
            child: const Text("Save")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A99D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            // Logo in AppBar
            Image.asset(
              'assets/new1.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text("UniSports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          // Sirf logout icon rahega, notification aur refresh remove kar diye
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _currentIndex == 0 
          ? _buildHomeBody() 
          : (_currentIndex == 1 
              ? const SportListScreen() 
              : (_currentIndex == 2 ? const MyAppliedSports() : _buildProfile())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00A99D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Sports List"), 
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "My Applied"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _refreshSportsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            
            // 6 BANNERS SLIDER
            CarouselSlider(
              options: CarouselOptions(
                height: 160, 
                autoPlay: true, 
                enlargeCenterPage: true, 
                viewportFraction: 0.9,
                onPageChanged: (index, reason) {
                  setState(() {
                    _bannerIndex = index;
                  });
                }
              ),
              items: bannerList.map((url) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), 
                  image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                ),
              )).toList(),
            ),

            // SLIDER INDICATORS (DOTS)
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bannerList.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF00A99D))
                        .withOpacity(_bannerIndex == entry.key ? 0.9 : 0.2),
                  ),
                );
              }).toList(),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Outdoor Category
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OutdoorSportsScreen()),
                    );
                  },
                  child: _buildCategoryIcon(Icons.sports_soccer, "Outdoor", Colors.blue),
                ),
                
                // Indoor Category
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IndoorSportsScreen()),
                    );
                  },
                  child: _buildCategoryIcon(Icons.videogame_asset, "Indoor", Colors.purple),
                ),
                
                // Winners Category
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WinnersScreen()),
                    );
                  },
                  child: _buildCategoryIcon(Icons.emoji_events, "Winners", Colors.orange),
                ),
                
                // Rules Category
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UniversityRulesScreen()),
                    );
                  },
                  child: _buildCategoryIcon(Icons.help_center, "Rules", Colors.green),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Row(
                children: [
                  Text("Available Sports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text("Pull down to refresh", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            _buildSportsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28, 
          backgroundColor: color.withOpacity(0.1), 
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSportsList() {
    if (_isLoadingSports && _sportsCache.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_sportsCache.isEmpty && !_isLoadingSports) {
      return Column(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.sports, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text('No sports available'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refreshSportsData,
            child: const Text('Try Again'),
          ),
        ],
      );
    }
    
    // Sport name se icon match karne ke liye function
    IconData getSportIcon(String sportName) {
      if (sportName.toLowerCase().contains('cricket')) return Icons.sports_cricket;
      if (sportName.toLowerCase().contains('football')) return Icons.sports_soccer;
      if (sportName.toLowerCase().contains('hockey')) return Icons.sports_hockey;
      if (sportName.toLowerCase().contains('badminton')) return Icons.sports_tennis;
      if (sportName.toLowerCase().contains('basketball')) return Icons.sports_basketball;
      if (sportName.toLowerCase().contains('volleyball')) return Icons.sports_volleyball;
      if (sportName.toLowerCase().contains('tennis')) return Icons.sports_tennis;
      if (sportName.toLowerCase().contains('chess')) return Icons.casino;
      if (sportName.toLowerCase().contains('table tennis') || sportName.toLowerCase().contains('ping pong')) return Icons.sports_tennis;
      if (sportName.toLowerCase().contains('gaming') || sportName.toLowerCase().contains('esports')) return Icons.videogame_asset;
      if (sportName.toLowerCase().contains('yoga')) return Icons.self_improvement;
      if (sportName.toLowerCase().contains('weight') || sportName.toLowerCase().contains('power')) return Icons.fitness_center;
      if (sportName.toLowerCase().contains('wrestling')) return Icons.sports_mma;
      if (sportName.toLowerCase().contains('karate') || sportName.toLowerCase().contains('taekwondo')) return Icons.sports_martial_arts;
      if (sportName.toLowerCase().contains('race') || sportName.toLowerCase().contains('athletics')) return Icons.directions_run;
      if (sportName.toLowerCase().contains('cycling')) return Icons.directions_bike;
      return Icons.emoji_events; // Default icon
    }
    
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sportsCache.length,
      itemBuilder: (context, index) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 50, 
            height: 50, 
            decoration: BoxDecoration(
              color: const Color(0xFF00A99D).withOpacity(0.1), 
              borderRadius: BorderRadius.circular(10)
            ), 
            child: Icon(
              getSportIcon(_sportsCache[index]['sport_name']), 
              color: const Color(0xFF00A99D),
              size: 28,
            ),
          ),
          title: Text(_sportsCache[index]['sport_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text("📍 Venue: ${_sportsCache[index]['venue']}"),
          trailing: ElevatedButton(
            onPressed: () => _openRegistrationForm(_sportsCache[index]['id'].toString(), _sportsCache[index]['sport_name']),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A99D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Apply", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white, 
      child: Column(children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF00A99D)),
          accountName: Text(userName ?? ""), 
          accountEmail: Text(userEmail ?? ""),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: (userImage != null && userImage!.isNotEmpty) ? NetworkImage(userImage!) : null,
            child: (userImage == null || userImage!.isEmpty) 
                ? Text((userName != null && userName!.isNotEmpty) ? userName![0].toUpperCase() : "S", style: const TextStyle(fontSize: 30, color: Color(0xFF00A99D))) 
                : null,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: Color(0xFF00A99D)), 
          title: const Text("Home"), 
          onTap: () {
            Navigator.pop(context);
            setState(() => _currentIndex = 0);
          }
        ),
        ListTile(
          leading: const Icon(Icons.list_alt, color: Color(0xFF00A99D)), 
          title: const Text("Sports List"), 
          onTap: () { 
            Navigator.pop(context); 
            setState(() => _currentIndex = 1); 
          }
        ),
        ListTile(
          leading: const Icon(Icons.history, color: Color(0xFF00A99D)), 
          title: const Text("Applied Sports"), 
          onTap: () { 
            Navigator.pop(context); 
            setState(() => _currentIndex = 2); 
          }
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Color(0xFF00A99D)), 
          title: const Text("About Us"), 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
          }
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.sports_soccer, color: Color(0xFF00A99D)), 
          title: const Text("Outdoor Sports"), 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OutdoorSportsScreen()));
          }
        ),
        ListTile(
          leading: const Icon(Icons.videogame_asset, color: Color(0xFF00A99D)), 
          title: const Text("Indoor Sports"), 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const IndoorSportsScreen()));
          }
        ),
        ListTile(
          leading: const Icon(Icons.emoji_events, color: Color(0xFF00A99D)), 
          title: const Text("Winners"), 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WinnersScreen()));
          }
        ),
        ListTile(
          leading: const Icon(Icons.help_center, color: Color(0xFF00A99D)), 
          title: const Text("University Rules"), 
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UniversityRulesScreen()));
          }
        ),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red), 
          title: const Text("Logout"), 
          onTap: _logout
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            children: [
              CircleAvatar(
                radius: 70, 
                backgroundColor: const Color(0xFF00A99D).withOpacity(0.1),
                backgroundImage: (userImage != null && userImage!.isNotEmpty) ? NetworkImage(userImage!) : null,
                child: (userImage == null || userImage!.isEmpty) ? const Icon(Icons.person, size: 70, color: Color(0xFF00A99D)) : null,
              ),
              if (_isUpdating) const Positioned.fill(child: Center(child: CircularProgressIndicator())),
              Positioned(
                bottom: 0, right: 0,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF00A99D),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20), 
                    onPressed: _pickAndUploadImage
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(userName ?? "", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(userEmail ?? "", style: const TextStyle(color: Colors.grey)),
          const Divider(height: 40, indent: 40, endIndent: 40),
          _profileOption(Icons.badge, "Roll Number", "See My Applications", () => setState(() => _currentIndex = 2)),
          _profileOption(Icons.lock, "Security", "Change Password", _showChangePasswordDialog),
          const SizedBox(height: 30),
          SizedBox(
            width: 200, 
            child: ElevatedButton(
              onPressed: _logout, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
              child: const Text("LOGOUT", style: TextStyle(color: Colors.white))
            )
          ),
        ],
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00A99D)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}