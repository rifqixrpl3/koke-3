import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  static Future<List<dynamic>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  static Future<Map<String, dynamic>> getPostById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } else {
      throw Exception('Gagal memuat detail artikel');
    }
  }

  static Future<void> createPost(String title, String content, int categoryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "content": content,
        "category_id": categoryId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menambah artikel');
    }
  }

  static Future<void> updatePost(int id, String title, String content, int categoryId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "content": content,
        "category_id": categoryId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui artikel');
    }
  }

  static Future<bool> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    return response.statusCode == 200;
  }
}