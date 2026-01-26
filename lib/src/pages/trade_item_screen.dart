import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'investment_data.dart';
import '../helpers/currency_helper.dart';

class TradeItemScreen extends StatelessWidget {
  final Trade trade;
  const TradeItemScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');
    final bool isProfit = trade.isWin;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trade.type.name, style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFBA8858)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header as a Card with icon on the far right
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProfit ? 'PROFITABLE TRADE' : 'TRADE LOSS',
                          style: josefineStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isProfit ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(trade.time),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      size: 40,
                      color: isProfit ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _DetailLine(label: 'Lot Size', value: 'R ${trade.lot.toStringAsFixed(2)}', style: josefineStyle),
                    const Divider(height: 24),
                    _DetailLine(label: 'Net Profit/Loss', value: '${isProfit ? "+" : ""}R ${CurrencyHelper.format(trade.profitLoss)}', color: isProfit ? Colors.green : Colors.red, style: josefineStyle),
                    const Divider(height: 24),
                    _DetailLine(label: 'Platform Fee', value: 'R ${trade.fee.toStringAsFixed(2)}', style: josefineStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Balance Impact Card
            const Text('Balance Impact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.blue.shade50.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _DetailLine(label: 'Balance Before', value: 'R ${CurrencyHelper.format(trade.balanceBefore)}', style: josefineStyle),
                    const SizedBox(height: 12),
                    _DetailLine(label: 'Balance After', value: 'R ${CurrencyHelper.format(trade.balanceAfter)}', color: Colors.blue.shade700, style: josefineStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trade Description
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _getTradeDescription(trade),
                style: josefineStyle.copyWith(height: 1.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BACK TO SESSION'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTradeDescription(Trade trade) {
    final result = trade.isWin ? 'successful' : 'unsuccessful';
    return 'This was a ${trade.type.name} ride on ${trade.vehicleName}. The investor allocated R ${trade.lot.toStringAsFixed(2)} for this specific entry. The outcome resulted in a $result position, affecting the overall running balance by R ${trade.profitLoss.abs().toStringAsFixed(2)}. Platform fees of R ${trade.fee.toStringAsFixed(2)} were applied to maintain secure execution.';
  }
}

class _DetailLine extends StatelessWidget {
  final String label, value;
  final Color? color;
  final TextStyle style;
  const _DetailLine({required this.label, required this.value, this.color, required this.style});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(color: Colors.grey, fontSize: 14)),
        Text(value, style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      ],
    );
  }
}
