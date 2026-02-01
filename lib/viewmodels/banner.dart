import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart'; // Cloudinary paket
import '../services/banner.dart'; // BannerService
import '../models/banner.dart';   // BannerModel

class BannerViewModel extends ChangeNotifier {
  final BannerService _bannerService = BannerService();

  List<BannerModel> _banners = [];
  List<BannerModel> get banners => _banners;

  // ================= CLOUDINARY =================
  final CloudinaryPublic _cloudinary =
  CloudinaryPublic('dxl1xnnx6', 'unsigned_preset', cache: false);

  /// Upload slike na Cloudinary i vrati URL
  Future<String> uploadImage(File file) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload failed: $e');
      return '';
    }
  }

  // ================= FETCH BANNERS =================
  Future<void> fetchBanners() async {
    _banners = await _bannerService.getBanners();
    notifyListeners();
  }

  // ================= ADD BANNER =================
  Future<void> addBanner(BannerModel banner) async {
    await _bannerService.saveBanner(banner);

    // Dodaj samo ako ne postoji
    if (!_banners.any((b) => b.id == banner.id)) {
      _banners.add(banner);
      notifyListeners();
    }
  }

// ================= UPDATE BANNER =================
  Future<void> updateBanner(BannerModel banner) async {
    await _bannerService.saveBanner(banner);

    // Nađi index po id i zameni
    final index = _banners.indexWhere((b) => b.id == banner.id);
    if (index != -1) {
      _banners[index] = banner;
    } else {
      // Ako baner ne postoji, dodaj ga
      _banners.add(banner);
    }
    notifyListeners();
  }

// ================= DELETE BANNER =================
  Future<void> deleteBanner(String id) async {
    await _bannerService.deleteBanner(id);
    _banners.removeWhere((b) => b.id == id);
    notifyListeners();
  }


  // ================= ACTIVE BANNERS =================
  List<BannerModel> get activeBanners =>
      _banners.where((b) => b.isActive).toList();
}
