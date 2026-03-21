import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../util/platform_config.dart';

class ApiService {
  // URL is resolved at runtime based on platform (iOS sim = localhost,
  // Android emulator = 10.0.2.2, physical device = your machine's LAN IP).
  static String get baseUrl => PlatformConfig.getBackendUrl(path: '');

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const Duration _timeout = Duration(seconds: 30);

  // ==================== TEXT ANALYSIS ====================

  Future<Map<String, dynamic>> analyzeText(String text, {String? userId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          if (userId != null) 'userId': userId,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Failed to analyze text: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile, {String? userId}) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/analyze-image'));
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      if (userId != null) request.fields['userId'] = userId;

      final streamedResponse =
          await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ==================== USER PROFILE ====================

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user/$userId/profile'))
          .timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      if (response.statusCode == 404) return {};
      throw ApiException('Failed to get profile: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/user/$userId/profile'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(profileData))
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserSubscription(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user/$userId/subscription'))
          .timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Failed to get subscription: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ==================== SCAN HISTORY ====================

  Future<String?> saveScanHistory(
      String userId, Map<String, dynamic> scanData) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/user/$userId/history'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(scanData))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['scanId'];
      }
      throw ApiException('Failed to save history: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getScanHistory(String userId,
      {int limit = 50}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user/$userId/history?limit=$limit'))
          .timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Failed to get history: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<bool> deleteScan(String userId, String scanId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/user/$userId/history/$scanId'))
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<bool> clearAllHistory(String userId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/user/$userId/history'))
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ==================== PRODUCTS ====================

  Future<Map<String, dynamic>> searchProducts(String query,
      {String? category, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/products/search').replace(
          queryParameters: {
            'query': query,
            if (category != null && category != 'all') 'category': category,
            'limit': limit.toString(),
          });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Failed to search products: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getAllProducts(
      {String? category, int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl/products/all').replace(
          queryParameters: {
            if (category != null && category != 'all') 'category': category,
            'limit': limit.toString(),
          });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Failed to get products: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getProductDetails(String productId,
      {String? userId}) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId').replace(
          queryParameters: {if (userId != null) 'userId': userId});
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      if (response.statusCode == 404) throw ApiException('Product not found');
      throw ApiException('Failed to get product: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ==================== INGREDIENTS ====================

  Future<Map<String, dynamic>> searchIngredients(String query,
      {String? category, int limit = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl/ingredients/search').replace(
          queryParameters: {
            'query': query,
            if (category != null && category != 'all') 'category': category,
            'limit': limit.toString(),
          });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException(
          'Failed to search ingredients: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getAllIngredients(
      {String? category, int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl/ingredients/all').replace(
          queryParameters: {
            if (category != null && category != 'all') 'category': category,
            'limit': limit.toString(),
          });
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Failed to get ingredients: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // ==================== HEALTH CHECK ====================

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
