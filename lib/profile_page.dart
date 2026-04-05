import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/edit_profile_page.dart';
import 'package:tea_go_app/main.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/user_model.dart';

const Color _green = Color(0xFF66BB6A);
const Color _greenLight = Color(0xFFE8F5E9);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AuthModel>(
        builder: (context, auth, _) {
          if (!auth.isLoggedIn) return _buildLoggedOutView(context, theme);
          return _buildLoggedInView(context, auth.currentUser!, theme);
        },
      ),
    );
  }

  // ─── Logged-out ────────────────────────────────────────────────────────────

  Widget _buildLoggedOutView(BuildContext context, ShadThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.mutedForeground),
            const SizedBox(height: 16),
            Text('Not signed in', style: theme.textTheme.h4),
            const SizedBox(height: 8),
            Text('Sign in to view your profile',
                style: theme.textTheme.muted, textAlign: TextAlign.center),
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

  // ─── Logged-in ─────────────────────────────────────────────────────────────

  Widget _buildLoggedInView(BuildContext context, User user, ShadThemeData theme) {
    final initials =
        '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
            .toUpperCase();

    return Consumer<OrderStatusModel>(
      builder: (context, orderStatus, _) {
        final totalOrders = orderStatus.totalOrderCount;
        final cupsThisCycle = totalOrders % 10;
        final rewardsEarned = totalOrders ~/ 10;
        final hasBirthdayPerk = user.dob.isNotEmpty;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // ── A. Profile Header ──────────────────────────────────────────
            _section(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ShadAvatar(
                        null,
                        size: const Size(76, 76),
                        placeholder: Text(initials,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => EditProfilePage(user: user)),
                          ),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${user.firstName} ${user.lastName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(user.email,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── B. Loyalty Summary ─────────────────────────────────────────
            _sectionLabel('Loyalty'),
            _section(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _statBox(
                          label: 'Total Points',
                          value: '${totalOrders * 10}',
                          icon: Icons.stars_rounded,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statBox(
                          label: 'Rewards Earned',
                          value: '$rewardsEarned',
                          icon: Icons.card_giftcard_rounded,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Cup progress toward next reward
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Next free drink',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                      Text('$cupsThisCycle / 10 cups',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: _green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Stamp row
                  Row(
                    children: List.generate(10, (i) {
                      final filled = i < cupsThisCycle;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 9 ? 4 : 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 28,
                            decoration: BoxDecoration(
                              color: filled ? _green : _greenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.emoji_food_beverage,
                              size: 14,
                              color: filled ? Colors.white : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cupsThisCycle == 0
                        ? 'Start ordering to earn your next reward!'
                        : '${10 - cupsThisCycle} more cup${10 - cupsThisCycle == 1 ? '' : 's'} until your next free drink',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── C. My Rewards ─────────────────────────────────────────────
            _sectionLabel('My Rewards'),
            _section(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _rewardRow(
                    icon: Icons.local_cafe_rounded,
                    iconColor: _green,
                    title: 'Free Drink Vouchers',
                    trailing: rewardsEarned > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$rewardsEarned available',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          )
                        : Text('None yet',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _rewardRow(
                    icon: Icons.history_rounded,
                    iconColor: Colors.grey,
                    title: 'Used Rewards',
                    trailing: Text('$rewardsEarned used',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _rewardRow(
                    icon: Icons.cake_rounded,
                    iconColor: hasBirthdayPerk ? Colors.pink : Colors.grey.shade300,
                    title: 'Birthday Perk',
                    trailing: hasBirthdayPerk
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.pink.shade200),
                            ),
                            child: Text('Active',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.pink.shade400,
                                    fontWeight: FontWeight.w600)),
                          )
                        : TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => EditProfilePage(user: user)),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('Add birthday',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.pink.shade300)),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── D. Account Details ─────────────────────────────────────────
            _sectionLabel('Account Details'),
            _section(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _detailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email.isEmpty ? '—' : user.email,
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _detailRow(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    value: user.dob.isEmpty ? '—' : user.dob,
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _detailRow(
                    icon: Icons.wc_outlined,
                    label: 'Gender',
                    value: user.gender.isEmpty ? '—' : user.gender,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── E. Support & Settings ──────────────────────────────────────
            _sectionLabel('Support & Settings'),
            _section(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _actionRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & FAQ',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _actionRow(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _actionRow(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  _actionRow(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    labelColor: Colors.red.shade400,
                    iconColor: Colors.red.shade400,
                    onTap: () => _confirmLogout(context),
                    showChevron: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
              letterSpacing: 0.8)),
    );
  }

  Widget _section({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
    Color? iconColor,
    bool showChevron = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.grey.shade500),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? Colors.black87)),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Logout'),
        description: const Text('Are you sure you want to sign out?'),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Provider.of<AuthModel>(context, listen: false).logout();
              Provider.of<OrderStatusModel>(context, listen: false).clearOrders();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
