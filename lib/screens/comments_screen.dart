import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/user_provider.dart';
import '../viewmodels/comment.dart';
import '../models/comment.dart';
import 'login_screen.dart';

class CommentsScreen extends StatefulWidget {
  final int productId;

  const CommentsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedRating = 5; // default ocena

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentVM = context.read<CommentViewModel>();
      commentVM.fetchComments(widget.productId);
    });
  }

  // ===============================
  // ADD COMMENT
  // ===============================
  void _addComment(String text) async {
    if (text.trim().isEmpty) return;

    final userProvider = context.read<UserProvider>();

    if (userProvider.isGuest) {
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
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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

    if (userProvider.isAdmin) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFC1CC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Administratori ne mogu dodavati komentare',
            style: TextStyle(
              color: Color(0xFF800020),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFF800020))),
            ),
          ],
        ),
      );
      return;
    }

    final String uid = FirebaseAuth.instance.currentUser!.uid;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: widget.productId,
      userId: uid,
      userName: userProvider.currentUser!.name,
      text: text,
      rating: _selectedRating,
    );

    final commentVM = context.read<CommentViewModel>();
    await commentVM.addComment(newComment);

    _commentController.clear();

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentVM = context.watch<CommentViewModel>();
    final userProvider = context.watch<UserProvider>();

    final comments = commentVM.comments
        .where((c) => c.productId == widget.productId)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD87F7F),
        title: const Text('Komentari', style: TextStyle(color: Colors.white)),
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

                return Card(
                  color: const Color(0xFFE3CFCF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(comment.text ?? ''),
                    subtitle: Row(
                      children: [
                        Text(
                          comment.userName ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 10),
                        // ====================
                        // ZVEZDICE
                        // ====================
                        Row(
                          children: _buildRatingStars(
                            comment.rating?.toDouble() ?? 0,
                            14.0,
                            Colors.pinkAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // RATING SELECTOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    int starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        _selectedRating >= starIndex
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.pinkAccent, // ROZE
                      ),
                      onPressed: () =>
                          setState(() => _selectedRating = starIndex),
                      iconSize: 28,
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================== POMOĆNA FUNKCIJA ZA ZVEZDICE ======================
  List<Widget> _buildRatingStars(double rating, double size, Color color) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: color, size: size));
    }
    if (hasHalfStar) {
      stars.add(Icon(Icons.star_half, color: color, size: size));
    }
    while (stars.length < 5) {
      stars.add(Icon(Icons.star_border, color: color, size: size));
    }
    return stars;
  }
}
