import 'package:flutter/material.dart';
import 'investment_data.dart';
import 'payment_webview_screen.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _emailCodeController = TextEditingController();
  bool _isVerified = false;
  final String _mockTestCode = "qwertyui12345678";

  void _verifyCode() {
    if (_emailCodeController.text == _mockTestCode) {
      setState(() {
        _isVerified = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Verification Code'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Funds'),
        centerTitle: true,
      ),
      body: !_isVerified ? _buildVerificationView() : _buildFundsManagerView(),
    );
  }

  Widget _buildVerificationView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Verification Required',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'We have sent a 16-digit alphanumeric code to your email. Please enter it below to access your card information and fund management.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailCodeController,
            decoration: const InputDecoration(
              hintText: 'Enter 16-digit code',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vpn_key),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyCode,
              child: const Text('VERIFY EMAIL'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsManagerView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'DEPOSIT', icon: Icon(Icons.add_card)),
              Tab(text: 'WITHDRAW', icon: Icon(Icons.account_balance_wallet_outlined)),
            ],
            labelColor: Colors.orange,
            indicatorColor: Colors.orange,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDepositSection(),
                _buildWithdrawSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositSection() {
    final amountController = TextEditingController();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Funds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Monthly limit: R10,000.00', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: const TextField(
                  decoration: InputDecoration(labelText: 'Expiry (MM/YY)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: const TextField(
                  decoration: InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount to Deposit (R)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 10000) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limit exceeded: Max R10,000.00 per month')));
                } else if (amount > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentWebViewScreen(amount: amount),
                    ),
                  ).then((_) {
                    // Assuming success for mock flow
                    investmentManager.topUp(amount);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funds added successfully!')));
                  });
                }
              },
              child: const Text('PROCEED TO PAYMENT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Withdraw Funds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text(
            'Returns can take up to 48 hours to reflect in your account, but can also take less than 24 hours depending on your bank.',
            style: TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Standard processing time remains 3 business days for final settlement.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 32),
          const TextField(
            decoration: InputDecoration(labelText: 'Bank Account Number', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Branch Code', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(labelText: 'Amount to Withdraw (R)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal request submitted. Returns typically reflect within 24-48 hours.')));
                Navigator.pop(context);
              },
              child: const Text('REQUEST WITHDRAWAL'),
            ),
          ),
        ],
      ),
    );
  }
}
