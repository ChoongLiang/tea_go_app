import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/home_page.dart';
import 'package:tea_go_app/order_status_model.dart';

class PaymentSuccessPage extends StatefulWidget {
  final double totalAmount;
  const PaymentSuccessPage({super.key, required this.totalAmount});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    
    var cart = Provider.of<CartModel>(context, listen: false);
    var orderStatus = Provider.of<OrderStatusModel>(context, listen: false);

    // Create the order
    orderStatus.placeOrder(cart.items, widget.totalAmount);
    
    // Clear the cart
    cart.clear();

    // Navigate after a delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to HomePage
          (Route<dynamic> route) => false,
        );
        // Ideally, you'd also switch the tab on HomePage to the Orders tab.
        // This requires a bit more state management on the HomePage itself.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text('Payment Successful!', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
