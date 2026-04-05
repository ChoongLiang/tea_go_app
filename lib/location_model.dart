import 'package:flutter/foundation.dart';

enum StallStatus { open, closed }

enum QueueStatus { notBusy, moderate, busy, veryBusy }

class StallInfo {
  final String id;
  final String name;
  final StallStatus status;
  final int distanceM;
  final int ordersInLine;
  final int estimatedPickupMinutes;
  final QueueStatus queueStatus;
  final String address;
  final String phone;
  final String openHours;

  const StallInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.distanceM,
    required this.ordersInLine,
    required this.estimatedPickupMinutes,
    required this.queueStatus,
    required this.address,
    required this.phone,
    required this.openHours,
  });

  bool get isOpen => status == StallStatus.open;

  String get distanceLabel {
    if (distanceM < 1000) return '${distanceM}m away';
    return '${(distanceM / 1000).toStringAsFixed(1)} km away';
  }

  String get queueLabel {
    switch (queueStatus) {
      case QueueStatus.notBusy:  return 'Not Busy';
      case QueueStatus.moderate: return 'Moderate';
      case QueueStatus.busy:     return 'Busy';
      case QueueStatus.veryBusy: return 'Very Busy';
    }
  }
}

class LocationModel extends ChangeNotifier {
  final List<StallInfo> _stalls = const [
    StallInfo(
      id: 'factory_gate_a',
      name: 'BULA Factory Gate A',
      status: StallStatus.open,
      distanceM: 120,
      ordersInLine: 6,
      estimatedPickupMinutes: 7,
      queueStatus: QueueStatus.moderate,
      address: 'Lot 12, Jalan Perusahaan 1, Kawasan Perindustrian Subang, 40150 Shah Alam, Selangor',
      phone: '+603-5565 1234',
      openHours: 'Mon – Fri  7:00 AM – 6:00 PM\nSat  8:00 AM – 3:00 PM\nSun  Closed',
    ),
    StallInfo(
      id: 'ss15_subang',
      name: 'BULA SS15 Subang',
      status: StallStatus.open,
      distanceM: 1500,
      ordersInLine: 2,
      estimatedPickupMinutes: 4,
      queueStatus: QueueStatus.notBusy,
      address: '27, Jalan SS 15/4, SS 15, 47500 Subang Jaya, Selangor',
      phone: '+603-5631 8800',
      openHours: 'Daily  9:00 AM – 10:00 PM',
    ),
    StallInfo(
      id: 'shah_alam_central',
      name: 'BULA Shah Alam Central',
      status: StallStatus.open,
      distanceM: 3200,
      ordersInLine: 11,
      estimatedPickupMinutes: 15,
      queueStatus: QueueStatus.busy,
      address: 'G-05, Shah Alam City Centre, Persiaran Masjid, Seksyen 14, 40000 Shah Alam, Selangor',
      phone: '+603-5510 2299',
      openHours: 'Daily  10:00 AM – 10:00 PM',
    ),
    StallInfo(
      id: 'subang_usj',
      name: 'BULA Subang USJ',
      status: StallStatus.closed,
      distanceM: 5800,
      ordersInLine: 0,
      estimatedPickupMinutes: 0,
      queueStatus: QueueStatus.notBusy,
      address: 'B-18, USJ Summit, Persiaran Kewajipan, USJ 1, 47600 Subang Jaya, Selangor',
      phone: '+603-8023 7700',
      openHours: 'Mon – Fri  8:00 AM – 8:00 PM\nSat – Sun  9:00 AM – 7:00 PM',
    ),
  ];

  StallInfo _selectedStall = const StallInfo(
    id: 'factory_gate_a',
    name: 'BULA Factory Gate A',
    status: StallStatus.open,
    distanceM: 120,
    ordersInLine: 6,
    estimatedPickupMinutes: 7,
    queueStatus: QueueStatus.moderate,
    address: 'Lot 12, Jalan Perusahaan 1, Kawasan Perindustrian Subang, 40150 Shah Alam, Selangor',
    phone: '+603-5565 1234',
    openHours: 'Mon – Fri  7:00 AM – 6:00 PM\nSat  8:00 AM – 3:00 PM\nSun  Closed',
  );

  List<StallInfo> get stalls => _stalls;
  StallInfo get selectedStall => _selectedStall;

  void selectStall(StallInfo stall) {
    _selectedStall = stall;
    notifyListeners();
  }

  // Legacy helper — used when only the name string is needed
  String get selectedStallName => _selectedStall.name;
}
