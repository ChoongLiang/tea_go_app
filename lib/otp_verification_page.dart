import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'user_model.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController(text: '123456');
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Invalid OTP'),
          description: Text('Please enter the 6-digit code sent to your phone.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      final userCredential = await _authService.signInWithCredential(credential);

      if (userCredential != null) {
        final existingUser = await _authService.loadUserProfile();
        if (!mounted) return;
        if (existingUser != null) {
          Provider.of<AuthModel>(context, listen: false).login(existingUser);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignupPage()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Verification failed'),
          description: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_outlined,
                    size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('Verify your number',
                    style: theme.textTheme.h3
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 32),
                ShadCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ShadInput(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        placeholder: const Text('6-digit OTP'),
                        maxLength: 6,
                      ),
                      const SizedBox(height: 20),
                      ShadButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Verify OTP'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ShadButton.ghost(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Wrong number? Go back',
                      style: TextStyle(color: theme.colorScheme.mutedForeground)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
