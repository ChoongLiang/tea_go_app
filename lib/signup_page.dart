import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/date_text_formatter.dart';
import 'package:tea_go_app/home_page.dart';
import 'package:tea_go_app/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<ShadFormState>();
  final _firstNameController = TextEditingController(text: 'Ahmad');
  final _lastNameController = TextEditingController(text: 'Razif');
  final _dobController = TextEditingController(text: '01/01/1995');
  final _emailController = TextEditingController(text: 'ahmad.razif@test.com');
  String? _gender = 'Male';
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      ShadToaster.of(context)
          .show(const ShadToast.destructive(description: Text('Please select your gender')));
      return;
    }
    setState(() => _loading = true);
    final auth = Provider.of<AuthModel>(context, listen: false);
    final user = User(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _gender!,
      email: _emailController.text.trim(),
    );
    await AuthService().saveUserProfile(user);
    auth.login(user);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: const Text('Create Your Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ShadForm(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShadCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ShadInputFormField(
                      id: 'firstName',
                      controller: _firstNameController,
                      label: const Text('First Name'),
                      placeholder: const Text('Ahmad'),
                      validator: (v) => v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    ShadInputFormField(
                      id: 'lastName',
                      controller: _lastNameController,
                      label: const Text('Last Name'),
                      placeholder: const Text('Razif'),
                      validator: (v) => v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    ShadInputFormField(
                      id: 'dob',
                      controller: _dobController,
                      label: const Text('Date of Birth (DD/MM/YYYY)'),
                      placeholder: const Text('01/01/1990'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        DateTextFormatter(),
                      ],
                      validator: (v) {
                        if (v.trim().isEmpty) return 'Required';
                        if (v.trim().length != 10) return 'Use DD/MM/YYYY format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    ShadSelectFormField<String>(
                      id: 'gender',
                      label: const Text('Gender'),
                      placeholder: const Text('Select gender'),
                      initialValue: _gender,
                      options: ['Male', 'Female', 'Other']
                          .map((g) => ShadOption(value: g, child: Text(g)))
                          .toList(),
                      selectedOptionBuilder: (_, v) => Text(v),
                      onChanged: (v) => setState(() => _gender = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    ShadInputFormField(
                      id: 'email',
                      controller: _emailController,
                      label: const Text('Email'),
                      placeholder: const Text('you@example.com'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v.trim().isEmpty) return 'Required';
                        final re = RegExp(
                            r"^[\w.!#$%&'*+\-/=?^_`{|}~]+@[\w]+\.[a-zA-Z]+");
                        return re.hasMatch(v) ? null : 'Enter a valid email';
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ShadButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
