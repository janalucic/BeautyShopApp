import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  Map<int, String> _productNames = {}; // productId -> naziv

  @override
  void initState() {
    super.initState();
    _loadData();

    // Fetch EUR rate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false).fetchEurRate();
    });
  }

  Future<void> _loadData() async {
    await _loadProducts();
    await _loadOrders();

    setState(() {
      _isLoading = false;
    });
  }

  // =========================
  // UČITAVANJE PROIZVODA
  // =========================
  Future<void> _loadProducts() async {
    final snapshot = await FirebaseDatabase.instance.ref('Products').get();

    if (!snapshot.exists || snapshot.value == null) return;

    final data = List<dynamic>.from(snapshot.value as List);

    for (var item in data) {
      if (item != null) {
        final map = Map<String, dynamic>.from(item);
        _productNames[map['id']] = map['name'];
      }
    }
  }

  // =========================
  // UČITAVANJE PORUDŽBINA
  // =========================
  Future<void> _loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseDatabase.instance.ref('Orders').get();

    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

    _orders = data.values
        .map((e) => Map<String, dynamic>.from(e))
        .where((o) => o['userId'].toString() == user.uid)
        .toList();
  }

  // =========================
  // STATUS BADGE
  // =========================
  Widget statusBadge(String status) {
    Color color;

    switch (status) {
      case 'obrađuje se':
        color = Colors.orange;
        break;
      case 'poslato':
        color = Colors.green;
        break;
      case 'otkazano':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/boxes.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: const Color(0x80000000)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Porudžbine',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD87F7F),
                    ),
                  )
                      : _orders.isEmpty
                      ? const Center(
                    child: Text(
                      'Trenutno nema porudžbina.',
                      style: TextStyle(
                        color: Color(0xFFD87F7F),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final items =
                      List<dynamic>.from(order['items'] ?? []);

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white.withOpacity(0.9),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    'ID porudžbine: ${order['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD87F7F),
                                    ),
                                  ),
                                  statusBadge(order['status'] ?? 'nepoznato'),
                                ],
                              ),
                              const SizedBox(height: 10),

                              ...items.map((item) {
                                final productId = item['productId'];
                                final productName =
                                    _productNames[productId] ??
                                        'Nepoznat proizvod';
                                return Text(
                                  '• $productName (x${item['quantity']})',
                                );
                              }),

                              const Divider(height: 20),

                              Builder(builder: (_) {
                                final totalPrice =
                                    order['totalPrice'] ?? 0;
                                final pdv = (totalPrice * 0.05).round();
                                final postarina = 350;
                                final finalPrice =
                                    totalPrice + pdv + postarina;

                                // Konverzija u EUR
                                final double? finalPriceEur =
                                currencyProvider.convertToEur(finalPrice);

                                return Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ukupno: $totalPrice RSD',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'PDV (5%): $pdv RSD',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Poštarina: $postarina RSD',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Za naplatu: $finalPrice RSD'
                                          '${(finalPriceEur != null && !currencyProvider.isLoading) ? ' ≈ ${finalPriceEur.toStringAsFixed(2)} EUR' : ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD87F7F),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
