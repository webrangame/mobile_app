import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ApiService {
  static const String _baseUrl = 'https://xfukqtd5pc.us-east-1.awsapprunner.com';
  static const String _marketBaseUrl = 'https://market.niyogen.com';
  static const String DEFAULT_USER_ID = 'test_user_123';
  static const String AGENT_ID = 'price-comparison-agent-australia';

  /// Helper to get the best possible user identifier.
  /// Prioritizes Email for LiteLLM readability, then numeric ID, then default.
  Future<String> _getBestUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return userMap['email']?.toString() ?? 
               userMap['id']?.toString() ?? 
               DEFAULT_USER_ID;
      }
    } catch (e) {
      print('Error getting user ID: $e');
    }
    return DEFAULT_USER_ID;
  }

  Future<List<dynamic>> fetchReviews() async {
    try {
      final url = '$_marketBaseUrl/api/reviews?agentId=$AGENT_ID&limit=50';
      print('ApiService: Fetching reviews from $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reviews'] as List<dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
       print('ApiService Error (fetchReviews): $e');
       if (e is http.ClientException) throw Exception('Network error. Please check your connection.');
       throw Exception('Error fetching reviews: $e');
    }
  }

  Future<void> submitReview({required int rating, required String comment}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson == null) throw Exception('No user found. Please login.');
      
      final userMap = jsonDecode(userJson);
      final userId = userMap['id']?.toString() ?? userMap['email']?.toString();
      
      if (userId == null) throw Exception('User ID is required.');

      final url = '$_marketBaseUrl/api/reviews';
      print('ApiService: Submitting review to $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'agentId': AGENT_ID,
          'userId': userId,
          'rating': rating,
          'comment': comment,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Failed to submit review');
      }
    } catch (e) {
       print('ApiService Error (submitReview): $e');
       throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<dynamic> sendMessage(String text) async {
    try {
      final userId = await _getBestUserId();
      final url = '$_baseUrl/chat';
      print('ApiService: Sending message to $url for user: $userId');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 45)); // Slightly longer for RAG

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'response': data['response'] ?? "No response received.",
          'metadata': data['metadata'] ?? [],
        };
      } else {
        String errorMsg = 'Server Error (${response.statusCode})';
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorData['detail'] != null) {
            errorMsg = errorData['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('ApiService Error (sendMessage): $e');
      if (e is SocketException || e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please check your internet.');
      }
      if (e is TimeoutException || e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. The server might be busy.');
      }
      throw Exception('Connection error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<List<dynamic>> getItemsByShop(String shopName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/items?shop_name=$shopName'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['items'] as List<dynamic>;
      } else {
        throw Exception('Failed to load items (${response.statusCode})');
      }
    } catch (e) {
      print('ApiService Error in getItemsByShop: $e');
      throw Exception('Error fetching shop items: $e');
    }
  }
}
