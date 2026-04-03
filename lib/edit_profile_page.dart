import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/auth_service.dart';
import 'package:tea_go_app/date_text_formatter.dart';
import 'package:tea_go_app/user_model.dart';

const Color _green = Color(0xFF66BB6A);
const Color _lightGreen = Color(0xFFE8F5E9);

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _green))
                : const Text('Save', style: TextStyle(color: _green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 20),
              _buildCard(children: [
                _buildField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  capitalization: TextCapitalization.words,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                _divider(),
                _buildField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  capitalization: TextCapitalization.words,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ]),
              const SizedBox(height: 12),
              _buildCard(children: [
                _buildField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final re = RegExp(r"^[\w.!#\$%&'*+\-/=?^_`{|}~]+@[\w]+\.[a-zA-Z]+");
                    return re.hasMatch(v) ? null : 'Enter a valid email';
                  },
                ),
              ]),
              const SizedBox(height: 12),
              _buildCard(children: [
                _buildField(
                  controller: _dobController,
                  label: 'Date of Birth (DD/MM/YYYY)',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    DateTextFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length != 10) return 'Use DD/MM/YYYY format';
                    return null;
                  },
                ),
                _divider(),
                _buildGenderField(),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final initials = '${widget.user.firstName.isNotEmpty ? widget.user.firstName[0] : ''}${widget.user.lastName.isNotEmpty ? widget.user.lastName[0] : ''}'.toUpperCase();
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: _lightGreen,
            child: Text(initials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _green)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: _green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52);

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon, color: _green, size: 20),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        initialValue: _gender,
        decoration: InputDecoration(
          labelText: 'Gender',
          icon: const Icon(Icons.wc_outlined, color: _green, size: 20),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        onChanged: (v) => setState(() => _gender = v),
        items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }
}
