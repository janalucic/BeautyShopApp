class Comment {
  final int id;
  final int productId;
  final int userId;
  final String text;

  Comment({
    required this.id,
    required this.productId,
    required this.userId,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'text': text,
    };
  }
}
