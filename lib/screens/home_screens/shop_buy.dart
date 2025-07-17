// lib/screens/cart_buy_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class CartBuyScreen extends StatefulWidget {
  const CartBuyScreen({super.key, required List cartItems});

  @override
  State<CartBuyScreen> createState() => _CartBuyScreenState();
}

class _CartBuyScreenState extends State<CartBuyScreen> {
  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('cart').doc(itemId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/shop'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final cartItems =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final price = _parsePrice(data['price']);
                final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
                final totalPrice = price * quantity;

                return {
                  'id': doc.id,
                  ...data,
                  'price': price,
                  'quantity': quantity,
                  'totalPrice': totalPrice,
                  'timestamp': data['timestamp']?.toDate(),
                };
              }).toList();

          final subtotal = cartItems.fold(
            0.0,
            (sum, item) => sum + (item['totalPrice'] as double),
          );
          final shipping = subtotal * 0.1;
          final total = subtotal + shipping;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Dismissible(
                        key: Key(item['id']),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text("Confirm"),
                                  content: const Text(
                                    "Remove this item from your cart?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                          );
                        },
                        onDismissed: (direction) => _removeItem(item['id']),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading:
                                item['imageUrl'] != null
                                    ? Image.network(
                                      item['imageUrl'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.shopping_bag),
                            title: Text(item['name']?.toString() ?? 'No Name'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['quantity']} x \$${item['price'].toStringAsFixed(2)}',
                                ),
                                if (item['productId'] != null)
                                  Text(
                                    'Product ID: ${item['productId']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${item['totalPrice'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(item['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shipping:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '\$${shipping.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _processOrder(context, cartItems),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processOrder(
    BuildContext context,
    List<Map<String, dynamic>> cartItems,
  ) async {
    try {
      final subtotal = cartItems.fold(
        0.0,
        (sum, item) => sum + (item['totalPrice'] as double),
      );
      final total = subtotal * 1.1;

      await FirebaseFirestore.instance.collection('orders').add({
        'items':
            cartItems
                .map(
                  (item) => {
                    'productId': item['productId'],
                    'name': item['name'],
                    'price': item['price'],
                    'quantity': item['quantity'],
                    'imageUrl': item['imageUrl'],
                  },
                )
                .toList(),
        'subtotal': subtotal,
        'shipping': subtotal * 0.1,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      final batch = FirebaseFirestore.instance.batch();
      final cartSnapshot =
          await FirebaseFirestore.instance.collection('cart').get();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Order Successful!"),
              content: const Text("Your order has been placed successfully."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/shop');
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
    }
  }
}
