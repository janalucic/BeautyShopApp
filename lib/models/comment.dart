class Comment {
  final int id;
  final int productId;
  final String userId;     // UID iz Firebase Auth
  final String userName;   // NOVO polje: ime korisnika
  final String text;

  Comment({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName, // obavezno
    required this.text,
  });

  // Factory za kreiranje Comment objekta iz JSON / Firebase snapshot
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: int.parse(json['id'].toString()),
      productId: int.parse(json['productId'].toString()),
      userId: json['userId'].toString(),
      userName: json['userName']?.toString() ?? 'Korisnik', // fallback za stare komentare
      text: json['text'].toString(),
    );
  }

  // Pretvaranje Comment objekta u JSON za upis u Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName, // NOVO polje
      'text': text,
    };
  }
}
