import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final CollectionReference commentsCollection =
  FirebaseFirestore.instance.collection('comments');

  //Prikaz svih komentara
  Future<List<Comment>> getComments(String productId) async {
    var snapshot = await commentsCollection
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs
        .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
//Dodavanje komentara
  Future<void> addComment(Comment comment) async {
    await commentsCollection.doc(comment.id.toString()).set(comment.toJson());
  }
//Brisanje komentara
  Future<void> deleteComment(String id) async {
    await commentsCollection.doc(id).delete();
  }
}
