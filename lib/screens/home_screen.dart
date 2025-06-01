import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shop_profile_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String shopName = '';
  String ownerName = '';
  int totalProducts = 0;
  double totalRevenue = 0.0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchShopDetails();
  }

  Future<void> fetchShopDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch shop name and owner
    final query = await FirebaseFirestore.instance
        .collection('shops')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      setState(() {
        shopName = data['shopName'] ?? 'My Shop';
        ownerName = data['ownerName'] ?? 'Shop Owner';
      });
    }

    // Fetch products count and revenue
    final productsSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('uid', isEqualTo: user.uid)
        .get();

    int productCount = productsSnapshot.docs.length;
    double revenue = 0.0;

    for (var doc in productsSnapshot.docs) {
      final price = double.tryParse(doc['price'].toString()) ?? 0.0;
      revenue += price;
    }

    setState(() {
      totalProducts = productCount;
      totalRevenue = revenue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      buildDashboard(),
      const ProductListScreen(),
      ShopProfileScreen(shopName: shopName, ownerName: ownerName),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("🏬 $shopName",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => showLogoutDialog(context),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.black,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text("👋 Hey $ownerName!",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Let's make some local magic happen today ✨",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          buildShopCard(),
          const SizedBox(height: 20),
          buildQuickActions(context),
          const SizedBox(height: 20),
          buildStatsCard(),
          const SizedBox(height: 20),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8),
            child: Text(
              "📦 Your Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const ProductListSection(),
        ],
      ),
    );
  }

  Widget buildShopCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.store, size: 40, color: Colors.purpleAccent),
        title: Text(shopName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text("Owned by $ownerName"),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pushNamed(context, '/edit-shop');
          },
        ),
      ),
    );
  }

  Widget buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildActionTile("➕", "Add Product", () {
          Navigator.pushNamed(context, '/add-product');
        }),
        buildActionTile("📦", "View Orders", () {
          Navigator.pushNamed(context, '/orders');
        }),
        buildActionTile("🛠", "Edit Shop", () {
          Navigator.pushNamed(context, '/edit-shop');
        }),
      ],
    );
  }

  Widget buildActionTile(String emoji, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget buildStatsCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildStatColumn(
                "Products", totalProducts.toString(), Icons.inventory),
            buildStatColumn("Revenue", "₹${totalRevenue.toStringAsFixed(2)}",
                Icons.currency_rupee),
          ],
        ),
      ),
    );
  }

  Widget buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purpleAccent, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ProductListSection extends StatelessWidget {
  const ProductListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text("No user found."));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No products added yet."),
          );
        }

        final products = snapshot.data!.docs;

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final name = product['name'];
              final price = product['price'];
              final images = product['images'] as List<dynamic>;
              final base64Image = images.isNotEmpty ? images[0] : null;

              return Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (base64Image != null)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            image: DecorationImage(
                              image: MemoryImage(base64Decode(base64Image)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                          height: 100,
                          child: Center(child: Text("No Image")),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("₹$price",
                            style: const TextStyle(color: Colors.purple)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
