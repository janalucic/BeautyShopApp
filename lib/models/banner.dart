class BannerModel {
  final String id;
  final String imageUrl;
  final int productId;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.productId,
    required this.isActive,
  });

  // =================== FROM JSON ===================
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'],
      productId: int.parse(json['productId'].toString()),
      isActive: json['isActive'].toString().toLowerCase() == 'true',
    );
  }


  // =================== TO JSON ===================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'productId': productId,
      'isActive': isActive,
    };
  }
}
