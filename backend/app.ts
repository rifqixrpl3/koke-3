import express, { Request, Response } from 'express';
import cors from 'cors';
import mysql from 'mysql2';
import { z } from 'zod';

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'db_blog_app'
});

db.connect((err) => {
  if (err) {
    console.error('Gagal konek MySQL:', err);
  } else {
    console.log('Terkoneksi ke database db_blog_app!');
  }
});

const postSchema = z.object({
  title: z.string().min(1, 'Title wajib diisi'),
  content: z.string().min(1, 'Content wajib diisi'),
  category_id: z.any()
});

const categorySchema = z.object({
  name: z.string().min(1, 'Name kategori wajib diisi')
});

app.get('/api/posts', (req: Request, res: Response) => {
  const query = `
    SELECT posts.*, categories.name AS category_name 
    FROM posts 
    LEFT JOIN categories ON posts.category_id = categories.id
    ORDER BY posts.id DESC
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: (err as Error).message });
    }
    res.json(results);
  });
});

app.delete('/api/posts/:id', (req: Request, res: Response) => {
  const { id } = req.params;
  const query = 'DELETE FROM posts WHERE id = ?';

  db.query(query, [id], (err, result) => {
    if (err) {
      return res.status(500).json({ error: (err as Error).message });
    }
    res.json({ message: 'Artikel berhasil dihapus' });
  });
});

app.post('/api/posts', (req: Request, res: Response) => {
  const validation = postSchema.safeParse(req.body);
  if (!validation.success) {
    return res.status(400).json({ error: validation.error.format() });
  }

  const { title, content, category_id } = validation.data;
  const query = 'INSERT INTO posts (title, content, category_id) VALUES (?, ?, ?)';

  db.query(query, [title, content, category_id], (err, result) => {
    if (err) {
      return res.status(500).json({ error: (err as Error).message });
    }
    res.json({ message: 'Artikel berhasil ditambahkan', id: (result as any).insertId });
  });
});

app.put('/api/posts/:id', (req: Request, res: Response) => {
  const validation = postSchema.safeParse(req.body);
  if (!validation.success) {
    return res.status(400).json({ error: validation.error.format() });
  }

  const { id } = req.params;
  const { title, content, category_id } = validation.data;
  const query = 'UPDATE posts SET title = ?, content = ?, category_id = ? WHERE id = ?';

  db.query(query, [title, content, category_id, id], (err, result) => {
    if (err) {
      return res.status(500).json({ error: (err as Error).message });
    }
    res.json({ message: 'Artikel berhasil diperbarui' });
  });
});

app.get('/api/categories', (req: Request, res: Response) => {
  const query = 'SELECT * FROM categories ORDER BY name ASC';
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: (err as Error).message });
    }
    res.json(results);
  });
});

app.post('/api/categories', (req: Request, res: Response) => {
  const validation = categorySchema.safeParse(req.body);
  if (!validation.success) {
    return res.status(400).json({ error: validation.error.format() });
  }

  const { name } = validation.data;
  const query = 'INSERT INTO categories (name) VALUES (?)';

  db.query(query, [name], (err, result) => {
    if (err) {
      return res.status(500).json({ error: (err as Error).message });
    }
    res.json({ message: 'Kategori berhasil ditambahkan', id: (result as any).insertId });
  });
});

app.listen(3000, () => {
  console.log('Server jalan di http://localhost:3000');
});