import 'package:flutter/material.dart';
import 'package:tea_go_app/signup_page.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Simulate a network call to verify OTP
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        if (_otpController.text == '123456') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid OTP')),
          );
        }
      });
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
                  child: const Text('Verify', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
