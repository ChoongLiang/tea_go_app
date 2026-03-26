import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/signup_page.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;

  const OtpVerificationPage({super.key, required this.verificationId});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: _otpController.text,
        );

        UserCredential? userCredential = await authService.signInWithCredential(credential);

        if (userCredential != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter the 6-digit code',
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length != 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMatchaGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Confirm', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
