import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../providers/currency_provider.dart';
import '../viewmodels/product.dart';
import '../viewmodels/category.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'comments_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product; // LOKALNI PROIZVOD
  int _quantity = 1;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product; // inicijalizacija lokalnog proizvoda
    Provider.of<CurrencyProvider>(context, listen: false).fetchEurRate();
    Provider.of<CategoryViewModel>(context, listen: false).fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = context.watch<UserProvider>().isGuest;
    final cartProvider = context.watch<CartProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final productVM = context.watch<ProductViewModel>();

    final double totalPriceRsd = _product.price * _quantity;
    final double? totalPriceEur =
    currencyProvider.convertToEur(totalPriceRsd);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDE4E4), Color(0xFFFFF5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BACK BUTTON + TITLE
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Color(0xFFD87F7F), size: 32),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Spinnaker',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD87F7F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // IMAGE
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            _product.imageUrl,
                            width: 260,
                            height: 260,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DESCRIPTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product.description,
                              maxLines:
                              _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Spinnaker',
                                fontSize: 16,
                                color: Color(0xFFD87F7F),
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() =>
                              _isDescriptionExpanded =
                              !_isDescriptionExpanded),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isDescriptionExpanded
                                        ? 'Prikaži manje'
                                        : 'Vidi više',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xFF800020),
                                    ),
                                  ),
                                  Icon(
                                    _isDescriptionExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: const Color(0xFF800020),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ),

              // BOTTOM PANEL
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.isAdmin) ...[
                        // QUANTITY
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Color(0xFFD87F7F)),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD87F7F),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFFD87F7F)),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // PRICE
                      Text(
                        'Cena: ${totalPriceRsd.toStringAsFixed(2)} RSD',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD87F7F),
                        ),
                      ),
                      if (!widget.isAdmin && totalPriceEur != null)
                        Text(
                          '≈ ${totalPriceEur.toStringAsFixed(2)} EUR',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 12),

                      // BUTTONS ROW
                      Row(
                        children: [
                          // COMMENTS BUTTON
                          Expanded(
                            child: _gradientButton(
                              icon: Icons.comment,
                              text: 'Komentari',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommentsScreen(
                                      productId: _product.id, // samo ovo prosleđujemo
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          // ADMIN BUTTONS OR ADD TO CART
                          Expanded(
                            child: widget.isAdmin
                                ? _buildAdminButtons(context, productVM)
                                : _gradientButton(
                              icon: Icons.shopping_cart,
                              text: 'Dodaj u korpu',
                              onTap: () async {
                                if (isGuest) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const LoginScreen()),
                                  );
                                } else {
                                  await cartProvider.addToCart(
                                      _product, _quantity);
                                  _showPinkSnackBar(
                                      context, 'Proizvod dodat u korpu!');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ADMIN BUTTONS =================
  Widget _buildAdminButtons(
      BuildContext context, ProductViewModel productVM) {
    return Column(
      children: [
        _gradientButton(
          icon: Icons.edit,
          text: 'Izmeni',
          onTap: () => _showEditDialog(context, productVM),
        ),
        const SizedBox(height: 6),
        _gradientButton(
          icon: Icons.delete,
          text: 'Obriši',
          onTap: () => _confirmDelete(context, productVM),
        ),
      ],
    );
  }

  // ================= EDIT PRODUCT DIALOG =================
  void _showEditDialog(
      BuildContext context, ProductViewModel productVM) async {
    final nameCtrl = TextEditingController(text: _product.name);
    final descCtrl = TextEditingController(text: _product.description);
    final priceCtrl =
    TextEditingController(text: _product.price.toString());
    bool isPopular = _product.popular;
    XFile? selectedImage;
    final picker = ImagePicker();

    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
    int selectedCategoryId = _product.categoryId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF5F7),
              title: const Text(
                'Izmeni proizvod',
                style: TextStyle(color: Color(0xFFD87F7F)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NAZIV, OPIS, CENA
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Naziv')),
                    TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Opis'), maxLines: 3),
                    TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Cena'), keyboardType: TextInputType.number),

                    const SizedBox(height: 12),

                    // POPULAR
                    CheckboxListTile(
                      value: isPopular,
                      activeColor: const Color(0xFFD87F7F),
                      title: const Text('Popularan'),
                      onChanged: (val) => setDialogState(() => isPopular = val ?? false),
                    ),

                    const SizedBox(height: 12),

                    // DROPDOWN KATEGORIJA
                    ValueListenableBuilder<List<Category>>(
                      valueListenable: categoryVM.categories,
                      builder: (context, categories, child) {
                        return DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Kategorija',
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedCategoryId = val);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // IZBOR SLIKE
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image, color: Color(0xFFD87F7F)),
                      label: Text(selectedImage == null ? 'Promeni sliku' : 'Izabrano', style: const TextStyle(color: Color(0xFFD87F7F))),
                      onPressed: () async {
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) setDialogState(() => selectedImage = picked);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFD87F7F)),
                  child: const Text('Otkaži'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String imageUrl = _product.imageUrl;
                    if (selectedImage != null) {
                      imageUrl = await uploadImageToCloudinary(selectedImage!);
                    }

                    final updatedProduct = Product(
                      id: _product.id,
                      categoryId: selectedCategoryId,
                      name: nameCtrl.text,
                      description: descCtrl.text,
                      price: double.parse(priceCtrl.text),
                      popular: isPopular,
                      imageUrl: imageUrl,
                    );

                    await productVM.updateProduct(updatedProduct);

                    setState(() {
                      _product = updatedProduct; // OSVEŽI EKRAN
                    });

                    Navigator.pop(context);
                    _showPinkSnackBar(context, 'Proizvod izmenjen!');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD87F7F)),
                  child: const Text('Sačuvaj', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= CONFIRM DELETE =================
  void _confirmDelete(BuildContext context, ProductViewModel productVM) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Brisanje'),
        content: const Text('Da li ste sigurni da želite da obrišete proizvod?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD87F7F)),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            onPressed: () async {
              await productVM.deleteProduct(_product.id);
              Navigator.pop(context);
              Navigator.pop(context);
              _showPinkSnackBar(context, 'Proizvod obrisan!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD87F7F)),
            child: const Text('Da', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= GRADIENT BUTTON =================
  Widget _gradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC1CC), Color(0xFFFADADD)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Spinnaker',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PINK SNACKBAR =================
  void _showPinkSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
              fontFamily: 'Spinnaker',
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: const Color(0xFFFFC1CC),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ================= CLOUDINARY UPLOAD =================
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
