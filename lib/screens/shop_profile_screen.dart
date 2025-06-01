import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({
    super.key,
    required String shopName,
    required String ownerName,
  });

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  String email = '';
  String ownerName = '';
  String shopName = '';
  String location = '';
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    email = user?.email ?? '';

    final query = await FirebaseFirestore.instance
        .collection('shops')
        .where('uid', isEqualTo: user?.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      setState(() {
        ownerName = data['ownerName'] ?? 'Owner';
        shopName = data['shopName'] ?? '';
        location = data['address'] ??
            ''; // fallback to 'address' if 'location' missing
        imageBase64 = data['image']; // optional image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purpleAccent],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Profile 👤",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: $email",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (imageBase64 != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                base64Decode(imageBase64!),
                height: 180,
                width: 180,
                fit: BoxFit.cover,
              ),
            )
          else
            const Text("📷 No image uploaded"),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  profileTile("👨‍💼", "Owner", ownerName),
                  const Divider(),
                  profileTile("🏪", "Shop Name", shopName),
                  const Divider(),
                  profileTile("📍", "Location", location),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileTile(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
