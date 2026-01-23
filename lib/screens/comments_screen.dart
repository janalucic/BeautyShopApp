import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../viewmodels/comment.dart';
import '../models/comment.dart';
import 'login_screen.dart';

class CommentsScreen extends StatefulWidget {
  final int productId;
  final bool isAdmin;

  const CommentsScreen({super.key, required this.productId, this.isAdmin = false});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentVM = Provider.of<CommentViewModel>(context, listen: false);
      commentVM.fetchComments(widget.productId);
    });
  }

  void _addComment(String text) async {
    if (text.trim().isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final bool isGuest = userProvider.isGuest;
    final int userId = userProvider.userId ?? 0;

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

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: widget.productId,
      text: text,
      userId: userId,
    );

    final commentVM = context.read<CommentViewModel>();
    await commentVM.addComment(newComment);
    _commentController.clear();

    // Scroll do poslednjeg komentara (opcionalno)
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _deleteComment(int id) {
    final commentVM = context.read<CommentViewModel>();
    commentVM.deleteComment(id);
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
        content: const Text('Da li ste sigurni da želite da obrišete ovaj komentar?'),
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

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final commentVM = context.watch<CommentViewModel>();
    final comments = commentVM.comments
        .where((c) => c.productId == widget.productId)
        .toList();

    final userProvider = context.watch<UserProvider>();
    final bool isGuest = userProvider.isGuest;

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
            child: commentVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text('Nema komentara za ovaj proizvod.'))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final userName = userProvider.getUserNameById(comment.userId);

                return Card(
                  color: const Color(0xFFE3CFCF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(comment.text),
                    subtitle: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: (!isGuest && widget.isAdmin)
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFD87F7F)),
                      onPressed: () => _confirmDelete(comment),
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
