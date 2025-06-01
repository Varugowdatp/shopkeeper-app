import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final List<String> _base64Images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      for (XFile img in images) {
        Uint8List imgBytes = await img.readAsBytes();
        String base64Str = base64Encode(imgBytes);
        setState(() {
          _base64Images.add(base64Str);
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _base64Images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and add images")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      // Fetch the shop document associated with the current user
      final shopQuery = await FirebaseFirestore.instance
          .collection('shops')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (shopQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Shop not found for this user.")),
        );
        setState(() => _isSaving = false);
        return;
      }

      final shopDoc = shopQuery.docs.first;
      final shopId = shopDoc.id;
      final ownerName = shopDoc['ownerName'];

      await FirebaseFirestore.instance.collection('products').add({
        'uid': uid,
        'shopId': shopId,
        'ownerName': ownerName,
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descController.text.trim(),
        'images': _base64Images,
        'createdAt': Timestamp.now(),
      });

      setState(() => _isSaving = false);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget _buildImagePreview() {
    return _base64Images.isEmpty
        ? GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purpleAccent),
              ),
              child: const Center(
                child: Text("📷 Tap to add product images",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          )
        : SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _base64Images.length + 1,
              itemBuilder: (context, index) {
                if (index == _base64Images.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 32),
                    ),
                  );
                }

                final base64 = _base64Images[index];
                return Container(
                  margin: const EdgeInsets.all(8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(base64Decode(base64)),
                    ),
                  ),
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product 🛍️"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "✨ Let’s show the world what you’ve got!",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration("Product Name"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Name required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Price (₹)"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Price required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: _inputDecoration("Short Description"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Add a description" : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProduct,
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: Text(_isSaving ? "Saving..." : "Save Product",
                        style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.pink.shade50,
    );
  }
}
