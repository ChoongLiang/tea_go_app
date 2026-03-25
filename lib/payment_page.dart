import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/payment_success_page.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          double subtotal = cart.totalPrice;
          double sst = subtotal * 0.06;
          double serviceTax = subtotal * 0.10;
          double grandTotal = subtotal + sst + serviceTax;
          double roundedTotal = (grandTotal * 20).round() / 20;
          double roundingAdjustment = roundedTotal - grandTotal;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildSummaryRow('Subtotal(MYR):', subtotal),
                const SizedBox(height: 10),
                _buildSummaryRow('SST 6%', sst),
                const SizedBox(height: 10),
                _buildSummaryRow('Service Tax 10%', serviceTax),
                const SizedBox(height: 10),
                _buildSummaryRow('Rounding adjustment', roundingAdjustment),
                const Divider(height: 30, thickness: 1),
                _buildTotalRow('Total (MYR)', roundedTotal),
                const Spacer(),
                _buildPayNowButton(context, roundedTotal),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(amount.toStringAsFixed(2), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildTotalRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(amount.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkMatchaGreen)),
      ],
    );
  }

  Widget _buildPayNowButton(BuildContext context, double total) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkMatchaGreen,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PaymentSuccessPage(totalAmount: total)),
          );
        },
        child: Text(
          'Pay Now - RM ${total.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
