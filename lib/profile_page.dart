import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/main.dart';
import 'package:tea_go_app/order_history_page.dart';
import 'package:tea_go_app/user_model.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthModel>(
        builder: (context, auth, child) {
          if (!auth.isLoggedIn) {
            return _buildLoggedOutView(context);
          }
          return _buildLoggedInView(context, auth.currentUser!);
        },
      ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You are not logged in.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Login / Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, User user) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text('${user.firstName} ${user.lastName}'),
          subtitle: Text(user.email),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Order History'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            _showSettingsDialog(context);
          },
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  final auth = Provider.of<AuthModel>(context, listen: false);
                  auth.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
