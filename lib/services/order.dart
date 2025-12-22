import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class OrderService {
  final CollectionReference ordersCollection =
  FirebaseFirestore.instance.collection('orders');

  // Kreiranje nove porudžbine
  Future<void> createOrder(UserOrder order) async {
    await ordersCollection.doc(order.toString()).set(order.toJson());
  }

  // Dohvat svih porudžbina (za admina)
  Future<List<UserOrder>> getAllOrders() async {
    var snapshot = await ordersCollection.get();
    return snapshot.docs
        .map((doc) => UserOrder.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Dohvat porudžbina jednog korisnika
  Future<List<UserOrder>> getOrdersByUser(String userId) async {
    var snapshot = await ordersCollection
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => UserOrder.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Ažuriranje porudžbine (npr. status)
  Future<void> updateOrder(UserOrder order) async {
    await ordersCollection.doc(order.id.toString()).update(order.toJson());
  }

  // Brisanje porudžbine
  Future<void> deleteOrder(String id) async {
    await ordersCollection.doc(id).delete();
  }
}
