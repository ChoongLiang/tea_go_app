import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/drink_image_widget.dart';
import 'package:tea_go_app/item_details_page.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/shopping_cart_page.dart';

// 定义与登录页一致的抹茶绿主题色
const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A); // 用于按钮和重点文字的深抹茶绿

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  List<String> get _categories =>
      _menuItems.map((e) => e['category'] as String).toSet().toList();

  List<Map<String, dynamic>> _itemsForCategory(String category) =>
      _menuItems.where((e) => e['category'] == category).toList();

  final List<Map<String, dynamic>> _menuItems = const [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 页面主体背景用白色，以突出卡片
      appBar: AppBar(
        automaticallyImplyLeading: false, // 不显示返回按钮
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildLocationPicker(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildBanner()),
          ..._categories.expand((category) => [
            SliverToBoxAdapter(child: _buildCategoryHeader(category)),
            _buildCategoryGrid(context, category),
          ]),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      floatingActionButton: _buildCartFab(context),
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Consumer<LocationModel>(
      builder: (context, location, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: darkMatchaGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              location.selectedStall,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              child: const Text('Change'),
              onPressed: () => _showLocationDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _showLocationDialog(BuildContext context) {
    final locationModel = Provider.of<LocationModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Stall'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locationModel.stalls.length,
              itemBuilder: (context, index) {
                final stall = locationModel.stalls[index];
                return ListTile(
                  title: Text(stall),
                  onTap: () {
                    locationModel.selectStall(stall);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Big promotional banner
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFFA5D6A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.emoji_food_beverage,
              size: 160,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fresh & Handcrafted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Order your favourite tea today ☕',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              color: darkMatchaGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  SliverPadding _buildCategoryGrid(BuildContext context, String category) {
    final items = _itemsForCategory(category);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: 192,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMenuItem(context, items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemDetailsPage(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with + button overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  DrinkImageWidget(
                    imageUrl: item['imageUrl'] as String? ?? '',
                    height: 110,
                    width: double.infinity,
                  ),
                  if (item['bestSeller'] == true)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Best Seller',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: darkMatchaGreen,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            // Info — name + price only, no button
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'RM ${(item['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkMatchaGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartFab(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShoppingCartPage()),
          ),
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
                      top: -6, right: -8,
                      child: Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${cart.totalCups}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: darkMatchaGreen),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Text(
                  'RM ${cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
