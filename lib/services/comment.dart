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
    if (!snapshot.exists || snapshot.value == null) return [];

    // Firebase može vratiti List ili Map, proveravamo
    List<dynamic> data;
    if (snapshot.value is List) {
      data = List<dynamic>.from(snapshot.value as List);
    } else if (snapshot.value is Map) {
      data = (snapshot.value as Map).values.toList();
    } else {
      return [];
    }

    final List<Comment> comments = [];

    for (var commentMap in data) {
      if (commentMap == null) continue; // preskoči null-ove
      final map = Map<String, dynamic>.from(commentMap);

      if (map['productId'] == productId) {
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

    if (snapshot.exists && snapshot.value != null) {
      if (snapshot.value is List) {
        data = List<dynamic>.from(snapshot.value as List);
      } else if (snapshot.value is Map) {
        data = (snapshot.value as Map).values.toList();
      }
    }

    // Dodaj novi komentar (sada sa rating)
    data.add(comment.toJson());

    await _commentsRef.set(data);
  }

  // ===============================
  // DELETE COMMENT
  // ===============================
  Future<void> deleteComment(int id) async {
    final snapshot = await _commentsRef.get();
    if (!snapshot.exists || snapshot.value == null) return;

    List<dynamic> data;
    if (snapshot.value is List) {
      data = List<dynamic>.from(snapshot.value as List);
    } else if (snapshot.value is Map) {
      data = (snapshot.value as Map).values.toList();
    } else {
      return;
    }

    // Ukloni komentar sa zadatim ID
    data.removeWhere((element) {
      if (element == null) return false;
      final map = Map<String, dynamic>.from(element);
      return map['id'] == id;
    });

    await _commentsRef.set(data);
  }

  // ===============================
  // UPDATE COMMENT (opciono)
  // ===============================
  Future<void> updateComment(Comment comment) async {
    final snapshot = await _commentsRef.get();
    if (!snapshot.exists || snapshot.value == null) return;

    List<dynamic> data;
    if (snapshot.value is List) {
      data = List<dynamic>.from(snapshot.value as List);
    } else if (snapshot.value is Map) {
      data = (snapshot.value as Map).values.toList();
    } else {
      return;
    }

    // Pronađi i izmeni komentar
    for (int i = 0; i < data.length; i++) {
      if (data[i] == null) continue;
      final map = Map<String, dynamic>.from(data[i]);
      if (map['id'] == comment.id) {
        data[i] = comment.toJson();
        break;
      }
    }

    await _commentsRef.set(data);
  }
}
