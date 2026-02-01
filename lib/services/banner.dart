import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import '../models/banner.dart';

class BannerService {
  final DatabaseReference _bannersRef =
  FirebaseDatabase.instance.ref('Banners');

  // Cloudinary konfiguracija
  static const cloudName = 'dxl1xnnx6';
  static const uploadPreset = 'unsigned_preset';

  // ================= GET ALL BANNERS =================
  Future<List<BannerModel>> getBanners() async {
    final snapshot = await _bannersRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    final List<BannerModel> banners = [];

    data.forEach((key, value) {
      final map = Map<String, dynamic>.from(value);
      banners.add(BannerModel.fromJson(map));
    });

    banners.sort((a, b) => a.id.compareTo(b.id));
    return banners;
  }

  // ================= ADD/UPDATE BANNER =================
  Future<void> saveBanner(BannerModel banner) async {
    await _bannersRef.child(banner.id).set(banner.toJson());
  }

  // ================= DELETE BANNER =================
  Future<void> deleteBanner(String id) async {
    await _bannersRef.child(id).remove();
  }

  // ================= UPLOAD IMAGE NA CLOUDINARY =================
  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(respStr);
      return data['secure_url']; // ovo je URL slike
    } else {
      throw Exception('Cloudinary upload failed: ${response.statusCode}');
    }
  }
}
