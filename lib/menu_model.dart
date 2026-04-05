import 'package:flutter/foundation.dart';

class MenuModel extends ChangeNotifier {
  String? _activeCategory;
  String? get activeCategory => _activeCategory;

  void setCategory(String? category) {
    _activeCategory = category;
    notifyListeners();
  }
}
