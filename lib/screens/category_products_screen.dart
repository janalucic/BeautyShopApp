import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:first_app_flutter/models/product.dart';
import 'package:first_app_flutter/viewmodels/product.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final bool isAdmin; // Admin status

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<ProductViewModel>(context);
    final List<Product> products = productVM.products
        .where((p) => p.categoryId == categoryId)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E8E8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD87F7F)),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Color(0xFFD87F7F),
            fontFamily: 'Spinnaker',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: productVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(
        child: Text(
          'Nema proizvoda u ovoj kategoriji.',
          style: TextStyle(
            fontFamily: 'Spinnaker',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                    product: product,
                    isAdmin: isAdmin,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD87F7F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD87F7F),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white.withOpacity(0.6),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFFD87F7F),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${product.price.toStringAsFixed(2)} RSD',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: const Color(0xFFD87F7F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddProductDialog(context, productVM),
      )
          : null,
    );
  }

  // ====================== DIALOG ZA DODAVANJE PROIZVODA ======================
  void _showAddProductDialog(BuildContext context, ProductViewModel productVM) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    bool isPopular = false;
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFD87F7F),
              title: const Text(
                'Dodaj novi proizvod',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Naziv proizvoda',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Opis proizvoda',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Cena',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Popular
                    Row(
                      children: [
                        Checkbox(
                          value: isPopular,
                          onChanged: (val) => setState(() => isPopular = val ?? false),
                          checkColor: Colors.white,
                          activeColor: Colors.white70,
                        ),
                        const Text('Popularan', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Pick image
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) setState(() => pickedImage = image);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child: Text(
                        pickedImage == null ? 'Izaberi sliku' : 'Izabrano',
                        style: const TextStyle(color: Color(0xFFD87F7F)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        descController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        pickedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Popunite sva polja i izaberite sliku')),
                      );
                      return;
                    }

                    // Upload slike na Cloudinary
                    final imageUrl = await uploadImageToCloudinary(pickedImage!);

                    // Kreiranje proizvoda
                    final newProduct = Product(
                      id: DateTime.now().millisecondsSinceEpoch,
                      categoryId: categoryId,
                      name: nameController.text,
                      description: descController.text,
                      price: double.parse(priceController.text),
                      popular: isPopular,
                      imageUrl: imageUrl,
                    );

                    // Dodaj proizvod u ViewModel
                    await productVM.addProduct(newProduct);

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text('Sačuvaj', style: TextStyle(color: Color(0xFFD87F7F))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ====================== FUNKCIJA ZA UPLOAD NA CLOUDINARY ======================
  Future<String> uploadImageToCloudinary(XFile image) async {
    const cloudName = 'dxl1xnnx6';
    const uploadPreset = 'unsigned_preset';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final jsonRes = json.decode(resStr);

    return jsonRes['secure_url'];
  }
}
