import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'investment_data.dart';
import 'trade_item_screen.dart';

class InvestmentDetailsView extends StatefulWidget {
  final Investment investment;
  const InvestmentDetailsView({super.key, required this.investment});

  @override
  State<InvestmentDetailsView> createState() => _InvestmentDetailsViewState();
}

class _InvestmentDetailsViewState extends State<InvestmentDetailsView> {
  Timer? _tradeTimer;
  late double _startingBalance;

  @override
  void initState() {
    super.initState();
    _startingBalance = investmentManager.storageBalance;
    investmentManager.addListener(_onManagerUpdate);
    _startMockTrades();
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  void _startMockTrades() {
    _tradeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.investment.isPaused || widget.investment.isClosed) return;
      if (investmentManager.storageBalance < 10) {
        _tradeTimer?.cancel();
        return;
      }
      
      final random = Random();
      final amount = 25.0 + random.nextDouble() * 100;
      
      // Select random trade type
      final type = random.nextBool() ? TradeType.digitOptions : TradeType.binaryOptions;
      final isWin = random.nextBool();

      investmentManager.recordTrade(widget.investment.id, amount, isWin, type);
    });
  }

  @override
  void dispose() {
    _tradeTimer?.cancel();
    investmentManager.removeListener(_onManagerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.investment;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${inv.name} Review'),
        actions: [
          if (!inv.isClosed) ...[
            IconButton(
              icon: Icon(inv.isPaused ? Icons.play_arrow : Icons.pause, color: inv.isPaused ? Colors.green : Colors.orange),
              onPressed: () => investmentManager.togglePause(inv.id),
            ),
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: () {
                investmentManager.stopInvestment(inv.id);
              },
            )
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (inv.isClosed) _buildClosureSummary(inv),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SummaryCard(title: 'Total Gains', value: 'R${investmentManager.returnsBalance.toStringAsFixed(2)}', color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Total Loss', value: 'R${investmentManager.lossesBalance.toStringAsFixed(2)}', color: Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _SummaryCard(title: 'Start Balance', value: 'R ${_startingBalance.toStringAsFixed(2)}', color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Running Balance', value: 'R ${investmentManager.storageBalance.toStringAsFixed(2)}', color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Trading Performance', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildChart(),
            const Divider(),
            const Text('Trade History', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTradeList(),
            if (!inv.isClosed && investmentManager.storageBalance < 25)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  onPressed: () => investmentManager.topUp(100),
                  child: const Text('TOP UP ACCOUNT'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosureSummary(Investment inv) {
    final totalTrades = inv.trades.length;
    final netProfit = inv.sessionGains - inv.sessionLosses;
    
    return Card(
      color: Colors.blueGrey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('INVESTMENT CONCLUDED', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 20),
            _SummaryRow('Total Trades', '$totalTrades', Colors.white),
            _SummaryRow('Session Gains', 'R${inv.sessionGains.toStringAsFixed(2)}', Colors.green),
            _SummaryRow('Session Losses', 'R${inv.sessionLosses.toStringAsFixed(2)}', Colors.red),
            const Divider(color: Colors.white24, height: 32),
            _SummaryRow('Net Performance', 'R${netProfit.toStringAsFixed(2)}', netProfit >= 0 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _SummaryRow(String label, String value, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return StreamBuilder<List<Trade>>(
      stream: widget.investment.tradesSubject.stream,
      builder: (context, snapshot) {
        final trades = snapshot.data ?? [];
        if (trades.isEmpty) return const SizedBox(height: 150, child: Center(child: Text('No trades yet.')));

        List<FlSpot> spots = [];
        double currentVal = 0;
        spots.add(const FlSpot(0, 0));
        
        for (int i = 0; i < trades.length; i++) {
          final chronologicalIndex = trades.length - 1 - i;
          currentVal += trades[chronologicalIndex].profitLoss;
          spots.add(FlSpot((i + 1).toDouble(), currentVal));
        }

        double minProfit = spots.map((s) => s.y).reduce(min);
        double maxProfit = spots.map((s) => s.y).reduce(max);
        minProfit = min(0, minProfit) - 50;
        maxProfit = max(0, maxProfit) + 50;

        return Container(
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.only(right: 16, top: 16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: LineChart(
            LineChartData(
              minY: minProfit,
              maxY: maxProfit,
              gridData: const FlGridData(show: true, drawVerticalLine: true),
              titlesData: const FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade400)),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [HorizontalLine(y: 0, color: Colors.red.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5])],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTradeList() {
    return StreamBuilder<List<Trade>>(
      stream: widget.investment.tradesSubject.stream,
      builder: (context, snapshot) {
        final trades = snapshot.data ?? [];
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: trade.isWin ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TradeItemScreen(trade: trade)),
                  );
                },
                dense: true,
                title: Text('Trade R${trade.amount.toStringAsFixed(0)} (${trade.type == TradeType.digitOptions ? "Digit" : "Binary"})'),
                subtitle: Text('Fee Paid: R${trade.fee.toStringAsFixed(2)}'),
                trailing: Text(
                  '${trade.isWin ? '+' : ''}R${trade.profitLoss.toStringAsFixed(2)}',
                  style: TextStyle(color: trade.isWin ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      }
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
