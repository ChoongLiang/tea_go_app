import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/main.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/user_model.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthModel>(
        builder: (context, auth, child) {
          if (auth.isGuest) {
            return _buildGuestView(context);
          }
          if (!auth.isLoggedIn) {
            return _buildLoggedOutView(context);
          }
          return _buildLoggedInView(context, auth.currentUser!);
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'You\'re browsing as a guest',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign up to track your orders and save your preferences.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AuthModel>(context, listen: false).logout();
                  Provider.of<OrderStatusModel>(context, listen: false).clearOrders();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMatchaGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Sign In / Sign Up', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
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
                  Provider.of<AuthModel>(context, listen: false).logout();
                  Provider.of<OrderStatusModel>(context, listen: false).clearOrders();
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
