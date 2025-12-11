import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan URL server Anda
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  // Untuk testing di emulator Android: http://10.0.2.2:8000/api/v1
  // Untuk testing di device fisik: http://YOUR_IP:8000/api/v1

  // Get stored Firebase token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebase_token');
  }

  // Save Firebase token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_token', token);
  }

  // Clear token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_token');
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'display_name': displayName,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String idToken) async {
    try {
      print('📡 Sending login request to backend...');
      print('🔗 URL: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Login API error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      await clearToken();
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Get profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final Map<String, dynamic> body = {};
      if (username != null) body['username'] = username;
      if (displayName != null) body['display_name'] = displayName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update password
  Future<Map<String, dynamic>> updatePassword({
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.put(
        Uri.parse('$baseUrl/profile/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'confirm': true}),
      );

      await clearToken();
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('🔍 Handling response: ${response.statusCode}');
    
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Request successful');
        return data;
      } else {
        final errorMessage = data['message'] ?? 'Request failed';
        print('❌ Request failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error parsing response: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to parse response: $e');
    }
  }
}
