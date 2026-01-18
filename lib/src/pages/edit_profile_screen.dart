import 'package:flutter/material.dart';
import 'deriv_webview_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '+27 82 000 0001');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelStyle: TextStyle(fontFamily: 'Josefine', color: Colors.grey),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFC4B5A6),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Change Photo', style: josefineStyle.copyWith(color: Colors.orange)),
              ),
              const SizedBox(height: 20),
              _buildEditField(_nameController, 'Full Name', josefineStyle),
              const SizedBox(height: 16),
              _buildEditField(_emailController, 'Email Address', josefineStyle),
              const SizedBox(height: 16),
              _buildEditField(_phoneController, 'Phone Number', josefineStyle),
              const SizedBox(height: 32),
              
              // Deriv Account Link Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DerivWebViewScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCE2029)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Image.asset('assets/images/deriv.png', width: 20, height: 20, errorBuilder: (c, e, s) => const Icon(Icons.link, color: Color(0xFFCE2029))),
                label: Text(
                  'LINK DERIV ACCOUNT',
                  style: josefineStyle.copyWith(color: const Color(0xFFCE2029), fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile Updated Successfully', style: josefineStyle)),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('SAVE CHANGES', style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: style.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: style.copyWith(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}
