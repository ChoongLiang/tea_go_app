import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/date_text_formatter.dart';
import 'package:tea_go_app/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<ShadFormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _emailController;
  late String? _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _dobController = TextEditingController(text: widget.user.dob);
    _emailController = TextEditingController(text: widget.user.email);
    _gender = widget.user.gender.isEmpty ? null : widget.user.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = User(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _gender ?? 'Not specified',
      email: _emailController.text.trim(),
    );

    try {
      await AuthService().updateUserProfile(updated);
      if (!mounted) return;
      Provider.of<AuthModel>(context, listen: false).updateProfile(updated);
      Navigator.of(context).pop();
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Profile updated successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        const ShadToast.destructive(
            description: Text('Failed to update. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final initials =
        '${widget.user.firstName.isNotEmpty ? widget.user.firstName[0] : ''}${widget.user.lastName.isNotEmpty ? widget.user.lastName[0] : ''}'
            .toUpperCase();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ShadButton.ghost(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ShadForm(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: ShadAvatar(
                  null,
                  size: const Size(72, 72),
                  placeholder: Text(initials,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // Name fields
              ShadCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ShadInputFormField(
                      id: 'firstName',
                      controller: _firstNameController,
                      label: const Text('First Name'),
                      placeholder: const Text('Ahmad'),
                      validator: (v) =>
                          v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    ShadInputFormField(
                      id: 'lastName',
                      controller: _lastNameController,
                      label: const Text('Last Name'),
                      placeholder: const Text('Razif'),
                      validator: (v) =>
                          v.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Email
              ShadCard(
                padding: const EdgeInsets.all(20),
                child: ShadInputFormField(
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
              ),
              const SizedBox(height: 12),

              // DOB + Gender
              ShadCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ShadButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
