import 'package:firebase_database/firebase_database.dart';
import '../models/comment.dart';

class CommentService {
  final DatabaseReference _commentsRef =
  FirebaseDatabase.instance.ref('Comments');

  // ===============================
  // GET COMMENTS FOR PRODUCT
  // ===============================
  Future<List<Comment>> getComments(int productId) async {
    final snapshot = await _commentsRef.get();

    if (!snapshot.exists) return [];

    // Firebase vraća List ako je niz u JSON-u
    final List<dynamic> data = snapshot.value as List<dynamic>;

    final List<Comment> comments = [];

    for (var commentMap in data) {
      if (commentMap == null) continue; // preskoči null-ove
      final map = Map<String, dynamic>.from(commentMap);

      if (map['productId'] == productId) {
        // userId sada je String (Firebase uid), nema int.parse
        comments.add(Comment.fromJson(map));
      }
    }

    return comments;
  }

  // ===============================
  // ADD COMMENT
  // ===============================
  Future<void> addComment(Comment comment) async {
    final snapshot = await _commentsRef.get();
    List<dynamic> data = [];

    if (snapshot.exists) {
      data = List<dynamic>.from(snapshot.value as List<dynamic>);
    }

    // Dodaj novi komentar
    data.add(comment.toJson());

    await _commentsRef.set(data);
  }

  // ===============================
  // DELETE COMMENT
  // ===============================
  Future<void> deleteComment(int id) async {
    final snapshot = await _commentsRef.get();
    if (!snapshot.exists) return;

    List<dynamic> data = List<dynamic>.from(snapshot.value as List<dynamic>);

    // Ukloni komentar sa zadatim ID
    data.removeWhere((element) {
      if (element == null) return false;
      final map = Map<String, dynamic>.from(element);
      return map['id'] == id;
    });

    await _commentsRef.set(data);
  }
}
