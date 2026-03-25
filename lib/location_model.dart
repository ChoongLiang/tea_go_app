import 'package:flutter/foundation.dart';

class LocationModel extends ChangeNotifier {
  final List<String> _stalls = [
    'Stall A - Kuala Lumpur',
    'Stall B - Petaling Jaya',
    'Stall C - Shah Alam',
    'Stall D - Subang Jaya',
  ];

  String _selectedStall = 'Stall A - Kuala Lumpur';

  List<String> get stalls => _stalls;
  String get selectedStall => _selectedStall;

  void selectStall(String stall) {
    _selectedStall = stall;
    notifyListeners();
  }
}
