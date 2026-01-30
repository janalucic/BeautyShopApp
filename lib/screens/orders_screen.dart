import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
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
  Map<String, String> _userNames = {}; // userId -> name

  String _searchQuery = '';
  String _statusFilter = 'Svi';

  @override
  void initState() {
    super.initState();
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyProvider>().fetchEurRate();
    });
  }

  Future<void> _loadData() async {
    await _loadUsers();
    await _loadProducts();
    await _loadOrders();
    setState(() => _isLoading = false);
  }

  Future<void> _loadUsers() async {
    final snapshot = await FirebaseDatabase.instance.ref('Users').get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as dynamic);
    _userNames.clear();
    data.forEach((key, value) {
      final u = Map<String, dynamic>.from(value);
      _userNames[key] = u['name'] ?? 'Nepoznat korisnik';
    });
  }

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

  Future<void> _loadOrders() async {
    final userProvider = context.read<UserProvider>();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseDatabase.instance.ref('Orders').get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

    _orders = data.entries
        .map((e) {
      final orderMap = Map<String, dynamic>.from(e.value);
      orderMap['id'] = e.key;
      return orderMap;
    })
        .where((order) =>
    userProvider.isAdmin || order['userId'].toString() == user.uid)
        .toList();
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'obrađuje se':
        color = const Color(0xFFD87F7F); // zlatno-bordo
        break;
      case 'poslato':
        color = const Color(0xFF800080); // tamno ljubičasta
        break;
      case 'isporučeno':
        color = const Color(0xFF6AA84F); // topla zelena
        break;
      case 'otkazano':
        color = const Color(0xFF800020); // crvena bordo
        break;
      default:
        color = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.4), color.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.25), blurRadius: 4, offset: const Offset(2,2))
        ],
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

  void _editStatus(Map<String, dynamic> order) {
    final allowedStatuses = ['obrađuje se', 'poslato', 'isporučeno', 'otkazano'];
    String selectedStatus = order['status'] ?? 'obrađuje se';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF800020),
          title: const Text(
            'Izmeni status porudžbine',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allowedStatuses.map((status) {
                return RadioListTile<String>(
                  title: Text(status, style: const TextStyle(color: Colors.white)),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedStatus = value);
                  },
                  activeColor: Colors.white,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Otkaži', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF800020),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Ažuriraj status u Firebase
                await FirebaseDatabase.instance
                    .ref('Orders/${order['id']}')
                    .update({'status': selectedStatus});

                // Ažuriraj status u glavnoj listi da se odmah vidi
                final index = _orders.indexWhere((o) => o['id'] == order['id']);
                if (index != -1) {
                  setState(() {
                    _orders[index]['status'] = selectedStatus;
                  });
                }

                Navigator.pop(context);
              },
              child: const Text('Sačuvaj'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Potvrda brisanja', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Da li ste sigurni da želite da obrišete ovu porudžbinu?\nOva akcija se ne može poništiti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ne', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800020),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await FirebaseDatabase.instance.ref('Orders/${order['id']}').remove();
              setState(() => _orders.remove(order));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Porudžbina je uspešno obrisana.')),
              );
            },
            child: const Text('Da', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final statuses = ['Svi', 'obrađuje se', 'poslato', 'isporučeno', 'otkazano'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Pretraži po imenu korisnika ...',
              hintStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
              filled: true,
              fillColor: Colors.white.withOpacity(0.95),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
              ],
            ),
            child: DropdownButton<String>(
              value: _statusFilter,
              underline: const SizedBox(),
              isExpanded: true,
              items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _statusFilter = value ?? 'Svi'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final isAdmin = context.watch<UserProvider>().isAdmin;

    final filteredOrders = _orders.where((order) {
      final name = _userNames[order['userId']] ?? '';
      final matchesName = name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'Svi' || order['status'] == _statusFilter;
      return matchesName && matchesStatus;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/boxes.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Porudžbine',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2,2)),
                    ],
                  ),
                ),
                _buildFilters(),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFD87F7F)))
                      : filteredOrders.isEmpty
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
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final items = List<dynamic>.from(order['items'] ?? []);
                      final userName = _userNames[order['userId']] ?? 'Nepoznat korisnik';

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white.withOpacity(0.95),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF800020)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'ID: ${order['id']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD87F7F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (isAdmin)
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color(0xFF800020)),
                                          onPressed: () => _confirmDeleteOrder(order),
                                        ),
                                      GestureDetector(
                                        onTap: isAdmin ? () => _editStatus(order) : null,
                                        child: _statusBadge(order['status'] ?? 'nepoznato'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...items.map((item) {
                                final productId = item['productId'];
                                final productName = _productNames[productId] ?? 'Nepoznat proizvod';
                                return Text('• $productName (x${item['quantity']})');
                              }),
                              const Divider(height: 20),
                              Builder(
                                builder: (_) {
                                  final totalPrice = (order['totalPrice'] ?? 0).toDouble();
                                  final pdv = (totalPrice * 0.05).roundToDouble();
                                  const postarina = 350.0;
                                  final finalPrice = totalPrice + pdv + postarina;
                                  final double? finalPriceEur = currencyProvider.convertToEur(finalPrice);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ukupno: ${totalPrice.toInt()} RSD', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('PDV (5%): ${pdv.toInt()} RSD', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text('Poštarina: ${postarina.toInt()} RSD', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Za naplatu: ${finalPrice.toInt()} RSD'
                                            '${(finalPriceEur != null && !currencyProvider.isLoading) ? ' ≈ ${finalPriceEur.toStringAsFixed(2)} EUR' : ''}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD87F7F),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
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
