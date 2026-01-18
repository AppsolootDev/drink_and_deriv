import 'package:flutter/material.dart';
import 'investment_data.dart';
import 'about_us_screen.dart';
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
              ],
              
              const SizedBox(height: 30),
              
              // Common Section
              SectionHeader(title: 'Support & Info', textStyle: josefineStyle),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text('About Us', style: josefineStyle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
              ),
              
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
          Text(label, style: textStyle.copyWith(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: textStyle.copyWith(
                  fontSize: 17,
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
