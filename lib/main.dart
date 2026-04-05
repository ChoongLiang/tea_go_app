import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'otp_verification_page.dart';
import 'user_model.dart';
import 'cart_model.dart';
import 'location_model.dart';
import 'menu_model.dart';
import 'order_status_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("✅ [Firebase] Initialized successfully");
  } catch (e) {
    print("❌ [Firebase] Initialization failed: $e");
  }
  runApp(const TeaGoApp());
}

class TeaGoApp extends StatelessWidget {
  const TeaGoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => LocationModel()),
        ChangeNotifierProvider(create: (_) => OrderStatusModel()),
        ChangeNotifierProvider(create: (_) => MenuModel()),
      ],
      child: ShadApp(
        debugShowCheckedModeBanner: false,
        theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadGreenColorScheme.light(),
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController =
      TextEditingController(text: '126899877');
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleGetTac() async {
    String input = _phoneController.text.trim();
    if (input.isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Please enter your phone number')),
      );
      return;
    }

    final formattedPhone = input.startsWith('0')
        ? '+60${input.substring(1)}'
        : input.startsWith('+')
            ? input
            : '+60$input';

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        formattedPhone,
        (verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                verificationId: verificationId,
                phoneNumber: formattedPhone,
              ),
            ),
          );
        },
        onError: (message) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Failed to send OTP'),
              description: Text(message),
            ),
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Hero area ────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Subtle decorative circle top-right
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                // Subtle decorative circle bottom-left
                Positioned(
                  bottom: 60,
                  left: -70,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Tagline top-left
                        const Text(
                          'Sip, relax, repeat.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Floating badge row
                        Row(
                          children: [
                            _badge('Malaysian Blend'),
                            const SizedBox(width: 10),
                            _badge('Premium Tea'),
                          ],
                        ),

                        const Spacer(),

                        // Large illustration — tea cup emoji
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              const Text('🧋', style: TextStyle(fontSize: 72)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Headline
                        const Text(
                          'FRESH\nHAND-\nCRAFTED\nTEA.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            letterSpacing: -1,
                          ),
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom sign-in panel ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Social proof pill
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_alt_rounded,
                            size: 13, color: Color(0xFF66BB6A)),
                        SizedBox(width: 5),
                        Text(
                          'Join 10K+ daily zessers',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text('Sign In',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Enter your Malaysian phone number to continue',
                    style: TextStyle(fontSize: 13, color: Colors.black45)),
                const SizedBox(height: 18),

                // Phone input
                ShadInput(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  placeholder: const Text('12 3456789'),
                  leading: const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Text('+60 ',
                        style: TextStyle(color: Colors.black45)),
                  ),
                ),

                const SizedBox(height: 14),

                // OTP button
                ShadButton(
                  onPressed: _isLoading ? null : _handleGetTac,
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Get OTP'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }
}
