import 'package:flutter/foundation.dart';

class LocationModel extends ChangeNotifier {
  final List<String> _stalls = [
    'Stall A - Kuala Lumpur',
    'Stall B - Petaling Jaya',
    'Stall C - Shah Alam',
    'Stall D - Subang Jaya',
  ];

  // Mock queue/wait/distance data per stall
  final Map<String, Map<String, String>> stallDetails = {
    'Stall A - Kuala Lumpur': {'queue': 'Busy',     'wait': '~20 min', 'distance': '0.2 km'},
    'Stall B - Petaling Jaya': {'queue': 'Moderate', 'wait': '~10 min', 'distance': '1.5 km'},
    'Stall C - Shah Alam':     {'queue': 'Quiet',    'wait': '~5 min',  'distance': '3.2 km'},
    'Stall D - Subang Jaya':   {'queue': 'Busy',     'wait': '~25 min', 'distance': '5.8 km'},
  };

  String _selectedStall = 'Stall A - Kuala Lumpur';

  List<String> get stalls => _stalls;
  String get selectedStall => _selectedStall;
  Map<String, String> get selectedStallDetails =>
      stallDetails[_selectedStall] ?? {'queue': 'Quiet', 'wait': '~5 min', 'distance': '—'};

  void selectStall(String stall) {
    _selectedStall = stall;
    notifyListeners();
  }
}
