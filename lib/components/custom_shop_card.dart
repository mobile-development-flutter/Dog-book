import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomShopCard extends StatefulWidget {
  final Map<String, dynamic> shopItem;
  final void Function(Map<String, dynamic> item, int quantity) onAddToCart;
  final void Function(Map<String, dynamic> item, int quantity) onBuyNow;
  final void Function(dynamic item, dynamic qty) onCartUpdate;

  const CustomShopCard({
    super.key,
    required this.shopItem,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onCartUpdate,
  });

  @override
  State<CustomShopCard> createState() => _CustomShopCardState();
}

class _CustomShopCardState extends State<CustomShopCard> {
  int quantity = 1;

  void increment() => setState(() => quantity++);
  void decrement() => setState(() => quantity > 1 ? quantity-- : quantity);

  @override
  Widget build(BuildContext context) {
    final item = widget.shopItem;
    final price =
        (item['price'] is String)
            ? double.tryParse(item['price']) ?? 0.0
            : (item['price'] as num).toDouble();
    final totalPrice = price * quantity;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image (if available)
          if (item['imageUrl'] != null && item['imageUrl'].isNotEmpty)
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item['imageUrl']),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),

          SizedBox(height: 10.h),
          Text(
            item['name'] ?? 'No Name',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),

          Text(
            item['type'] ?? 'No Type',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12.sp),
          ),

          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                "(${price.toStringAsFixed(2)} x $quantity)",
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12.sp,
                ),
              ),
              Icon(Icons.attach_money, size: 15.w, color: Colors.grey[700]),
            ],
          ),

          Row(
            children: [
              Text(
                "Total: ${totalPrice.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              Icon(Icons.attach_money, size: 17.w, color: Colors.green[700]),
            ],
          ),

          SizedBox(height: 8.h),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: decrement,
              ),
              Text(
                quantity.toString(),
                style: GoogleFonts.poppins(fontSize: 12.sp),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: increment,
              ),
            ],
          ),

          // Action Buttons
          Row(
            children: [
              // Add to Cart Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38B6FF),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                onPressed: () {
                  widget.onAddToCart(item, quantity);
                  _addToCartInFirebase(item, quantity);
                },
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text("Add", style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              ),

              const Spacer(),

              // Buy Now Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                onPressed: () {
                  widget.onAddToCart(item, quantity);
                  widget.onBuyNow(item, quantity);
                  context.go('/cartbuy');
                },
                child: Text("Buy", style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // **Save to Firebase Firestore**
  Future<void> _addToCartInFirebase(
    Map<String, dynamic> item,
    int quantity,
  ) async {
    try {
      final price =
          (item['price'] is String)
              ? double.tryParse(item['price']) ?? 0.0
              : (item['price'] as num).toDouble();

      final cartItem = {
        'productId': item['id'] ?? '', // Ensure null safety
        'name': item['name'] ?? 'No Name',
        'price': price,
        'quantity': quantity,
        'totalPrice': (price * quantity),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('cart').add(cartItem);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added to cart!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
