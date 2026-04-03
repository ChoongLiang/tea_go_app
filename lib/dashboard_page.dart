import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/user_model.dart';

const Color _green = Color(0xFF66BB6A);
const Color _darkGreen = Color(0xFF43A047);
const Color _lightGreen = Color(0xFFE8F5E9);
const Color _bg = Color(0xFFF5F5F5);

class DashboardPage extends StatelessWidget {
  final Function(int) onNavigateTo;
  const DashboardPage({super.key, required this.onNavigateTo});

  String get _greeting {
    final h = DateTime.now().toUtc().add(const Duration(hours: 8)).hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _queueColor(String queue) {
    switch (queue) {
      case 'Busy':     return const Color(0xFFE53935);
      case 'Moderate': return const Color(0xFFFB8C00);
      default:         return _green;
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
            const SizedBox(height: 16),
            _buildLoyaltySection(orderStatus),
            const SizedBox(height: 16),
            _buildPromosSection(),
            const SizedBox(height: 16),
            if (orderStatus.latestOrder != null) ...[
              _buildRecentOrderSection(context, orderStatus.latestOrder!),
              const SizedBox(height: 16),
            ],
            _buildCategoryShortcuts(),
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
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_darkGreen, _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, $name 👋',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Skip the queue, sip smarter.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ─── Section B: Selected Stall Card ───────────────────────────────────────
  Widget _buildSelectedStallCard(BuildContext context, LocationModel location) {
    final info = location.selectedStallDetails;
    final queueColor = _queueColor(info['queue'] ?? 'Quiet');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: _green, size: 15),
              const SizedBox(width: 4),
              const Text('Your Outlet',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              GestureDetector(
                onTap: () => _showStallPicker(context, location),
                child: const Text('Change',
                    style: TextStyle(
                        fontSize: 12,
                        color: _green,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(location.selectedStall,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _queueBadge(info['queue'] ?? 'Quiet', queueColor),
              const SizedBox(width: 10),
              Icon(Icons.access_time_rounded,
                  size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(info['wait'] ?? '~10 min',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 10),
              Icon(Icons.near_me_outlined,
                  size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(info['distance'] ?? '—',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const Spacer(),
              ElevatedButton(
                onPressed: () => onNavigateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Order Now',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _queueBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showStallPicker(BuildContext context, LocationModel location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Outlet',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...location.stalls.map((stall) {
              final info = location.stallDetails[stall] ?? {};
              final qColor =
                  _queueColor(info['queue'] ?? 'Quiet');
              return ListTile(
                leading:
                    const Icon(Icons.store_outlined, color: _green),
                title: Text(stall,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Row(
                  children: [
                    _queueBadge(info['queue'] ?? 'Quiet', qColor),
                    const SizedBox(width: 8),
                    Text(info['wait'] ?? '',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500)),
                  ],
                ),
                trailing: location.selectedStall == stall
                    ? const Icon(Icons.check_circle, color: _green)
                    : null,
                onTap: () {
                  location.selectStall(stall);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Section C: Loyalty Stamps ────────────────────────────────────────────
  Widget _buildLoyaltySection(OrderStatusModel orderStatus) {
    final stamps = orderStatus.orders.length % 10;
    final remaining = 10 - stamps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
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
                        color: filled
                            ? _green
                            : Colors.grey.shade200,
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12)),
              child:
                  const Icon(Icons.replay_rounded, color: _green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Again?',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    order.items.map((i) => i.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text('RM ${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: _green,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () {
                final cart = Provider.of<CartModel>(context, listen: false);
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Items added to cart'),
                    backgroundColor: _green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                side: const BorderSide(color: _green),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reorder',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section F: Category Shortcuts ───────────────────────────────────────
  Widget _buildCategoryShortcuts() {
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
                onTap: () => onNavigateTo(1),
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
  Widget _buildAllStallsSection(
      BuildContext context, LocationModel location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('All Outlets',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        ...location.stalls.map((stall) {
          final info = location.stallDetails[stall] ??
              {'queue': 'Quiet', 'wait': '~5 min', 'distance': '—'};
          final isSelected = location.selectedStall == stall;
          final qColor = _queueColor(info['queue'] ?? 'Quiet');

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
                border: isSelected
                    ? Border.all(color: _green, width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _lightGreen
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.store_outlined,
                        color:
                            isSelected ? _green : Colors.grey.shade400,
                        size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(stall,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                            if (isSelected)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: _lightGreen,
                                    borderRadius:
                                        BorderRadius.circular(8)),
                                child: const Text('Selected',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _green,
                                        fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            _queueBadge(info['queue'] ?? 'Quiet', qColor),
                            const SizedBox(width: 8),
                            Text(
                              '${info['wait']}  ·  ${info['distance']}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
