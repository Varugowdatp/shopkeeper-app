import 'package:flutter/material.dart';

class Order {
  final String orderId;
  final String customerName;
  final String date;
  final double amount;
  final List<String> items;
  String status; // "Pending", "Accepted", "Rejected"

  Order({
    required this.orderId,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.items,
    this.status = "Pending",
  });
}

class ManageOrdersScreen extends StatefulWidget {
  @override
  _ManageOrdersScreenState createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Order> dummyOrders = [
    Order(
      orderId: "#ORD1001",
      customerName: "Aarav Joshi",
      date: "2025-05-25",
      amount: 749.0,
      items: ["Dog Food", "Chew Toy"],
    ),
    Order(
      orderId: "#ORD1002",
      customerName: "Meera Kapoor",
      date: "2025-05-24",
      amount: 1299.5,
      items: ["Cat Litter", "Scratching Pad"],
    ),
    Order(
      orderId: "#ORD1003",
      customerName: "Kunal Desai",
      date: "2025-05-23",
      amount: 499.0,
      items: ["Pet Shampoo"],
    ),
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Manage Orders"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: ListView.builder(
        itemCount: dummyOrders.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final order = dummyOrders[index];

          return Card(
            elevation: 5,
            margin: const EdgeInsets.only(bottom: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Customer & Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.customerName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${order.amount.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),

                  /// Order ID & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order ID: ${order.orderId}",
                          style: TextStyle(color: Colors.grey[700])),
                      Text("Date: ${order.date}",
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  SizedBox(height: 10),

                  /// Items
                  Text("Items: ${order.items.join(", ")}"),
                  SizedBox(height: 10),

                  /// Status Chip
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          order.status,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: getStatusColor(order.status),
                      ),
                      Spacer(),

                      /// Accept & Reject Buttons
                      if (order.status == "Pending") ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () {
                            setState(() {
                              order.status = "Accepted";
                            });
                          },
                          child: Text("Accept",
                              style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            setState(() {
                              order.status = "Rejected";
                            });
                          },
                          child: Text(
                            "Reject",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
