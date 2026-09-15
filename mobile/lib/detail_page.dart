import 'package:flutter/material.dart';
import 'http_service.dart';

class DetailPage extends StatelessWidget {
  final int postId;

  const DetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: HttpService.getPostById(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Artikel tidak ditemukan.'));
          }

          final post = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  post['title'] ?? 'Tanpa Judul',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kategori ID: ${post['category_id'] ?? '-'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Divider(height: 24),
                Text(
                  post['content'] ?? 'Tidak ada konten.',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}