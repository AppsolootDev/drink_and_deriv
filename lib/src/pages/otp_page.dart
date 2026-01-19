import 'package:flutter/material.dart';
import 'landing_page.dart';

class OtpPage extends StatefulWidget {
  final String destination;
  const OtpPage({super.key, required this.destination, required bool isTutorial});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  final String _testOtp = "123456"; // Fake OTP for test purposes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Enter the OTP sent to your email and SMS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'OTP sent to: ${widget.destination}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '(Test OTP: 123456)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_open),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_otpController.text == _testOtp) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid OTP. Please use 123456 for testing.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('VERIFY & ACCESS'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test OTP sent: 123456')),
                );
              },
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
