import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/home_page.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/order_status_model.dart';

class PaymentSuccessPage extends StatefulWidget {
  final double totalAmount;
  final String pickupTime;
  final String paymentMethod;
  const PaymentSuccessPage({super.key, required this.totalAmount, this.pickupTime = 'ASAP (~15 min)', this.paymentMethod = 'Touch\'n Go'});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var cart = Provider.of<CartModel>(context, listen: false);
      var orderStatus = Provider.of<OrderStatusModel>(context, listen: false);
      var location = Provider.of<LocationModel>(context, listen: false);

      final epoch = DateTime(2025).millisecondsSinceEpoch;
      final orderId = '#TG-${(DateTime.now().millisecondsSinceEpoch - epoch).toRadixString(36).toUpperCase()}';
      final authService = AuthService();
      final queueNumber = await authService.getNextQueueNumber();

      // Save to Firestore
      await authService.saveOrder(
        orderId: orderId,
        queueNumber: queueNumber,
        paymentMethod: widget.paymentMethod,
        items: cart.items,
        total: widget.totalAmount,
        outlet: location.selectedStallName,
      );

      // Update local state with the same ID
      orderStatus.placeOrder(cart.items, widget.totalAmount, outlet: location.selectedStallName, orderId: orderId, queueNumber: queueNumber, pickupTime: widget.pickupTime);

      // Clear the cart
      cart.clear();
    });

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
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 100),
            const SizedBox(height: 20),
            Text('Payment Successful!', style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text('Redirecting to your orders…', style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
