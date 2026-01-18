import 'package:flutter/material.dart';
import '../helpers/currency_helper.dart';

class SummaryScreen extends StatelessWidget {
  final double totalInvested;
  final double totalGains;
  final double totalLosses;

  const SummaryScreen({
    super.key,
    required this.totalInvested,
    required this.totalGains,
    required this.totalLosses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Summary'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Session Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildSummaryRow('Total Invested', totalInvested),
            _buildSummaryRow('Total Gains', totalGains, color: Colors.green),
            _buildSummaryRow('Total Losses', totalLosses, color: Colors.red),
            const Divider(height: 40),
            _buildSummaryRow('Net Profit/Loss', totalGains - totalLosses, 
                color: (totalGains - totalLosses) >= 0 ? Colors.green : Colors.red,
                isBold: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            'R${CurrencyHelper.format(value)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
