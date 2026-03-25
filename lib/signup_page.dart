import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/home_page.dart';
import 'package:tea_go_app/user_model.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthModel>(context, listen: false);
      final user = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dob: _dobController.text,
        gender: _gender ?? 'Not specified',
        email: _emailController.text,
      );
      auth.login(user);
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth (DD/MM/YYYY)'),
                validator: (value) => value!.isEmpty ? 'Please enter your date of birth' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                hint: const Text('Gender'),
                onChanged: (value) => setState(() => _gender = value),
                items: ['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMatchaGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
