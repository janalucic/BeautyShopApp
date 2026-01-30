class Comment {
  final int id;
  final int productId;
  final String text;
  final String userId;
  final int? rating; // NOVO: ocena između 1-5
  final String? userName;

  Comment({
    required this.id,
    required this.productId,
    required this.text,
    required this.userId,
    this.rating,
    this.userName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      productId: json['productId'],
      text: json['text'],
      userId: json['userId'],
      rating: json['rating'], // NOVO
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'text': text,
      'userId': userId,
      if (rating != null) 'rating': rating, // NOVO
      if (userName != null) 'userName': userName,
    };
  }
}
