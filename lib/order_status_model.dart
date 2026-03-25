import 'package:flutter/foundation.dart';
import 'package:tea_go_app/cart_model.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime orderDate;
  String status; // e.g., '制作中', '待取餐'

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderDate,
    this.status = '制作中',
  });
}

class OrderStatusModel extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  List<Order> get inProgressOrders =>
      _orders.where((o) => o.status == '制作中').toList();

  List<Order> get readyForPickupOrders =>
      _orders.where((o) => o.status == '待取餐').toList();

  void placeOrder(List<CartItem> items, double total) {
    final newOrder = Order(
      id: 'Order #${_orders.length + 1}',
      items: List.from(items),
      total: total,
      orderDate: DateTime.now(),
    );
    _orders.add(newOrder);
    notifyListeners();
  }

  // In a real app, you'd have a system to update this status.
  // For now, let's just add a dummy method to simulate it.
  void moveOrderToPickup(Order order) {
    order.status = '待取餐';
    notifyListeners();
  }
}
