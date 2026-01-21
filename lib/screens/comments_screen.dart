import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart'; // ← DODATO

class Comment {
  final int id;
  final int productId;
  final String text;

  Comment({required this.id, required this.productId, required this.text});
}

class CommentsScreen extends StatefulWidget {
  final int productId;
  final bool isAdmin;

  const CommentsScreen({super.key, required this.productId, this.isAdmin = false});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  List<Comment> comments = [
    Comment(id: 1, productId: 1, text: 'Odličan proizvod!'),
    Comment(id: 2, productId: 1, text: 'Veoma sam zadovoljan.'),
    Comment(id: 3, productId: 2, text: 'Može bolje.'),
  ];

  void _addComment(String text) {
    if (text.trim().isEmpty) return;

    final bool isGuest = context.read<UserProvider>().isGuest;

    if (isGuest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFC1CC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Prijavite se',
            style: TextStyle(
              color: Color(0xFF800020),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Morate se prijaviti da biste ostavili komentar.',
            style: TextStyle(color: Color(0xFF800020)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Otkaži',
                style: TextStyle(color: Color(0xFF800020)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD87F7F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text(
                'Prijavi se',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      comments.add(Comment(
        id: comments.length + 1,
        productId: widget.productId,
        text: text,
      ));
    });

    _commentController.clear();
  }

  void _deleteComment(int id) {
    setState(() {
      comments.removeWhere((c) => c.id == id);
    });
  }

  void _confirmDelete(Comment comment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5E8E8),
        title: const Text(
          'Potvrdi brisanje',
          style: TextStyle(color: Color(0xFFD87F7F)),
        ),
        content: const Text(
          'Da li ste sigurni da želite da obrišete ovaj komentar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Otkaži'),
          ),
          TextButton(
            onPressed: () {
              _deleteComment(comment.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Obriši',
              style: TextStyle(color: Color(0xFFD87F7F)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productComments =
    comments.where((c) => c.productId == widget.productId).toList();

    final bool isGuest = context.watch<UserProvider>().isGuest;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD87F7F),
        title: const Text(
          'Komentari',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: productComments.isEmpty
                ? const Center(
              child: Text('Nema komentara za ovaj proizvod.'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productComments.length,
              itemBuilder: (context, index) {
                final comment = productComments[index];
                return Card(
                  color: const Color(0xFFE3CFCF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(comment.text),
                    trailing: (!isGuest && widget.isAdmin)
                        ? IconButton(
                      icon: const Icon(Icons.delete,
                          color: Color(0xFFD87F7F)),
                      onPressed: () =>
                          _confirmDelete(comment),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Dodaj komentar...',
                      filled: true,
                      fillColor: const Color(0xFFE3CFCF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addComment(_commentController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD87F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
