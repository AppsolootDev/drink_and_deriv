import 'package:flutter/material.dart';
import 'investment_data.dart';
import 'deriv_webview_screen.dart';
import '../helpers/currency_helper.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final String userName;

  const AdminUserDetailScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');

    return Theme(
      data: Theme.of(context).copyWith(
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '$userName Details',
            style: josefineStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Details Section
              Text(
                'USER DETAILS',
                style: josefineStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailTile('Full Name', userName, josefineStyle),
              _buildDetailTile('Email', '${userName.toLowerCase().replaceAll(' ', '.')}@example.com', josefineStyle),
              _buildDetailTile('Phone', '+27 12 345 6789', josefineStyle),
              _buildDetailTile('Running Balance', CurrencyHelper.format(investmentManager.storageBalance), josefineStyle),
              _buildDetailTile('Returns Accrued', CurrencyHelper.format(investmentManager.returnsBalance), josefineStyle, valueColor: Colors.green),
              _buildDetailTile('Losses Accrued', CurrencyHelper.format(investmentManager.lossesBalance), josefineStyle, valueColor: Colors.red),
              
              const SizedBox(height: 32),

              // Deriv Information Section
              Text(
                'DERIV INFORMATION',
                style: josefineStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailTile('Account ID', 'CR1234567', josefineStyle),
              _buildDetailTile('Currency', 'USD', josefineStyle),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DerivWebViewScreen()));
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('VIEW DERIV ACCOUNT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCE2029),
                    side: const BorderSide(color: Color(0xFFCE2029)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Active Trades Section
              Text(
                'ACTIVE TRADES',
                style: josefineStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Use real data from investmentManager if available, otherwise mocks for specific user
              ...investmentManager.activeInvestments.map((inv) => _ActiveTradeItem(investment: inv, textStyle: josefineStyle)),
              
              const SizedBox(height: 32),

              // Previous Trades Section
              Text(
                'PREVIOUS TRADES',
                style: josefineStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ...investmentManager.completedInvestments.map((inv) => _PreviousTradeItem(investment: inv, textStyle: josefineStyle)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, TextStyle baseStyle, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: baseStyle.copyWith(color: Colors.grey, fontSize: 15)),
          Text(value, style: baseStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor)),
        ],
      ),
    );
  }
}

class _ActiveTradeItem extends StatefulWidget {
  final Investment investment;
  final TextStyle textStyle;

  const _ActiveTradeItem({
    required this.investment,
    required this.textStyle,
  });

  @override
  State<_ActiveTradeItem> createState() => _ActiveTradeItemState();
}

class _ActiveTradeItemState extends State<_ActiveTradeItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminTradeDetailScreen(investment: widget.investment),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(widget.investment.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Icon(Icons.directions_car, color: Colors.orange)),
        ),
        title: Text(
          widget.investment.name,
          style: widget.textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Gains: ${CurrencyHelper.format(widget.investment.sessionGains)}',
          style: widget.textStyle.copyWith(fontSize: 13, color: Colors.green),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IconButton(
            //   icon: Icon(widget.investment.isPaused ? Icons.play_arrow : Icons.pause,
            //     color: widget.investment.isPaused ? Colors.lightGreen : Colors.orange),
            //   onPressed: () {
            //     setState(() {
            //       investmentManager.togglePause(widget.investment.id);
            //     });
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Color(0xFFCE2029)),
              onPressed: () {
                investmentManager.stopInvestment(widget.investment.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousTradeItem extends StatelessWidget {
  final Investment investment;
  final TextStyle textStyle;

  const _PreviousTradeItem({required this.investment, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.history, color: Colors.grey),
        title: Text(investment.name, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('Final Result: ${CurrencyHelper.format(investment.sessionGains - investment.sessionLosses)}',
          style: textStyle.copyWith(fontSize: 13, color: (investment.sessionGains - investment.sessionLosses) >= 0 ? Colors.green : Colors.red)),
        trailing: const Icon(Icons.chevron_right, size: 16),
      ),
    );
  }
}

class AdminTradeDetailScreen extends StatelessWidget {
  final Investment investment;

  const AdminTradeDetailScreen({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');

    return Scaffold(
      appBar: AppBar(
        title: Text('${investment.name} Performance', style: josefineStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Session Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Vehicle', style: josefineStyle.copyWith(color: Colors.grey)),
                      Text(investment.vehicleName, style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target Amount', style: josefineStyle.copyWith(color: Colors.grey)),
                      Text(investment.investment, style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Session Gains', style: josefineStyle.copyWith(color: Colors.grey)),
                      Text(CurrencyHelper.format(investment.sessionGains), 
                        style: josefineStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Session Losses', style: josefineStyle.copyWith(color: Colors.grey)),
                      Text(CurrencyHelper.format(investment.sessionLosses), 
                        style: josefineStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('PERFORMANCE GRAPH', style: josefineStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            
            // Trade Performance Graph
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpots(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text('TRADE LOG', style: josefineStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            
            // Stream trade updates
            StreamBuilder<List<Trade>>(
              stream: investment.tradesSubject.stream,
              builder: (context, snapshot) {
                final trades = snapshot.data ?? [];
                if (trades.isEmpty) return const Center(child: Text('No trades recorded yet.'));
                return Column(
                  children: trades.map((t) => _TradeLogTile(trade: t, style: josefineStyle)).toList(),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    // Generate some mock spots based on gain history if available
    final trades = investment.trades;
    if (trades.isEmpty) return [const FlSpot(0, 0)];
    
    List<FlSpot> spots = [];
    double runningTotal = 0;
    spots.add(const FlSpot(0, 0));
    
    for (int i = 0; i < trades.length; i++) {
      runningTotal += trades[i].isWin ? trades[i].profitLoss : trades[i].profitLoss;
      spots.add(FlSpot((i + 1).toDouble(), runningTotal));
    }
    return spots;
  }
}

class _TradeLogTile extends StatelessWidget {
  final Trade trade;
  final TextStyle style;
  const _TradeLogTile({required this.trade, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trade.isWin ? 'WIN' : 'LOSS', 
                style: style.copyWith(fontWeight: FontWeight.bold, color: trade.isWin ? Colors.green : Colors.red)),
              Text('Lot: ${CurrencyHelper.format(trade.lot)}', style: style.copyWith(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text('${trade.isWin ? '+' : ''}${CurrencyHelper.format(trade.profitLoss)}',
            style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
