import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/item_details_page.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/shopping_cart_page.dart';

// 定义与登录页一致的抹茶绿主题色
const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A); // 用于按钮和重点文字的深抹茶绿

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  // 推荐饮品假数据
  final List<Map<String, dynamic>> _recommendedDrinks = const [
    {'name': '招牌珍珠奶茶', 'price': 12.90},
    {'name': '抹茶拿铁', 'price': 15.90},
    {'name': '芝士葡萄', 'price': 18.90},
  ];

  // 菜单列表假数据
  final List<Map<String, dynamic>> _menuItems = const [
    {'name': '珍珠奶茶', 'price': 10.90},
    {'name': '抹茶拿铁', 'price': 15.90},
    {'name': '百香果绿茶', 'price': 9.90},
    {'name': '芝士芒芒', 'price': 17.90},
    {'name': '芋泥波波', 'price': 13.90},
    {'name': '草莓欧蕾', 'price': 16.90},
    {'name': '柠檬红茶', 'price': 8.90},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 页面主体背景用白色，以突出卡片
      appBar: AppBar(
        automaticallyImplyLeading: false, // 不显示返回按钮
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            _buildLocationPicker(context),
            _buildSearchBox(context),
          ],
        ),
        toolbarHeight: 120, // Increased height
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: _buildRecommendedSection(context),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Divider(height: 1),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildMenuListHeader(),
          ),
          _buildMenuList(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
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

  // 搜索框
  Widget _buildSearchBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: matchaGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '想喝什么？',
                hintStyle: TextStyle(color: darkMatchaGreen),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: darkMatchaGreen),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: darkMatchaGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // 横向滚动的推荐位
  Widget _buildRecommendedSection(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _recommendedDrinks.length,
        itemBuilder: (context, index) {
          return _buildRecommendedCard(context, _recommendedDrinks[index]);
        },
      ),
    );
  }

  // 推荐位茶饮卡片
  Widget _buildRecommendedCard(BuildContext context, Map<String, dynamic> drink) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位符
          Container(
            height: 130,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              color: matchaGreen,
            ),
            child: Center(
              child: Icon(
                Icons.emoji_food_beverage_outlined,
                color: darkMatchaGreen.withOpacity(0.7),
                size: 50,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drink['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${drink['price']!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: darkMatchaGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 菜单列表标题
  Widget _buildMenuListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        '所有饮品',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 纵向茶饮列表
  Widget _buildMenuList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildMenuItem(context, _menuItems[index]);
        },
        childCount: _menuItems.length,
      ),
    );
  }

  // 单个茶饮列表项
  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item['name'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsPage(item: item),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      )
                    ]),
                child: const Icon(Icons.add_circle, color: Colors.blue, size: 32)),
          ),
        ],
      ),
    );
  }

  // 底部固定的浮动条
  Widget _buildBottomBar(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    children: [
                      const TextSpan(text: '已选 '),
                      TextSpan(
                        text: '${cart.totalCups}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const TextSpan(text: ' 杯'),
                    ]),
              ),
              ElevatedButton(
                onPressed: cart.items.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ShoppingCartPage()),
                        );
                      }
                    : null, // 当未选商品时禁用按钮
                style: ElevatedButton.styleFrom(
                    backgroundColor: darkMatchaGreen,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: darkMatchaGreen.withOpacity(0.5)),
                child: const Text(
                  '去结算',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
