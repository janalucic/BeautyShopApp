class Comment {
  final int id;
  final int productId;
  final String text;
  final String userId;
  final int? rating;       // ocena između 1-5
  final String? userName;
  final DateTime createdAt; // datum kreiranja

  Comment({
    required this.id,
    required this.productId,
    required this.text,
    required this.userId,
    this.rating,
    this.userName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // =================== FROM JSON ===================
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      productId: json['productId'],
      text: json['text'],
      userId: json['userId'],
      rating: json['rating'],
      userName: json['userName'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime(1970, 1, 1), // fallback za stare komentare
    );
  }

  // =================== TO JSON ===================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'text': text,
      'userId': userId,
      if (rating != null) 'rating': rating,
      if (userName != null) 'userName': userName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
