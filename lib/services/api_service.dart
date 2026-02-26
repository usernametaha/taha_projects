import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL taake har baar poora link na likhna paray
  static const String baseUrl = "https://skcubetech.site/sport_api";

  // Sab sports ki list fetch karne ka function
  static Future<List<dynamic>> getSports() async {
    final response = await http.get(Uri.parse('$baseUrl/get_sports.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sports');
    }
  }

  // Sport ke liye apply karne ka common function
  static Future<Map<String, dynamic>> applyForSport(String userId, String sportId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apply_sport.php'),
      body: {
        'user_id': userId,
        'sport_id': sportId,
      },
    );
    return json.decode(response.body);
  }

  // FCM Token update karne ka function
  static Future<void> updateFCMToken(String userId, String token) async {
    await http.post(
      Uri.parse('$baseUrl/update_token.php'),
      body: {
        'user_id': userId,
        'fcm_token': token,
      },
    );
  }
}