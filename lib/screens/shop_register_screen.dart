import 'dart:convert';
import 'dart:io';

import 'package:admin_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_snackbar.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();

  bool isLoading = false;
  File? _imageFile;
  String? _base64Image;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _base64Image = base64Encode(imageBytes);
      });
    }
  }

  Future<void> registerShop() async {
    if (shopNameController.text.isEmpty ||
        ownerNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        mobileController.text.isEmpty ||
        _base64Image == null) {
      showErrorSnackBar(
          context, "Please fill in all details and select an image.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('shops').add({
        'shopName': shopNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'address': addressController.text.trim(),
        'mobile': mobileController.text.trim(),
        'uid': user?.uid,
        'image': _base64Image,
        'timestamp': Timestamp.now(),
      });

      showSuccessSnackBar(context, "Store Registered Successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      shopNameController.clear();
      ownerNameController.clear();
      addressController.clear();
      mobileController.clear();
      setState(() {
        _imageFile = null;
        _base64Image = null;
      });
    } catch (e) {
      showErrorSnackBar(context, "Something went wrong. Try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Registration"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "List Your Local Store 🛍️",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Reach nearby customers instantly and boost your sales",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Image Upload Section
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? const Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Tap to upload store image",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Input Fields
                    buildTextField(
                        "Store Name", Icons.store, shopNameController),
                    const SizedBox(height: 16),
                    buildTextField(
                        "Owner Name", Icons.person, ownerNameController),
                    const SizedBox(height: 16),
                    buildTextField(
                        "Store Address", Icons.location_on, addressController),
                    const SizedBox(height: 16),
                    buildTextField("Contact Number", Icons.phone,
                        mobileController, TextInputType.phone),
                    const SizedBox(height: 24),

                    // Submit Button
                    GestureDetector(
                      onTap: isLoading ? null : registerShop,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
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

  Widget buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
