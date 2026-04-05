import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/dashboard_page.dart';
import 'package:tea_go_app/menu_page.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/order_status_page.dart';
import 'package:tea_go_app/profile_page.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fetch orders so Dashboard has real loyalty count + "Order Again" data
    // without requiring the user to visit the Orders tab first.
    _prefetchOrders();
  }

  Future<void> _prefetchOrders() async {
    final rawOrders = await AuthService().loadOrders();
    if (!mounted) return;
    // Convert Timestamp → DateTime before passing to the model
    final orders = rawOrders.map((o) {
      final ts = o['createdAt'];
      return {...o, 'createdAt': ts is Timestamp ? ts.toDate() : DateTime.now()};
    }).toList();
    Provider.of<OrderStatusModel>(context, listen: false).setFirestoreData(orders);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(onNavigateTo: _onItemTapped),
      const MenuPage(),
      const OrderStatusPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: darkMatchaGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink_outlined),
            activeIcon: Icon(Icons.local_drink),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
