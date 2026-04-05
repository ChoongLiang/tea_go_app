import 'dart:math';
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
  int stage; // 1: Placed, 2: Preparing, 3: Ready, 4: Completed

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
  int _totalFirestoreOrderCount = 0;
  Order? _latestFirestoreOrder;

  List<Order> get orders => _orders;

  // Total across all-time Firestore orders + any new in-session orders not yet in Firestore
  int get totalOrderCount => max(_orders.length, _totalFirestoreOrderCount);

  List<Order> get inProgressOrders =>
      _orders.where((o) => o.stage == 1 || o.stage == 2).toList();

  List<Order> get readyForPickupOrders =>
      _orders.where((o) => o.stage == 3).toList();

  // Latest order — in-session first, then most recent Firestore order
  Order? get latestOrder => _orders.isNotEmpty ? _orders.last : _latestFirestoreOrder;

  /// Called after fetching from Firestore (in home_page or order_status_page).
  /// [firestoreOrders] must already have 'createdAt' converted to DateTime.
  void setFirestoreData(List<Map<String, dynamic>> firestoreOrders) {
    _totalFirestoreOrderCount = firestoreOrders.length;
    if (firestoreOrders.isNotEmpty) {
      // firestoreOrders is sorted descending, so first = most recent
      final raw = firestoreOrders.first;
      final rawItems = (raw['items'] as List?) ?? [];
      _latestFirestoreOrder = Order(
        id: raw['orderId'] as String? ?? '',
        queueNumber: raw['queueNumber'] as String? ?? '001',
        items: rawItems.map((item) => CartItem(
          name: item['name'] as String? ?? '',
          price: (item['price'] as num?)?.toDouble() ?? 0,
          quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          sugarLevel: item['sugarLevel'] as String? ?? 'Normal',
          iceLevel: item['iceLevel'] as String? ?? 'Normal Ice',
          note: item['note'] as String? ?? '',
          imageUrl: item['imageUrl'] as String? ?? '',
        )).toList(),
        total: (raw['total'] as num?)?.toDouble() ?? 0,
        orderDate: raw['createdAt'] is DateTime
            ? raw['createdAt'] as DateTime
            : DateTime.now(),
        outlet: raw['outlet'] as String? ?? '',
        stage: 4, // historical = completed
      );
    }
    notifyListeners();
  }

  void placeOrder(List<CartItem> items, double total,
      {String outlet = '',
      String? orderId,
      String queueNumber = '001',
      String pickupTime = 'ASAP (~15 min)'}) {
    final epoch = DateTime(2025).millisecondsSinceEpoch;
    final newOrder = Order(
      id: orderId ??
          '#TG-${(DateTime.now().millisecondsSinceEpoch - epoch).toRadixString(36).toUpperCase()}',
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

  void advanceOrderStatus(Order order) {
    if (order.stage < 3) {
      order.stage++;
      notifyListeners();
    }
  }
}
