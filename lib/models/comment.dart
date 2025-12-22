class Comment {
  final int id;
  final int productId;
  final int userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.productId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      productId: json['productId'] as int,
      userId: json['userId'] as int,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
