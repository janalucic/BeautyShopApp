class Product {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final bool popular;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.popular,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      popular: json['popular'] ?? false,
    );
  }

  // <<< DODAJ OVO >>>
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'popular': popular,
    };
  }
}
