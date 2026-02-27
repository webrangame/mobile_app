import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Using the live URL as requested by "same api login"
  static const String _baseUrl = 'https://market.niyogen.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        if (data['accessToken'] != null) {
          await prefs.setString('accessToken', data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await prefs.setString('refreshToken', data['refreshToken']);
        }
        if (data['user'] != null) {
          await prefs.setString('user', jsonEncode(data['user']));
        }

        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is TimeoutException) throw Exception('Login request timed out. Please try again.');
      throw Exception('Login error: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Forgot password request failed');
      }
    } catch (e) {
      if (e is TimeoutException) throw Exception('Request timed out. Please try again.');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        if (data['accessToken'] != null) {
          await prefs.setString('accessToken', data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await prefs.setString('refreshToken', data['refreshToken']);
        }
        if (data['user'] != null) {
          await prefs.setString('user', jsonEncode(data['user']));
        }

        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Signup failed');
      }
    } catch (e) {
      if (e is TimeoutException) throw Exception('Signup request timed out. Please try again.');
      throw Exception('Signup error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }

  /// Retrieve the stored user ID (if any) from SharedPreferences.
  /// Returns `null` when no user is logged in or the stored JSON does not contain an `id` field.
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    try {
      final decoded = jsonDecode(userJson);
      if (decoded is! Map) return null;
      final Map<String, dynamic> userMap = Map<String, dynamic>.from(decoded);
      // Adjust the key name according to the backend's user schema.
      return userMap['id']?.toString() ??
          userMap['userId']?.toString() ??
          userMap['uid']?.toString();
    } catch (_) {
      return null;
    }
  }
}
