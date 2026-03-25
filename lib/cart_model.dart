import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final double price;
  String sugarLevel;
  String iceLevel;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    this.sugarLevel = '正常',
    this.iceLevel = '正常冰',
    this.quantity = 1,
  });

  // A unique ID for each item based on its properties
  String get id => '$name-$sugarLevel-$iceLevel';
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice =>
      _items.fold(0, (total, current) => total + current.price * current.quantity);
      
  int get totalCups => _items.fold(0, (total, current) => total + current.quantity);

  void add(CartItem item) {
    // Check if an item with the same id is already in the cart
    for (var cartItem in _items) {
      if (cartItem.id == item.id) {
        cartItem.quantity += item.quantity;
        notifyListeners();
        return;
      }
    }
    _items.add(item);
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }
  
  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
