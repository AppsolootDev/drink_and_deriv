import 'package:flutter/material.dart';
import 'investment_data.dart';

class TradeItemScreen extends StatelessWidget {
  final Trade trade;
  const TradeItemScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trade.isWin ? 'Profit' : 'Loss'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(
            trade.isWin ? Icons.trending_up : Icons.trending_down,
            color: trade.isWin ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailCard(),
            const SizedBox(height: 32),
            const Text('Financial Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _ImpactRow(label: 'Net Balance Effect', value: 'R${trade.profitLoss.toStringAsFixed(2)}', color: trade.isWin ? Colors.green : Colors.red),
            _ImpactRow(label: 'Total Deducted', value: 'R${trade.totalCost.toStringAsFixed(2)}', color: Colors.blueGrey),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BACK TO SESSION'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _DetailLine(label: 'Trade Amount', value: 'R${trade.amount.toStringAsFixed(2)}'),
            const Divider(),
            _DetailLine(label: 'Platform Fee (15%)', value: 'R${trade.fee.toStringAsFixed(2)}', color: Colors.orange),
            const Divider(),
            _DetailLine(label: 'Result', value: trade.isWin ? 'WIN' : 'LOSS', color: trade.isWin ? Colors.green : Colors.red),
            const Divider(),
            _DetailLine(label: 'Profit/Loss', value: 'R${trade.profitLoss.toStringAsFixed(2)}', color: trade.isWin ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _DetailLine({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ImpactRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        ],
      ),
    );
  }
}
