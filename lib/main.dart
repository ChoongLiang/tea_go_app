import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/home_page.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/menu_page.dart';
import 'package:tea_go_app/order_status_model.dart';
import 'package:tea_go_app/otp_verification_page.dart';
import 'package:tea_go_app/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => OrderStatusModel()),
        ChangeNotifierProvider(create: (context) => AuthModel()),
        ChangeNotifierProvider(create: (context) => LocationModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tea Go',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _getTac() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    authService.verifyPhoneNumber(
      phoneNumber: '+60' + _phoneController.text,
      context: context,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await authService.signInWithCredential(credential);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification failed')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                OtpVerificationPage(verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    'Tea Go',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 48.0),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixText: '+60 ',
                    prefixStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    hintText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getTac,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            '获取验证码 (Get TAC)',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    '以游客身份预览 (Continue as Guest)',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
