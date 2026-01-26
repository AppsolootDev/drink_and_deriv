import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'investment_data.dart';
import 'trade_item_screen.dart';
import '../helpers/currency_helper.dart';

class InvestmentDetailsView extends StatefulWidget {
  final Investment investment;
  const InvestmentDetailsView({super.key, required this.investment});

  @override
  State<InvestmentDetailsView> createState() => _InvestmentDetailsViewState();
}

class _InvestmentDetailsViewState extends State<InvestmentDetailsView> {
  late double _startingBalance;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Trade> _displayTrades = [];
  bool _showAllTrades = false;

  @override
  void initState() {
    super.initState();
    _startingBalance = investmentManager.storageBalance;
    _displayTrades.addAll(widget.investment.trades);
    investmentManager.addListener(_onManagerUpdate);
    
    widget.investment.tradesSubject.stream.listen((allTrades) {
      if (allTrades.isNotEmpty && (_displayTrades.isEmpty || allTrades.first.id != _displayTrades.first.id)) {
        _addNewTrade(allTrades.first);
      }
    });
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  void _addNewTrade(Trade trade) {
    if (!mounted) return;
    setState(() {
      _displayTrades.insert(0, trade);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 600));
    });
  }

  @override
  void dispose() {
    investmentManager.removeListener(_onManagerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.investment;
    const josefineStyle = TextStyle(fontFamily: 'Josefine');
    final int itemsToShow = _showAllTrades ? _displayTrades.length : min(10, _displayTrades.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Review', style: josefineStyle),
        centerTitle: true,
        actions: [
          if (!inv.isClosed) ...[
            IconButton(
              icon: Icon(inv.isPaused ? Icons.play_arrow : Icons.pause, color: inv.isPaused ? Colors.green : Colors.orange),
              onPressed: () => investmentManager.togglePause(inv.id),
            ),
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: () => investmentManager.stopInvestment(inv.id),
            )
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMasterSessionCard(inv, josefineStyle),
            const SizedBox(height: 24),
            
            // Trading Performance Table
            _buildTradingPerformanceTable(josefineStyle),
            const SizedBox(height: 24),

            Text('Performance Chart', style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
            _buildChart(),
            const Divider(),
            Text('Trade History', style: josefineStyle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _displayTrades.isEmpty ? 0 : min(itemsToShow * 80.0, 600.0),
              ),
              child: AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: itemsToShow,
                itemBuilder: (context, index, animation) {
                  if (index >= _displayTrades.length) return const SizedBox.shrink();
                  final tradeNumber = _displayTrades.length - index;
                  return _buildAnimatedTradeTile(_displayTrades[index], tradeNumber, animation, josefineStyle);
                },
              ),
            ),

            if (_displayTrades.length > 10)
              TextButton(
                onPressed: () => setState(() => _showAllTrades = !_showAllTrades),
                child: Text(_showAllTrades ? 'See less' : 'See all (${_displayTrades.length} trades)'),
              ),
            
            if (!inv.isClosed && investmentManager.storageBalance < 25)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  onPressed: () => investmentManager.topUp(100),
                  child: const Text('Top up account'),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSessionCard(Investment inv, TextStyle style) {
    final activeDuration = inv.activeDuration;
    final totalDuration = (inv.endTime ?? DateTime.now()).difference(inv.startTime);
    final totalPause = inv.pauseEvents.fold(Duration.zero, (prev, element) => prev + element.duration);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(inv.imageUrl, width: 80, height: 60, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 80, height: 60, color: Colors.grey.shade100, child: const Icon(Icons.directions_car))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.name, style: style.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(inv.vehicleName, style: style.copyWith(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.settings_input_component, color: Colors.orange, size: 24),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50.withOpacity(0.3),
            child: Column(
              children: [
                if (inv.isClosed) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('RIDE CONCLUDED', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CompactStat('Total Gains', 'R ${CurrencyHelper.format(inv.sessionGains)}', Colors.green),
                      _CompactStat('Total Loss', 'R ${CurrencyHelper.format(inv.sessionLosses)}', Colors.red),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CompactStat('Net Result', 'R ${CurrencyHelper.format(inv.sessionGains - inv.sessionLosses)}', 
                        (inv.sessionGains - inv.sessionLosses) >= 0 ? Colors.green : Colors.red),
                      _CompactStat('Trip Duration', '${totalDuration.inMinutes}m ${totalDuration.inSeconds % 60}s', Colors.blueGrey),
                    ],
                  ),
                  const Divider(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TimerBlock('Active Ride', '${activeDuration.inMinutes}m ${activeDuration.inSeconds % 60}s', style),
                    _TimerBlock('Trip Time', '${totalDuration.inMinutes}m ${totalDuration.inSeconds % 60}s', style),
                    _TimerBlock('Pause', '${totalPause.inMinutes}m ${totalPause.inSeconds % 60}s', style),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _CompactStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _TimerBlock(String label, String value, TextStyle style) {
    return Column(
      children: [
        Text(label, style: style.copyWith(fontSize: 10, color: Colors.grey.shade600)),
        Text(value, style: style.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
      ],
    );
  }

  Widget _buildTradingPerformanceTable(TextStyle style) {
    final recentTrades = _displayTrades.take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Performance Summary', style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade50),
                children: [
                  _buildTableCell('#', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                  _buildTableCell('Result', isHeader: true),
                  _buildTableCell('Win', isHeader: true),
                ],
              ),
              ...recentTrades.map((trade) {
                final tradeNumber = _displayTrades.length - _displayTrades.indexOf(trade);
                return TableRow(
                  children: [
                    _buildTableCell('$tradeNumber'),
                    _buildTableCell('R ${trade.amount.toStringAsFixed(0)}'),
                    _buildTableCell(
                      '${trade.isWin ? '+' : ''}R ${CurrencyHelper.format(trade.profitLoss)}',
                      color: trade.isWin ? Colors.green : Colors.red,
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Icon(
                          trade.isWin ? Icons.check_circle : Icons.cancel,
                          color: trade.isWin ? Colors.green : Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 11 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.black87 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildAnimatedTradeTile(Trade trade, int tradeNumber, Animation<double> animation, TextStyle style) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TradeItemScreen(trade: trade))),
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade100,
              child: Text('#$tradeNumber', style: style.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            ),
            title: Text('Trade R ${trade.amount.toStringAsFixed(0)}', style: style.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('Fee Paid: R ${trade.fee.toStringAsFixed(2)}', style: style.copyWith(fontSize: 11)),
            trailing: Icon(
              trade.isWin ? Icons.trending_up : Icons.trending_down,
              color: trade.isWin ? Colors.green : Colors.red,
            ),
          ),
        ),
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

        return Container(
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                 // tooltipBgColor: Colors.grey.shade800,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final index = touchedSpot.x.toInt() - 1;
                      if (index < 0 || index >= trades.length) return null;
                      final trade = trades[trades.length - 1 - index];
                      return LineTooltipItem(
                        'Trade #${index + 1}\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        children: [
                          TextSpan(text: 'Amount: R ${trade.amount.toStringAsFixed(0)}\n', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          TextSpan(text: trade.isWin ? 'PROFIT' : 'LOSS', style: TextStyle(color: trade.isWin ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white)),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots, color: Colors.blue, isCurved: true, barWidth: 3,
                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                    if (index == 0) return FlDotCirclePainter(radius: 0);
                    final trade = trades[trades.length - index];
                    return FlDotCirclePainter(radius: 4, color: trade.isWin ? Colors.green : Colors.red, strokeWidth: 1, strokeColor: Colors.white);
                  }),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))]));
  }
}
