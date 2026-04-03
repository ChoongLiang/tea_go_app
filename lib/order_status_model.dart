import 'package:flutter/foundation.dart';
import 'package:tea_go_app/cart_model.dart';

class Order {
  final String id;           // booking ID for system records
  final String queueNumber;  // short customer-facing number e.g. "042"
  final List<CartItem> items;
  final double total;
  final DateTime orderDate;
  final String outlet;
  final String pickupTime;
  int stage; // 1: Placed, 2: Preparing, 3: Ready

  Order({
    required this.id,
    required this.queueNumber,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.outlet,
    this.pickupTime = 'ASAP (~15 min)',
    this.stage = 2,
  });
}

class OrderStatusModel extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  List<Order> get inProgressOrders =>
      _orders.where((o) => o.stage == 1 || o.stage == 2).toList();

  List<Order> get readyForPickupOrders =>
      _orders.where((o) => o.stage == 3).toList();

  // Get the most recent order to display
  Order? get latestOrder => _orders.isNotEmpty ? _orders.last : null;

  void placeOrder(List<CartItem> items, double total, {String outlet = '', String? orderId, String queueNumber = '001', String pickupTime = 'ASAP (~15 min)'}) {
    final epoch = DateTime(2025).millisecondsSinceEpoch;
    final newOrder = Order(
      id: orderId ?? '#TG-${(DateTime.now().millisecondsSinceEpoch - epoch).toRadixString(36).toUpperCase()}',
      queueNumber: queueNumber,
      items: List.from(items),
      total: total,
      orderDate: DateTime.now().toUtc(),
      outlet: outlet,
      pickupTime: pickupTime,
    );
    _orders.add(newOrder);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  // Simulates the order progressing to the next stage
  void advanceOrderStatus(Order order) {
    if (order.stage < 3) {
      order.stage++;
      notifyListeners();
    }
  }
}
