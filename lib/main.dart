import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'otp_verification_page.dart';
import 'user_model.dart';
import 'cart_model.dart';
import 'location_model.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
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
  final TextEditingController _phoneController = TextEditingController(text: '126899877');
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleGetTac() async {
    String input = _phoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your phone number')));
      return;
    }


    String formattedPhone = input.startsWith('0') ? '+60${input.substring(1)}' : (input.startsWith('+') ? input : '+60$input');

    setState(() => _isLoading = true);

    print("-----------------------------------------");
    print("🚀 [UI] Sending OTP...");
    print("📱 [UI] Target: $formattedPhone");

    try {
      await _authService.verifyPhoneNumber(
        formattedPhone,
        (verificationId) {
          print("💡 [UI] Got verification ID, navigating to OTP page");
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send OTP: $message'), backgroundColor: Colors.red),
          );
        },
      );
    } catch (e) {
      print("❌ [UI] Exception: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_food_beverage, size: 80, color: Colors.green),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixText: '+60 ',
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleGetTac,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get OTP', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Provider.of<AuthModel>(context, listen: false).loginAsGuest();
                Provider.of<OrderStatusModel>(context, listen: false).clearOrders();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text(
                'Continue as Guest',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}