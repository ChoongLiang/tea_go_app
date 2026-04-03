import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/edit_profile_page.dart';
import 'package:tea_go_app/main.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/user_model.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);
const Color lightMatchaGreen = Color(0xFFE8F5E9);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
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
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
            .toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: lightMatchaGreen,
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: darkMatchaGreen)),
              ),
              const SizedBox(height: 12),
              Text('${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: darkMatchaGreen),
                  label: const Text('Edit Profile',
                      style: TextStyle(color: darkMatchaGreen, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: darkMatchaGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info tiles
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              _infoTile(Icons.cake_outlined, 'Date of Birth', user.dob.isEmpty ? '—' : user.dob),
              const Divider(height: 1, indent: 52),
              _infoTile(Icons.wc_outlined, 'Gender', user.gender.isEmpty ? '—' : user.gender),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Settings / logout
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            onTap: () => _confirmLogout(context),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: darkMatchaGreen),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthModel>(context, listen: false).logout();
              Provider.of<OrderStatusModel>(context, listen: false).clearOrders();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
