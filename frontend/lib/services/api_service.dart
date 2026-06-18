import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // The baseUrl can now be injected at compile-time:
  // flutter run --dart-define=API_URL=https://your-production-url.com
  // It defaults to localhost for standard dev testing.
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8000');

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> _setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_name');
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _setToken(data['access_token']);
      if (data.containsKey('name') && data['name'] != null) {
        await _setName(data['name']);
      }
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> analyzeImage(XFile imageFile) async {
    final token = await _getToken();
    if (token == null) return null;

    print('DEBUG: Image selected: ${imageFile.name}');
    print('DEBUG: API request sent to $baseUrl/api/analyze');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/analyze'));
    request.headers['Authorization'] = 'Bearer $token';
    
    final bytes = await imageFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name));

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('DEBUG: API response received: 200 OK');
        Map<String, dynamic> data = jsonDecode(response.body);
        
        // Decode base64 mask to image
        if (data.containsKey('mask')) {
          String base64String = data['mask'];
          if (base64String.contains(',')) {
            base64String = base64String.split(',')[1];
          }
          data['mask_bytes'] = base64Decode(base64String);
        }
        return data;
      }
      
      print('DEBUG: API error response: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to analyze image: ${response.body}');
    } catch (e) {
      print('DEBUG: Error during analyzeImage: $e');
      rethrow;
    }
  }

  Future<List<dynamic>?> getHistory() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
