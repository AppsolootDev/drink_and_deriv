import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Legal Disclaimer',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Drink & Deryve is a technology platform provided for asset-backed vehicle investment participation. Please read the following terms carefully:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'No Financial Advice',
              'We are NOT financial advisors or technical brokers. All information provided within the app is for informational purposes only. You should consult with a professional financial advisor before making any investment decisions.',
            ),
            _buildSection(
              'User Responsibility',
              'We emphasize the absolute need for users to keep up with their investments and monitor how they are performing in real-time. The responsibility of managing trades lies solely with the account holder.',
            ),
            _buildSection(
              'Automatic Termination',
              'If you do not set a "Take Profit" or "Stop Loss" limit, the investment vehicle will continue to run and trade automatically until your available funds reach a minimum threshold of R10.00.',
            ),
            _buildSection(
              'Minimum Requirements',
              'To initiate any new investment or trade session, a minimum account balance of R60.00 is required.',
            ),
            _buildSection(
              'Refund Policy',
              'All refunds will take 7-14 business days to process. A 10% administrative fee will be deducted from the total refund amount. End users must be certain of their commitment before signing up and depositing funds.',
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'By using this platform, you acknowledge that you have read, understood, and agreed to these terms.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I ACCEPT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}
