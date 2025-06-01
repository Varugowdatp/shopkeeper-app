import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final DocumentSnapshot product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    final List<dynamic> base64Images = data['images'] ?? [];

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        title: const Text("🎀 Product Details"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            tooltip: "Edit Product",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            tooltip: "Delete Product",
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Product"),
                  content: const Text(
                      "Are you sure you want to delete this product?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: const Text("Delete",
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(product.id)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product deleted")),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔁 Scrollable Images
            if (base64Images.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: base64Images.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(base64Images[index]),
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              )
            else
              const Text("📷 No images available",
                  style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 24),

            // 🧁 Product Info Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔤 Name
                    Text(
                      data['name'] ?? 'Unnamed Product',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 💸 Price
                    Row(
                      children: [
                        const Icon(Icons.attach_money_rounded,
                            color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          "₹${data['price']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 📝 Description
                    const Text(
                      "📝 Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description provided.',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 20),

                    // 📅 Created Date
                    if (data['createdAt'] != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            data['createdAt']
                                .toDate()
                                .toLocal()
                                .toString()
                                .split('.')[0],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
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
    );
  }
}
