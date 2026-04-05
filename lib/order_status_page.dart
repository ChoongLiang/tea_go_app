import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/drink_image_widget.dart';
import 'package:tea_go_app/main.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/user_model.dart';

const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A);

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  List<Map<String, dynamic>> _firestoreOrders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final rawOrders = await AuthService().loadOrders();
    if (!mounted) return;
    final orders = rawOrders.map((o) {
      final ts = o['createdAt'];
      return {...o, 'createdAt': ts is Timestamp ? ts.toDate() : DateTime.now()};
    }).toList();
    setState(() { _firestoreOrders = orders; _loading = false; });
    Provider.of<OrderStatusModel>(context, listen: false).setFirestoreData(orders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Activities', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () { setState(() => _loading = true); _fetchOrders(); },
          ),
        ],
      ),
      body: Consumer<AuthModel>(
        builder: (context, auth, _) {
          if (!auth.isLoggedIn) {
            return _buildLoginWall(context);
          }
          return _loading
              ? const Center(child: CircularProgressIndicator(color: darkMatchaGreen))
              : Consumer<OrderStatusModel>(
              builder: (context, orderStatus, _) {
                // Merge: local orders take priority (have stage info), Firestore fills in the rest
                final localIds = orderStatus.orders.map((o) => o.id).toSet();
                final firestoreOnly = _firestoreOrders
                    .where((o) => !localIds.contains(o['orderId']))
                    .toList();

                if (orderStatus.orders.isEmpty && firestoreOnly.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Your order history will appear here', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (orderStatus.orders.isNotEmpty) ...[
                      _sectionLabel(context, 'Active Orders'),
                      const SizedBox(height: 10),
                      ...([...orderStatus.orders]..sort((a, b) => b.orderDate.compareTo(a.orderDate))).map((o) => _buildLocalOrderCard(context, o, orderStatus)),
                      const SizedBox(height: 20),
                    ],
                    if (firestoreOnly.isNotEmpty) ...[
                      _sectionLabel(context, 'Past Orders'),
                      const SizedBox(height: 10),
                      ...firestoreOnly.map((o) => _buildFirestoreOrderCard(o)),
                    ],
                  ],
                );
              },
            );
        },
      ),
    );
  }

  Widget _buildLoginWall(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.mutedForeground),
            const SizedBox(height: 16),
            Text('Sign in to view your orders', style: theme.textTheme.h4),
            const SizedBox(height: 8),
            Text('Your order history and active orders will appear here.',
                textAlign: TextAlign.center, style: theme.textTheme.muted),
            const SizedBox(height: 24),
            ShadButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) =>
      Text(label, style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold));

  // Card for orders in the current session (has stage info)
  Widget _buildLocalOrderCard(BuildContext context, Order order, OrderStatusModel model) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(order.queueNumber, order.id, _buildStatusBadge(order.stage)),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: _buildStepper(order.stage),
          ),
          if (order.stage < 4) _buildQueueAheadRow(order.stage),
          const Divider(height: 1),
          _buildItemsList(order.items.map((i) => {
            'name': i.name,
            'quantity': i.quantity,
            'price': i.price,
            'imageUrl': i.imageUrl,
            'sugarLevel': i.sugarLevel,
            'iceLevel': i.iceLevel,
            'note': i.note,
          }).toList()),
          const Divider(height: 1),
          _buildPickupTimeRow(order.orderDate, order.pickupTime),
          const Divider(height: 1),
          _cardFooter(order.outlet, order.orderDate, order.total),
          if (order.stage <= 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: ShadButton.ghost(
                onPressed: () => model.advanceOrderStatus(order),
                child: const Text('Advance Status (Demo)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      ),
    );
  }

  // Card for past orders loaded from Firestore
  Widget _buildFirestoreOrderCard(Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>? ?? [])
        .map((i) => Map<String, dynamic>.from(i as Map))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(order['queueNumber'] ?? '—', order['orderId'] ?? '—', _buildStatusBadge(4)),
          const Divider(height: 1),
          _buildItemsList(items),
          const Divider(height: 1),
          _cardFooter(
            order['outlet'] ?? '',
            order['createdAt'] as DateTime?,
            (order['total'] as num?)?.toDouble() ?? 0,
          ),
        ],
      ),
      ),
    );
  }

  Widget _cardHeader(String queueNumber, String bookingId, Widget badge) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('#$queueNumber', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(bookingId, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
          const Spacer(),
          badge,
        ],
      ),
    );
  }

  Widget _buildQueueAheadRow(int stage) {
    final int ahead = stage == 1 ? 5 : stage == 2 ? 2 : 0;
    final String label = ahead == 0
        ? 'Your order is next!'
        : 'There are $ahead orders ahead of you';
    final Color color = ahead == 0 ? darkMatchaGreen : Colors.orange.shade700;
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                ahead == 0 ? Icons.celebration_outlined : Icons.people_outline,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          ...items.map((item) {
            final sugar = item['sugarLevel'] as String? ?? '';
            final ice = item['iceLevel'] as String? ?? '';
            final note = item['note'] as String? ?? '';
            final customParts = [
              if (sugar.isNotEmpty) sugar,
              if (ice.isNotEmpty) ice,
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DrinkImageWidget(
                      imageUrl: item['imageUrl'] as String? ?? '',
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['name']}  ×${item['quantity']}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        if (customParts.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(customParts.join('  ·  '),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                        if (note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Note: $note',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    'RM ${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatGmt8Time(DateTime utcDt) {
    final dt = utcDt.toUtc().add(const Duration(hours: 8));
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  int _pickupMinutes(String pickupTime) {
    switch (pickupTime) {
      case '30 minutes': return 30;
      case '45 minutes': return 45;
      case '1 hour': return 60;
      default: return 15;
    }
  }

  Widget _buildPickupTimeRow(DateTime orderDate, String pickupTime) {
    final readyAt = orderDate.toUtc().add(Duration(hours: 8, minutes: _pickupMinutes(pickupTime)));
    final h = readyAt.hour % 12 == 0 ? 12 : readyAt.hour % 12;
    final m = readyAt.minute.toString().padLeft(2, '0');
    final readyStr = '$h:$m ${readyAt.hour >= 12 ? 'PM' : 'AM'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: matchaGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: darkMatchaGreen, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Pickup', style: TextStyle(fontSize: 11, color: darkMatchaGreen)),
                Text('Ready by $readyStr', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkMatchaGreen)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: darkMatchaGreen, borderRadius: BorderRadius.circular(12)),
              child: Text(pickupTime, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFooter(String outlet, DateTime? dateTime, double total) {
    final time = dateTime != null ? _formatGmt8Time(dateTime) : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          const Icon(Icons.store_outlined, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(outlet.isEmpty ? 'Unknown outlet' : outlet,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          if (time.isNotEmpty) ...[
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 12),
          ],
          Text('RM ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkMatchaGreen)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int stage) {
    switch (stage) {
      case 1: return const ShadBadge.secondary(child: Text('Order Placed'));
      case 2: return ShadBadge.secondary(
          backgroundColor: Colors.orange.shade50,
          foregroundColor: Colors.orange.shade700,
          child: const Text('Preparing'));
      case 3: return const ShadBadge(child: Text('Ready for Pickup'));
      default: return const ShadBadge.outline(child: Text('Completed'));
    }
  }

  Widget _buildStepper(int stage) {
    final steps = ['Order Placed', 'Preparing', 'Ready'];
    return Row(
      children: List.generate(steps.length, (i) {
        final stepNum = i + 1;
        final done = stage >= stepNum;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: done ? darkMatchaGreen : Colors.grey.shade200),
                    child: Icon(done ? Icons.check : Icons.circle,
                        size: done ? 16 : 8, color: done ? Colors.white : Colors.grey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[i],
                      style: TextStyle(fontSize: 10,
                          fontWeight: stage == stepNum ? FontWeight.bold : FontWeight.normal,
                          color: done ? darkMatchaGreen : Colors.grey)),
                ],
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: stage > stepNum ? darkMatchaGreen : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

}
