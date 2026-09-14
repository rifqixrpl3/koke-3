import 'package:flutter/material.dart';
import 'form_page.dart';
import 'http_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      final data = await HttpService.getPosts();
      setState(() {
        _posts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deletePost(int id) async {
    final success = await HttpService.deletePost(id);
    if (success) {
      _fetchPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog App')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('Belum ada artikel', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchPosts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFF222222)),
                    itemBuilder: (context, index) {
                      final item = _posts[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item['title'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(item['content'] ?? '', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['category_name'] ?? 'Umum',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormPage(post: item),
                                  ),
                                );
                                
                                if (result != null) {
                                  if (result['id'] != null) {
                                    await HttpService.updatePost(
                                      result['id'], 
                                      result['title'], 
                                      result['content'], 
                                      result['category_id']
                                    );
                                  } else {
                                    await HttpService.createPost(
                                      result['title'], 
                                      result['content'], 
                                      result['category_id']
                                    );
                                  }
                                  _fetchPosts();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePost(item['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPage()),
          );
          if (result != null) {
            await HttpService.createPost(
              result['title'], 
              result['content'], 
              result['category_id']
            );
            _fetchPosts();
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}