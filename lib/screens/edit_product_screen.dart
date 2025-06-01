import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final DocumentSnapshot product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product['name'];
    descController.text = widget.product['description'];
    priceController.text = widget.product['price'].toString();
  }

  Future<void> updateProduct() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id)
        .update({
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Product updated")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Edit Product"),
          backgroundColor: Colors.purpleAccent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent),
              onPressed: updateProduct,
              child: const Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}
