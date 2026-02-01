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

    List<dynamic> data = [];

    if (snapshot.value is List) {
      data = List<dynamic>.from(snapshot.value as List);
    } else if (snapshot.value is Map) {
      data = (snapshot.value as Map).values.toList();
    }

    final List<Comment> comments = [];

    bool needsUpdate = false; // flag za update starih komentara

    for (var commentMap in data) {
      if (commentMap == null) continue;
      final map = Map<String, dynamic>.from(commentMap);

      // Ako komentar nema createdAt, dodaj timestamp sada
      if (!map.containsKey('createdAt')) {
        map['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        needsUpdate = true; // moramo da sačuvamo ovu promenu u Firebase
      }

      if (map['productId'] == productId) {
        comments.add(Comment.fromJson(map));
      }
    }

    // Ako smo dodali createdAt starim komentarima, sačuvaj nazad
    if (needsUpdate) {
      await _commentsRef.set(data);
    }

    // Sortiranje po datumu, najnoviji prvi
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

    // Novi komentar već ima createdAt u Comment.toJson()
    data.add(comment.toJson());
    await _commentsRef.set(data);
  }

  // ===============================
  // DELETE COMMENT
  // ===============================
  Future<void> deleteComment(int id) async {
    final snapshot = await _commentsRef.get();
    if (!snapshot.exists || snapshot.value == null) return;

    List<dynamic> data = [];

    if (snapshot.value is List) {
      data = List<dynamic>.from(snapshot.value as List);
    } else if (snapshot.value is Map) {
      data = (snapshot.value as Map).values.toList();
    }

    data.removeWhere((element) {
      if (element == null) return false;
      final map = Map<String, dynamic>.from(element);
      return map['id'] == id;
    });

    await _commentsRef.set(data);
  }
}
