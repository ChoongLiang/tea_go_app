import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Consumer<OrderStatusModel>(
        builder: (context, orderStatus, child) {
          if (orderStatus.orders.isEmpty) {
            return const Center(
              child: Text(
                'You have no past orders.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: orderStatus.orders.length,
            itemBuilder: (context, index) {
              final order = orderStatus.orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text('${order.id} - RM ${order.total.toStringAsFixed(2)}'),
                  subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(order.orderDate)),
                  children: order.items.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.sugarLevel}, ${item.iceLevel}'),
                      trailing: Text('x${item.quantity}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
