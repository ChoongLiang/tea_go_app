import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/drink_image_widget.dart';
import 'package:tea_go_app/item_details_page.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/menu_model.dart';
import 'package:tea_go_app/shopping_cart_page.dart';

const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A);

const List<Map<String, dynamic>> _menuItems = [
  {
    'name': 'Signature Teh Tarik Milk Tea', 'category': 'Milk Tea', 'price': 6.50,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/teh%20tarik.webp?alt=media&token=99d711a6-3e58-4aca-b661-f136e8b39eac',
    'bestSeller': true, 'featured': true, 'calorieLevel': 'High',
    'sugarLevels': ['0%', '25%', '50%', '75%', '100%'], 'iceLevels': ['No Ice', 'Less Ice', 'Normal Ice'],
  },
  {
    'name': 'Sea Salt Cream Tea', 'category': 'Milk Tea', 'price': 7.50,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/sea%20salt.webp?alt=media&token=83609ada-c0c5-4078-a132-bb084a857406',
    'bestSeller': false, 'featured': false, 'calorieLevel': 'High',
    'sugarLevels': ['25%', '50%', '75%', '100%'], 'iceLevels': ['Less Ice', 'Normal Ice'],
  },
  {
    'name': 'Gula Melaka Milk Tea', 'category': 'Milk Tea', 'price': 7.00,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/gula%20melaka.webp?alt=media&token=a3280cd5-9180-4d45-b04b-48a5f4734ff5',
    'bestSeller': true, 'featured': false, 'calorieLevel': 'High',
    'sugarLevels': ['25%', '50%', '75%', '100%'], 'iceLevels': ['No Ice', 'Less Ice', 'Normal Ice'],
  },
  {
    'name': 'Lemon Tea', 'category': 'Fruit Tea', 'price': 5.50,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/lemon%20tea.webp?alt=media&token=0bdb2d4e-4cd7-4a49-b441-e0fbcbbdaace',
    'bestSeller': true, 'featured': false, 'calorieLevel': 'Low',
    'sugarLevels': ['0%', '25%', '50%', '75%', '100%'], 'iceLevels': ['No Ice', 'Less Ice', 'Normal Ice', 'Extra Ice'],
  },
  {
    'name': 'Honey Lemon', 'category': 'Fruit Tea', 'price': 6.50,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/honey%20lemon.webp?alt=media&token=06cb863b-fd58-4323-a4ec-e5ec31ce166f',
    'bestSeller': true, 'featured': true, 'calorieLevel': 'Medium',
    'sugarLevels': ['0%', '25%', '50%', '75%'], 'iceLevels': ['No Ice', 'Less Ice', 'Normal Ice', 'Extra Ice'],
  },
  {
    'name': 'Lime Sour Plum', 'category': 'Fruit Tea', 'price': 6.00,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/lime%20sour.webp?alt=media&token=ca95baa2-affb-4de0-bef7-ad035c71b0b6',
    'bestSeller': false, 'featured': false, 'calorieLevel': 'Low',
    'sugarLevels': ['0%', '25%', '50%'], 'iceLevels': ['Less Ice', 'Normal Ice', 'Extra Ice'],
  },
  {
    'name': 'Cold Brew Jasmine Green Tea', 'category': 'Fresh Tea', 'price': 6.50,
    'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/tea-go-app.firebasestorage.app/o/jasmine.webp?alt=media&token=ab36e45a-153e-4ba1-a7ed-5010c54d4dde',
    'bestSeller': false, 'featured': false, 'calorieLevel': 'Low',
    'sugarLevels': ['0%', '25%', '50%', '75%', '100%'], 'iceLevels': ['No Ice', 'Less Ice', 'Normal Ice', 'Extra Ice'],
  },
];

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const List<String> _tabs = ['All', 'Milk Tea', 'Fruit Tea', 'Fresh Tea'];
  int _tabIndex = 0;

  List<Map<String, dynamic>> get _visibleItems {
    if (_tabIndex == 0) return _menuItems;
    return _menuItems.where((i) => i['category'] == _tabs[_tabIndex]).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromMenuModel());
  }

  void _syncFromMenuModel() {
    if (!mounted) return;
    final cat = context.read<MenuModel>().activeCategory;
    if (cat == null) return;
    final idx = _tabs.indexOf(cat);
    if (idx >= 0) setState(() => _tabIndex = idx);
    context.read<MenuModel>().setCategory(null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuModel>(
      builder: (context, menuModel, _) {
        // Sync when dashboard navigates here with a category
        if (menuModel.activeCategory != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromMenuModel());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeftTabs(),
                      const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                  child: Consumer<LocationModel>(
                    builder: (context, loc, _) =>
                        _buildItemList(context, loc.selectedStall.isOpen),
                  ),
                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildCartFab(context),
        );
      },
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Consumer<LocationModel>(
      builder: (context, location, _) {
        final stall = location.selectedStall;
        final queueColor = _queueColor(stall.queueStatus);

        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Pickup chip + stall name (tap to change)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
                child: Row(
                  children: [
                    // Pickup chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_walk_rounded, size: 13, color: Color(0xFF1565C0)),
                          SizedBox(width: 3),
                          Text('Pickup',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1565C0),
                                  letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Location icon + stall name (tappable)
                    const Icon(Icons.location_on_rounded, color: darkMatchaGreen, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showLocationDialog(context),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                stall.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Row 2: Open/Closed · queue status · orders · distance · (i)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 14, 12),
                child: Row(
                  children: [
                    // Open / Closed dot
                    _statusDot(stall.isOpen ? const Color(0xFF4CAF50) : Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      stall.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stall.isOpen ? const Color(0xFF4CAF50) : Colors.grey,
                      ),
                    ),
                    _dot(),
                    // Queue status dot + label
                    _statusDot(queueColor),
                    const SizedBox(width: 5),
                    Text(stall.queueLabel,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    if (stall.isOpen) ...[
                      _dot(),
                      Text('${stall.ordersInLine} in line',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      _dot(),
                      Text(stall.distanceLabel,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                    const Spacer(),
                    // Info button
                    GestureDetector(
                      onTap: () => _showStallInfo(context, stall),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          shape: BoxShape.circle,
                          color: Colors.grey.shade50,
                        ),
                        child: Icon(Icons.info_outline_rounded,
                            size: 15, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey.shade200),
            ],
          ),
        );
      },
    );
  }

  Widget _statusDot(Color color) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Text('·', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      );

  Color _queueColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.notBusy:  return const Color(0xFF4CAF50);
      case QueueStatus.moderate: return const Color(0xFFFFC107);
      case QueueStatus.busy:     return const Color(0xFFFF9800);
      case QueueStatus.veryBusy: return const Color(0xFFF44336);
    }
  }

  // ─── Stall Info Bottom Sheet ───────────────────────────────────────────────

  void _showStallInfo(BuildContext context, StallInfo stall) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Stall name + status badge
            Row(
              children: [
                Expanded(
                  child: Text(stall.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stall.isOpen
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stall.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: stall.isOpen ? const Color(0xFF388E3C) : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Address
            _infoRow(Icons.location_on_outlined, stall.address),
            const SizedBox(height: 12),
            // Hours
            _infoRow(Icons.access_time_outlined, stall.openHours),
            const SizedBox(height: 20),
            // Call button
            ShadButton.outline(
              onPressed: () {
                Navigator.pop(ctx);
                ShadToaster.of(context).show(
                  ShadToast(description: Text('Calling ${stall.phone}…')),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(stall.phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
        ),
      ],
    );
  }

  // ─── Location Picker Dialog ────────────────────────────────────────────────

  void _showLocationDialog(BuildContext context) {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Select a Stall',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locationModel.stalls.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (ctx2, index) {
                final stall = locationModel.stalls[index];
                return GestureDetector(
                  onTap: () {
                    locationModel.selectStall(stall);
                    Navigator.of(ctx2).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stall.isOpen
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.shade300),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stall.name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 3),
                              Text(
                                '${stall.distanceLabel}  ·  ${stall.queueLabel}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          stall.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                              fontSize: 12,
                              color: stall.isOpen
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Left Tab Rail ─────────────────────────────────────────────────────────

  Widget _buildLeftTabs() {
    return SizedBox(
      width: 82,
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: _tabs.length,
          itemBuilder: (context, index) {
            final isActive = index == _tabIndex;
            return GestureDetector(
              onTap: () => setState(() => _tabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  color: isActive ? matchaGreen : Colors.white,
                  border: Border(
                    left: BorderSide(
                      color: isActive ? darkMatchaGreen : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? darkMatchaGreen : Colors.grey.shade500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Item List ─────────────────────────────────────────────────────────────

  Widget _buildItemList(BuildContext context, bool isOpen) {
    final items = _visibleItems;
    if (items.isEmpty) {
      return Center(
        child: Text('No items', style: TextStyle(color: Colors.grey.shade400)),
      );
    }
    return Column(
      children: [
        if (!isOpen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Icon(Icons.storefront_outlined,
                    size: 16, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This stall is currently closed. Ordering is unavailable.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 6, bottom: 80),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, indent: 102, color: Colors.grey.shade100),
            itemBuilder: (context, index) =>
                _buildItemRow(context, items[index], isOpen),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(
      BuildContext context, Map<String, dynamic> item, bool isOpen) {
    final isBestSeller = item['bestSeller'] == true;
    return Opacity(
      opacity: isOpen ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: isOpen
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ItemDetailsPage(item: item)),
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            children: [
              // Drink image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DrinkImageWidget(
                  imageUrl: item['imageUrl'] as String? ?? '',
                  height: 74,
                  width: 74,
                ),
              ),
              const SizedBox(width: 14),
              // Name + best seller tag + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isBestSeller) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.orange.shade300, width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Best Seller',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade600,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'RM ${(item['price'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkMatchaGreen),
                    ),
                  ],
                ),
              ),
              // Add icon — hidden when closed
              if (isOpen)
                Icon(Icons.add_rounded, size: 22, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Cart FAB ──────────────────────────────────────────────────────────────

  Widget _buildCartFab(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, _) {
        if (cart.items.isEmpty) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ShoppingCartPage())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: darkMatchaGreen,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: darkMatchaGreen.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white, size: 22),
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${cart.totalCups}',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: darkMatchaGreen),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Text(
                  'RM ${cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
