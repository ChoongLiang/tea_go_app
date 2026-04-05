import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/menu_model.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/user_model.dart';

const Color _green = Color(0xFF66BB6A);
const Color _darkGreen = Color(0xFF43A047);
const Color _lightGreen = Color(0xFFE8F5E9);
const Color _bg = Colors.white;

class DashboardPage extends StatelessWidget {
  final Function(int) onNavigateTo;
  const DashboardPage({super.key, required this.onNavigateTo});

  String get _greeting {
    final h = DateTime.now().toUtc().add(const Duration(hours: 8)).hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _queueColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.notBusy:  return const Color(0xFF4CAF50);
      case QueueStatus.moderate: return const Color(0xFFFFC107);
      case QueueStatus.busy:     return const Color(0xFFFF9800);
      case QueueStatus.veryBusy: return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final orderStatus = context.watch<OrderStatusModel>();
    final location = context.watch<LocationModel>();
    final firstName = auth.currentUser?.firstName ?? 'there';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(firstName),
            _buildSelectedStallCard(context, location),
            if (orderStatus.latestOrder != null) ...[
              const SizedBox(height: 12),
              _buildRecentOrderSection(context, orderStatus.latestOrder!),
            ],
            const SizedBox(height: 16),
            _buildLoyaltySection(orderStatus),
            const SizedBox(height: 16),
            _buildPromosSection(),
            const SizedBox(height: 16),
            _buildCategoryShortcuts(context),
            const SizedBox(height: 16),
            _buildAllStallsSection(context, location),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Section A: Header ────────────────────────────────────────────────────
  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_greeting, $name 👋',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          const Text(
            'What are we zessing today?',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  // ─── Section B: Selected Stall Card ───────────────────────────────────────
  Widget _buildSelectedStallCard(BuildContext context, LocationModel location) {
    final stall = location.selectedStall;
    final qColor = _queueColor(stall.queueStatus);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.location_on, color: _green, size: 14),
                const SizedBox(width: 4),
                const Text('Your Outlet', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showStallPicker(context, location),
                  child: const Text('Change',
                      style: TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stall name
            Text(stall.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Status + distance
            Row(
              children: [
                _statusChip(stall),
                const SizedBox(width: 8),
                Icon(Icons.near_me_outlined, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(stall.distanceLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            if (stall.isOpen) ...[
              const SizedBox(height: 10),
              // Queue status
              Row(
                children: [
                  _queueDot(qColor),
                  const SizedBox(width: 6),
                  Text(stall.queueLabel,
                      style: TextStyle(fontSize: 12, color: qColor, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Text('· ${stall.ordersInLine} in line',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 6),
              // Pickup time
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 5),
                  Text('Estimated pickup ${stall.estimatedPickupMinutes} min',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
            const SizedBox(height: 14),
            // CTA
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: stall.isOpen ? () => onNavigateTo(1) : null,
                child: Text(stall.isOpen ? 'Order Now' : 'Currently Closed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(StallInfo stall) {
    final color = stall.isOpen ? _green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: stall.isOpen ? _lightGreen : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(stall.isOpen ? 'Open' : 'Closed',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _queueDot(Color color) =>
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _queueBadge(StallInfo stall) {
    final color = _queueColor(stall.queueStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(stall.queueLabel, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showStallPicker(BuildContext context, LocationModel location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Outlet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...location.stalls.map((stall) => ListTile(
              leading: Icon(Icons.store_outlined, color: stall.isOpen ? _green : Colors.grey),
              title: Text(stall.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              subtitle: Row(
                children: [
                  if (stall.isOpen) ...[
                    _queueBadge(stall),
                    const SizedBox(width: 6),
                    Text('${stall.ordersInLine} in line · ~${stall.estimatedPickupMinutes} min',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ] else
                    Text('Closed', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
              trailing: location.selectedStall.id == stall.id
                  ? const Icon(Icons.check_circle, color: _green)
                  : null,
              onTap: () {
                location.selectStall(stall);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  // ─── Section C: Loyalty Stamps ────────────────────────────────────────────
  Widget _buildLoyaltySection(OrderStatusModel orderStatus) {
    final stamps = orderStatus.totalOrderCount % 10;
    final remaining = 10 - stamps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Loyalty Stamps',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  stamps == 0
                      ? 'Start collecting!'
                      : '$stamps / 10',
                  style: TextStyle(
                      fontSize: 12,
                      color: stamps == 0
                          ? Colors.grey
                          : _green,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              remaining == 10
                  ? 'Order 10 times to earn a free drink!'
                  : '$remaining more sip${remaining == 1 ? '' : 's'} to your free drink! 🎉',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(10, (i) {
                final filled = i < stamps;
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: filled ? _green : _lightGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: filled ? _green : Colors.grey.shade200,
                        width: 1.5),
                  ),
                  child: Icon(
                    Icons.emoji_food_beverage,
                    size: 16,
                    color: filled
                        ? Colors.white
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section D: Promos ────────────────────────────────────────────────────
  Widget _buildPromosSection() {
    final promos = [
      {
        'code': 'TEA10',
        'desc': '10% off your next order',
        'bg': const Color(0xFFE3F2FD),
        'accent': const Color(0xFF1E88E5),
      },
      {
        'code': 'FIRST20',
        'desc': '20% off your first order',
        'bg': const Color(0xFFFFF3E0),
        'accent': const Color(0xFFEF6C00),
      },
      {
        'code': 'WELCOME',
        'desc': '15% off — welcome gift',
        'bg': _lightGreen,
        'accent': _darkGreen,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text("Today's Deals",
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final p = promos[i];
              final accent = p['accent'] as Color;
              return Container(
                width: 190,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p['bg'] as Color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(p['code'] as String,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: accent)),
                    ),
                    const SizedBox(height: 8),
                    Text(p['desc'] as String,
                        style: TextStyle(
                            fontSize: 12,
                            color: accent.withValues(alpha: 0.85))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Section E: Recent Order ──────────────────────────────────────────────
  Widget _buildRecentOrderSection(BuildContext context, Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.replay_rounded, color: _green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Again?',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        order.items.map((i) => i.name).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      Text('RM ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12, color: _green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ShadButton.outline(
                  onPressed: () {
                    final cart = Provider.of<CartModel>(context, listen: false);
                    final location = Provider.of<LocationModel>(context, listen: false);

                    // Restore the outlet from this order
                    if (order.outlet.isNotEmpty) {
                      final match = location.stalls.where(
                        (s) => s.name == order.outlet,
                      );
                      if (match.isNotEmpty) location.selectStall(match.first);
                    }

                    for (final item in order.items) {
                      cart.add(CartItem(
                        name: item.name,
                        price: item.price,
                        sugarLevel: item.sugarLevel,
                        iceLevel: item.iceLevel,
                        quantity: item.quantity,
                        note: item.note,
                        imageUrl: item.imageUrl,
                      ));
                    }
                    onNavigateTo(1);
                    ShadToaster.of(context).show(
                      const ShadToast(description: Text('Items added to cart')),
                    );
                  },
                  size: ShadButtonSize.sm,
                  child: const Text('Reorder'),
                ),
              ],
            ),
            if (order.outlet.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.store_outlined, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 5),
                  Text(order.outlet,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Section F: Category Shortcuts ───────────────────────────────────────
  Widget _buildCategoryShortcuts(BuildContext context) {
    final categories = [
      {'label': 'Milk Tea',    'icon': Icons.local_cafe_outlined},
      {'label': 'Fruit Tea',   'icon': Icons.local_drink_outlined},
      {'label': 'Fresh Tea',   'icon': Icons.eco_outlined},
      {'label': 'Best Sellers','icon': Icons.star_outline_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('Browse Menu',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final cat = categories[i];
              return GestureDetector(
                onTap: () {
                  context.read<MenuModel>().setCategory(cat['label'] as String);
                  onNavigateTo(1);
                },
                child: Container(
                  width: 82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat['icon'] as IconData,
                          color: _green, size: 24),
                      const SizedBox(height: 6),
                      Text(cat['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.2)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Section G: All Stalls ────────────────────────────────────────────────
  Widget _buildAllStallsSection(BuildContext context, LocationModel location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('All Outlets', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        ...location.stalls.map((stall) {
          final isSelected = location.selectedStall.id == stall.id;

          return GestureDetector(
            onTap: () {
              location.selectStall(stall);
              onNavigateTo(1);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? Border.all(color: _green, width: 1.5) : null,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: isSelected ? _lightGreen : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.store_outlined, color: isSelected ? _green : Colors.grey.shade400, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(stall.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Selected',
                                    style: TextStyle(fontSize: 10, color: _green, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _statusChip(stall),
                            const SizedBox(width: 8),
                            Icon(Icons.near_me_outlined, size: 11, color: Colors.grey.shade400),
                            const SizedBox(width: 3),
                            Text(stall.distanceLabel,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                        if (stall.isOpen) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              _queueBadge(stall),
                              const SizedBox(width: 6),
                              Text('${stall.ordersInLine} in line · ~${stall.estimatedPickupMinutes} min',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
