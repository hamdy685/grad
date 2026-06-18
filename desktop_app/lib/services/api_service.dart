import 'dart:convert';
import 'package:cross_file/cross_file.dart';
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<bool> login(String email, String password) async {
    print('Attempting login to $baseUrl/auth/login');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      ).timeout(const Duration(seconds: 10));

      print('Login response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _setToken(data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    print('Attempting register to $baseUrl/auth/register');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      print('Register response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> analyzeImage(XFile imageFile) async {
    final token = await _getToken();
    if (token == null) return null;

    final bytes = await imageFile.readAsBytes();
    print('Sending API request to: $baseUrl/api/analyze');
    print('File: ${imageFile.name}, Size: ${bytes.length} bytes');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/analyze'));
    request.headers['Authorization'] = 'Bearer $token';
    
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name));

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to analyze image: HTTP ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('API Error: $e');
      throw Exception('Failed to connect to backend: $e');
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
