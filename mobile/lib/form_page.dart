import 'package:flutter/material.dart';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? post;
  const FormPage({super.key, this.post});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!['title'] ?? '';
      _categoryController.text = widget.post!['category_name'] ?? 'Umum';
      _contentController.text = widget.post!['content'] ?? '';
    } else {
      _categoryController.text = 'Umum';
    }
  }

  void _savePost() {
    if (_titleController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data'), backgroundColor: Colors.orange),
      );
      return;
    }

    Navigator.pop(context, {
      if (widget.post != null) 'id': widget.post!['id'],
      'title': _titleController.text,
      'content': _contentController.text,
      'category_id': 1, // Sesuaikan ID kategori sementara
      'category_name': _categoryController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Artikel' : 'Tambah Artikel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Artikel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Isi Artikel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: _savePost,
                child: Text(
                  isEdit ? 'Update' : 'Simpan',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}