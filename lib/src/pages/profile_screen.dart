import 'package:flutter/material.dart';
import 'investment_data.dart';
import 'login_page.dart';
import 'edit_profile_screen.dart';
import 'deriv_webview_screen.dart';
import '../helpers/currency_helper.dart';

class ProfileScreen extends StatefulWidget {
  final bool isAdmin;
  const ProfileScreen({super.key, this.isAdmin = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showDerivFields = false;
  final _appIdController = TextEditingController(text: '12345');
  final _accessCodeController = TextEditingController(text: 'ABCDE-FGHIJ-KLMNO');

  @override
  void dispose() {
    _appIdController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');

    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isAdmin ? 'Admin Profile' : 'User Profile', style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            if (!widget.isAdmin)
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: widget.isAdmin ? Colors.blue.shade100 : const Color(0xFFC4B5A6),
                      child: Icon(widget.isAdmin ? Icons.admin_panel_settings : Icons.person, size: 80, color: widget.isAdmin ? Colors.blue : Colors.white),
                    ),
                    if (!widget.isAdmin)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.orange,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(Icons.photo_camera, size: 20, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Identity Section
              SectionHeader(title: widget.isAdmin ? 'Admin Identity' : 'User Details', textStyle: josefineStyle),
              ProfileDetailRow(label: 'Name', value: widget.isAdmin ? 'Platform Admin' : 'John Doe', textStyle: josefineStyle),
              ProfileDetailRow(label: 'Email', value: widget.isAdmin ? 'deriver@admin' : 'john.doe@example.com', textStyle: josefineStyle),
              
              const SizedBox(height: 30),
              
              if (widget.isAdmin) ...[
                // Admin specific section
                SectionHeader(title: 'Portal Access', textStyle: josefineStyle),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DerivWebViewScreen()));
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('ADMIN DERIV ACCOUNT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCE2029),
                      side: const BorderSide(color: Color(0xFFCE2029)),
                    ),
                  ),
                ),
              ] else ...[
                // User Balance Section
                SectionHeader(title: 'Account Details', textStyle: josefineStyle),
                ProfileDetailRow(label: 'Total Investments', value: 'R ${CurrencyHelper.format(investmentManager.storageBalance)}', isEditable: false, textStyle: josefineStyle),
                ProfileDetailRow(label: 'Total Gains', value: 'R ${CurrencyHelper.format(investmentManager.returnsBalance)}', isEditable: false, color: Colors.green, textStyle: josefineStyle),
                ProfileDetailRow(label: 'Total Losses', value: 'R ${CurrencyHelper.format(investmentManager.lossesBalance)}', isEditable: false, color: Colors.red, textStyle: josefineStyle),
                
                const SizedBox(height: 30),
                SectionHeader(title: 'Deriv Connection', textStyle: josefineStyle),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showDerivFields = !_showDerivFields;
                      });
                    },
                    icon: Icon(_showDerivFields ? Icons.visibility_off : Icons.visibility, size: 18),
                    label: const Text('ACCESS MY DERIV ACCOUNT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFCE2029),
                      side: const BorderSide(color: Color(0xFFCE2029)),
                    ),
                  ),
                ),
                
                if (_showDerivFields) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _appIdController,
                    style: josefineStyle.copyWith(fontSize: 19, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'App ID',
                      labelStyle: josefineStyle.copyWith(fontSize: 18),
                      prefixIcon: const Icon(Icons.apps),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _accessCodeController,
                    style: josefineStyle.copyWith(fontSize: 19, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Access Code',
                      labelStyle: josefineStyle.copyWith(fontSize: 18),
                      prefixIcon: const Icon(Icons.vpn_key),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ],
              
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text('Drink & Deryve', style: josefineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text('Version 1.0.0 (Build 24)', style: josefineStyle.copyWith(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: Text('LOG OUT', style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final TextStyle textStyle;
  const SectionHeader({super.key, required this.title, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: textStyle.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;
  final Color? color;
  final TextStyle textStyle;

  const ProfileDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.textStyle,
    this.isEditable = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textStyle.copyWith(color: Colors.grey, fontSize: 18)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: textStyle.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
