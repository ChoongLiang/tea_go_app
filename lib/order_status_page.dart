import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/order_status_model.dart';

// 定义与登录页一致的抹茶绿主题色
const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A); // 用于按钮和重点文字的深抹茶绿

class OrderStatusPage extends StatelessWidget {
  const OrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单状态'),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: matchaGreen,
      body: Consumer<OrderStatusModel>(
        builder: (context, orderStatus, child) {
          if (orderStatus.orders.isEmpty) {
            return const Center(
              child: Text(
                '您还没有任何订单',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (orderStatus.inProgressOrders.isNotEmpty)
                _buildStatusSection(
                  title: '制作中',
                  icon: Icons.local_fire_department,
                  orders: orderStatus.inProgressOrders,
                ),
              const SizedBox(height: 20),
              if (orderStatus.readyForPickupOrders.isNotEmpty)
                _buildStatusSection(
                  title: '待取餐',
                  icon: Icons.check_circle,
                  orders: orderStatus.readyForPickupOrders,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusSection({
    required String title,
    required IconData icon,
    required List<Order> orders,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: darkMatchaGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...orders.map((order) => _buildOrderItem(order)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              order.items.map((item) => '${item.name} x${item.quantity}').join(', '),
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(order.id, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
