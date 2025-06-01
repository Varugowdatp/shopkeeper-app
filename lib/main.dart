import 'package:admin_app/screens/add_product_screen.dart';
import 'package:admin_app/screens/manage_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_screen.dart';
import 'screens/shop_register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NearBuy - Admin',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashLoadingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const ShopRegisterScreen(),
        '/orders': (context) => ManageOrdersScreen(),
        '/add-product': (context) => AddProductScreen(),
      },
    );
  }
}

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  @override
  void initState() {
    super.initState();
    navigateAfterLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NearBuy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.purpleAccent),
            SizedBox(height: 10),
            Text(
              "Bringing local shops to life...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.purpleAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> navigateAfterLogin(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2));
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  final shopSnapshot = await FirebaseFirestore.instance
      .collection('shops')
      .where('uid', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (shopSnapshot.docs.isNotEmpty) {
    final shopId = shopSnapshot.docs.first.id;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  } else {
    Navigator.pushReplacementNamed(context, '/register');
  }
}
