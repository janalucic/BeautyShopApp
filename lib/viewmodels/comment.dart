import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ===============================
  // GETTERS (za UI)
  // ===============================
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===============================
  // FETCH COMMENTS FOR PRODUCT
  // ===============================
  Future<void> fetchComments(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _commentService.getComments(productId);
    } catch (e) {
      _errorMessage = 'Greška pri učitavanju komentara';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===============================
  // ADD COMMENT
  // ===============================
  Future<void> addComment(Comment comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _commentService.addComment(comment); // comment sada ima rating
      _comments.add(comment); // lokalno dodavanje
    } catch (e) {
      _errorMessage = 'Greška pri dodavanju komentara';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ===============================
  // DELETE COMMENT
  // ===============================
  Future<void> deleteComment(int commentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _commentService.deleteComment(commentId); // <-- šalje int
      _comments.removeWhere((c) => c.id == commentId);
    } catch (e) {
      _errorMessage = 'Greška pri brisanju komentara';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ===============================
  // CLEAR COMMENTS
  // ===============================
  void clearComments() {
    _comments = [];
    notifyListeners();
  }
  // ===============================
// GET AVERAGE RATING FOR A PRODUCT
// ===============================
  double getAverageRating(int productId) {
    final productComments = _comments.where((c) => c.productId == productId).toList();
    if (productComments.isEmpty) return 0.0;

    final total = productComments.fold<int>(0, (sum, c) => sum + (c.rating ?? 0));
    return total / productComments.length;
  }

// ===============================
// GET NUMBER OF COMMENTS FOR PRODUCT
// ===============================
  int getCommentCount(int productId) {
    return _comments.where((c) => c.productId == productId).length;
  }

}
