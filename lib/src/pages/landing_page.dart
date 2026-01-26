import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:showcaseview/showcaseview.dart';
import 'deriv_webview_screen.dart';
import 'login_page.dart';
import 'profile_screen.dart';
import 'vehicle_investment_screen.dart';
import 'investment_data.dart';
import 'notifications_screen.dart';
import 'investment_details_view.dart';
import 'security_page.dart';
import 'notification_preferences_page.dart';
import 'support_screen.dart';
import 'about_us_screen.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/animated_nav_bar.dart';
import '../helpers/risk_helper.dart';
import '../helpers/currency_helper.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  int _selectedIndex = 0; 
  late AnimationController _bellController;
  bool _isNavCollapsed = false;
  bool _isChangingPage = false;

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _vehiclesKey = GlobalKey();
  final GlobalKey _accountKey = GlobalKey();
  final GlobalKey _notificationsKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _lipKey = GlobalKey();

  static final List<String> _titles = ['Home', 'Vehicles', 'Account'];
  static final List<IconData> _icons = [Icons.home, Icons.directions_car, Icons.account_balance_wallet];

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const VehiclePage(),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    investmentManager.addListener(_onUpdate);
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startBellAnimation();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        _homeKey, _vehiclesKey, _accountKey, _notificationsKey, _profileKey, _lipKey
      ]);
    });
  }

  void _startBellAnimation() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (investmentManager.notifications.isNotEmpty && mounted) {
        _bellController.forward(from: 0).then((_) => _bellController.reverse());
      }
    });
  }

  @override
  void dispose() {
    investmentManager.removeListener(_onUpdate);
    _bellController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _isChangingPage = true);
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
          _isChangingPage = false;
        });
      }
    });
  }

  void _handleProfileMenu(String value) {
    if (value == 'profile') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else if (value == 'logout') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        leading: Showcase(
          key: _notificationsKey,
          description: 'View your trade and session alerts here.',
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _bellController,
                builder: (context, child) => Transform.rotate(angle: _bellController.value * 0.2, child: child),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28, color: Colors.grey),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                ),
              ),
              if (investmentManager.notifications.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('${investmentManager.notifications.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DerivWebViewScreen())),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
                child: ClipOval(child: Image.asset('assets/images/deriv.png', width: 16, height: 16, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(width: 10),
            Text(_titles[_selectedIndex], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          Showcase(
            key: _profileKey,
            description: 'Manage your profile and security settings.',
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: PopupMenuButton<String>(
                onSelected: _handleProfileMenu,
                icon: const Icon(Icons.person_outline, color: Colors.grey, size: 28),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'profile', child: ListTile(leading: Icon(Icons.person), title: Text('My Profile'))),
                  const PopupMenuItem<String>(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Logout', style: TextStyle(color: Colors.red)))),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: KeyedSubtree(key: ValueKey<int>(_selectedIndex), child: _widgetOptions.elementAt(_selectedIndex)),
          ),
          if (_isChangingPage) Positioned.fill(child: Container(color: Colors.white, child: const SpinningRedLoader())),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Showcase(
            key: _lipKey,
            description: 'Tap here to collapse or expand the navigation bar.',
            child: GestureDetector(
              onTap: () => setState(() => _isNavCollapsed = !_isNavCollapsed),
              child: Container(
                width: 60, height: 20,
                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))]),
                child: Icon(_isNavCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: Colors.orange),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isNavCollapsed ? 0 : 80,
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12, width: 0.5))),
            curve: Curves.easeInOut,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedNavBarItem(icon: _icons[0], isSelected: _selectedIndex == 0, isChanging: _isChangingPage, onTap: () => _onItemTapped(0), showcaseKey: _homeKey, description: 'Return to your dashboard at any time.'),
                AnimatedNavBarItem(icon: _icons[1], isSelected: _selectedIndex == 1, isChanging: _isChangingPage, onTap: () => _onItemTapped(1), showcaseKey: _vehiclesKey, description: 'Browse and select vehicles for your next ride.'),
                AnimatedNavBarItem(icon: _icons[2], isSelected: _selectedIndex == 2, isChanging: _isChangingPage, onTap: () => _onItemTapped(2), showcaseKey: _accountKey, description: 'Check your overall balance and history.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _carouselController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.7, initialPage: 1000);
    _carouselController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _carouselController.page!;
        });
      }
    });
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = investmentManager.activeInvestments.length;
    final totalTrades = investmentManager.totalTrades;
    final winsRatio = totalTrades == 0 ? 0.0 : (investmentManager.winsCount / totalTrades);
    final lossesRatio = totalTrades == 0 ? 0.0 : (investmentManager.lossesCount / totalTrades);
    
    double totalRiskValue = 0;
    for (var inv in investmentManager.activeInvestments) {
      switch (inv.riskDegree.toLowerCase()) {
        case 'low': totalRiskValue += 1; break;
        case 'medium': totalRiskValue += 2; break;
        case 'high': totalRiskValue += 3; break;
      }
    }
    final riskRatio = activeCount == 0 ? 0.0 : (totalRiskValue / (activeCount * 3));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                _BalanceCard(title: 'Running Balance', amount: 'R ${CurrencyHelper.format(investmentManager.storageBalance)}', color: Colors.blue, isFullWidth: true),
                const SizedBox(height: 24),
                if (activeCount > 0) ...[
                  const SectionTitle(title: 'Rides Overview'),
                  const SizedBox(height: 12),
                  _RidesOverviewChart(),
                  const SizedBox(height: 24),
                  
                  Column(
                    children: [
                      _BalanceCard(title: 'Returns Accrued', amount: '${(winsRatio * 100).toStringAsFixed(0)}%', color: Colors.green, isFullWidth: true),
                      const SizedBox(height: 12),
                      _BalanceCard(title: 'Portfolio Risk', amount: '${(riskRatio * 100).toStringAsFixed(0)}%', color: Colors.blue, isFullWidth: true, child: _RiskPieChart(ratio: riskRatio)),
                      const SizedBox(height: 12),
                      _BalanceCard(title: 'Losses Accrued', amount: '${(lossesRatio * 100).toStringAsFixed(0)}%', color: Colors.red, isFullWidth: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                const InvestmentTipsWidget(),
                const SizedBox(height: 24),
                const SectionTitle(title: 'Running Investments'),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const ListRunningInvestments(),
          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  Widget _buildCarouselItem(int index, double wins, double risk, double losses) {
    if (index == 0) {
      return _BalanceCard(title: 'Returns Accrued', amount: '${(wins * 100).toStringAsFixed(0)}%', color: Colors.green);
    } else if (index == 1) {
      return _BalanceCard(title: 'Portfolio Risk', amount: '${(risk * 100).toStringAsFixed(0)}%', color: Colors.blue, child: _RiskPieChart(ratio: risk));
    } else {
      return _BalanceCard(title: 'Losses Accrued', amount: '${(losses * 100).toStringAsFixed(0)}%', color: Colors.red);
    }
  }
}

class _RidesOverviewChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trade>>(
      stream: investmentManager.allTradesStream,
      builder: (context, snapshot) {
        final trades = snapshot.data ?? [];
        if (trades.isEmpty) return const SizedBox(height: 150, child: Center(child: Text('Waiting for trade data...')));
        List<FlSpot> spots = [];
        double currentVal = 0;
        spots.add(const FlSpot(0, 0));
        final displayTrades = trades.length > 50 ? trades.sublist(0, 50) : trades;
        for (int i = 0; i < displayTrades.length; i++) {
          final chronologicalIndex = displayTrades.length - 1 - i;
          currentVal += displayTrades[chronologicalIndex].profitLoss;
          spots.add(FlSpot((i + 1).toDouble(), currentVal));
        }
        return Container(
          height: 150, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white10)),
              titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
              lineBarsData: [LineChartBarData(spots: spots, color: Colors.blue, isCurved: true, barWidth: 2, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)))],
            ),
          ),
        );
      }
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) { return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center); }
}

class _RiskPieChart extends StatelessWidget {
  final double ratio;
  const _RiskPieChart({required this.ratio});
  @override
  Widget build(BuildContext context) {
    return Column(children: [const SizedBox(height: 10), SizedBox(height: 40, width: 40, child: Stack(children: [CircularProgressIndicator(value: ratio, strokeWidth: 4, backgroundColor: Colors.blue.shade100, color: ratio > 0.7 ? Colors.red : ratio > 0.4 ? Colors.orange : Colors.green), Center(child: Text('${(ratio * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))]))]);
  }
}

class InvestmentTipsWidget extends StatefulWidget {
  const InvestmentTipsWidget({super.key});
  @override
  State<InvestmentTipsWidget> createState() => _InvestmentTipsWidgetState();
}

class _InvestmentTipsWidgetState extends State<InvestmentTipsWidget> with SingleTickerProviderStateMixin {
  String _tip = 'Loading advice...';
  bool _isLoading = true;
  bool _isDrinkingTip = false;
  Timer? _refreshTimer;
  Timer? _jumpTimer;
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _fetchTip();
    _refreshTimer = Timer.periodic(const Duration(seconds: 90), (timer) => _fetchTip());
    _jumpController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0).chain(CurveTween(curve: Curves.bounceIn)), weight: 50),
    ]).animate(_jumpController);
    _jumpTimer = Timer.periodic(const Duration(seconds: 30), (timer) { if (mounted) _jumpController.forward(from: 0); });
  }

  Future<void> _fetchTip() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _isDrinkingTip = Random().nextBool();
    if (_isDrinkingTip) {
      final drinkingTips = ["Drink water between every glass of beer to deriv more profit and stay hydrated!", "Stay classy! Enjoy your rides but remember: drink responsibly, deriv profit.", "A clear mind leads to clear trades. Drink water, deriv success.", "Alcohol and trading don't mix. Keep the beer for the 'fun' rides, use water for the profit rides.", "Deriv struggle usually starts with a third beer. Stick to water for the wins!"];
      if (mounted) setState(() { _tip = drinkingTips[Random().nextInt(drinkingTips.length)]; _isLoading = false; });
    } else {
      try {
        final response = await http.get(Uri.parse('https://api.adviceslip.com/advice'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (mounted) setState(() { _tip = data['slip']['advice']; _isLoading = false; });
        }
      } catch (e) { if (mounted) setState(() { _tip = 'Stay diversified and invest for the long term!'; _isLoading = false; }); }
    }
  }

  @override
  void dispose() { _refreshTimer?.cancel(); _jumpTimer?.cancel(); _jumpController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (investmentManager.activeInvestments.isNotEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _isDrinkingTip ? Colors.orange.shade50 : Colors.yellow.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: _isDrinkingTip ? Colors.orange.shade200 : Colors.yellow.shade700)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [AnimatedBuilder(animation: _jumpAnimation, builder: (context, child) => Transform.translate(offset: Offset(0, _jumpAnimation.value), child: child), child: Icon(_isDrinkingTip ? Icons.sports_bar : Icons.lightbulb, color: _isDrinkingTip ? Colors.orange.shade900 : Colors.yellow.shade900, size: 24)), const SizedBox(width: 8), Text(_isDrinkingTip ? 'Drinking Advice' : 'Investment Tip', style: TextStyle(fontWeight: FontWeight.bold, color: _isDrinkingTip ? Colors.orange.shade900 : Colors.yellow.shade900))]),
          const SizedBox(height: 8),
          _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_tip, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ListRunningInvestments extends StatelessWidget {
  const ListRunningInvestments({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: investmentManager,
      builder: (context, _) {
        final active = investmentManager.activeInvestments;
        final completed = investmentManager.completedInvestments;
        return Column(children: [
          if (active.isEmpty) 
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Are you ready to ride?",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            )
          else ...active.map((inv) => StreamBuilder<InvestmentStatus>(stream: inv.statusStream, builder: (context, snapshot) {
            final status = snapshot.data ?? inv.status;
            return AnimatedOpacity(opacity: status == InvestmentStatus.closed ? 0.0 : 1.0, duration: const Duration(milliseconds: 500), child: Card(margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16), clipBehavior: Clip.antiAlias, child: Stack(children: [Row(children: [SizedBox(width: MediaQuery.of(context).size.width * 0.25, height: 100, child: Image.asset(inv.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.orange)))), Expanded(child: ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvestmentDetailsView(investment: inv))), title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [if (status == InvestmentStatus.paused) ...[const Text('Session Paused', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)), Text('Paused: ${inv.currentPauseDuration.inSeconds}s', style: const TextStyle(fontSize: 10, color: Colors.grey))] else _LiveTimer(startTime: inv.startTime, investment: inv)]), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(icon: Icon(status == InvestmentStatus.paused ? Icons.play_arrow : Icons.pause, color: status == InvestmentStatus.paused ? Colors.green : Colors.orange, size: 20), onPressed: () => investmentManager.togglePause(inv.id), padding: EdgeInsets.zero, constraints: const BoxConstraints()), const SizedBox(height: 8), IconButton(icon: const Icon(Icons.stop_circle, color: Colors.red, size: 20), onPressed: () => investmentManager.stopInvestment(inv.id), padding: EdgeInsets.zero, constraints: const BoxConstraints())])))],), const Positioned(top: 8, left: 8, child: CircleAvatar(radius: 12, backgroundColor: Colors.white70, child: Icon(Icons.radio_button_unchecked, size: 14, color: Colors.black87)))])));
          })),
          if (completed.isEmpty) 
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "History repeats itself, keep riding",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            )
          else ...[const SizedBox(height: 24), const SectionTitle(title: 'Investment History'), const SizedBox(height: 12), ...completed.map((inv) => Card(margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16), clipBehavior: Clip.antiAlias, child: Stack(children: [Row(children: [SizedBox(width: MediaQuery.of(context).size.width * 0.25, height: 100, child: Image.asset(inv.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.orange)))), Expanded(child: ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvestmentDetailsView(investment: inv))), title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right), subtitle: Text('Ride Concluded', style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.right), trailing: const Icon(Icons.chevron_right, color: Color(0xFFBA8858))))],), const Positioned(top: 6, left: 6, child: CircleAvatar(radius: 10, backgroundColor: Colors.white70, child: Icon(Icons.radio_button_unchecked, size: 12, color: Colors.black87)))])))]
        ]);
      }
    );
  }
}

class _LiveTimer extends StatefulWidget {
  final DateTime startTime;
  final Investment investment;
  const _LiveTimer({required this.startTime, required this.investment});
  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late Timer _timer;
  late Duration _duration;
  @override
  void initState() { super.initState(); _duration = widget.investment.activeDuration; _timer = Timer.periodic(const Duration(seconds: 1), (timer) { if (mounted && widget.investment.status == InvestmentStatus.active) setState(() { _duration = widget.investment.activeDuration; }); }); }
  @override
  void dispose() { _timer.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return Text('Live Session: ${_duration.inSeconds}s', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)); }
}

class _BalanceCard extends StatelessWidget {
  final String title, amount;
  final Color color;
  final bool isFullWidth;
  final Widget? child;
  const _BalanceCard({required this.title, required this.amount, required this.color, this.isFullWidth = false, this.child});
  @override
  Widget build(BuildContext context) {
    return Container(width: isFullWidth ? double.infinity : null, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10), textAlign: TextAlign.center), const SizedBox(height: 4), Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center), if (child != null) child!]));
  }
}

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      children: const [
        VehicleCard(name: 'Kentucky Rounder', investment: 'R 25,000', lotSize: '40 Units', risk: 'Medium', guarantee: '15%', img: 'assets/images/car_1.jpeg', type: 'Fleet Asset', tradingOption: 'Rise/Fall'),
        VehicleCard(name: 'Levora', investment: 'R 18,500', lotSize: '25 Units', risk: 'Low', guarantee: '12%', img: 'assets/images/car_2.jpeg', type: 'Logistics Asset', tradingOption: 'Higher/Lower'),
        VehicleCard(name: 'Matchbox', investment: 'R 12,000', lotSize: '15 Units', risk: 'High', guarantee: '20%', img: 'assets/images/car_3.jpeg', type: 'Economy Asset', tradingOption: 'Touch/No Touch'),
      ],
    );
  }
}

class VehicleCard extends StatelessWidget {
  final String name, investment, lotSize, risk, guarantee, img, type, tradingOption;
  const VehicleCard({super.key, required this.name, required this.investment, required this.lotSize, required this.risk, required this.guarantee, required this.img, required this.type, required this.tradingOption});
  @override
  Widget build(BuildContext context) {
    final riskColor = getRiskColor(risk);
    return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias, elevation: 2, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleInvestmentScreen(name: name, investment: investment, lotSize: lotSize, risk: risk, guarantee: guarantee, img: img))), child: SizedBox(height: 140, child: Stack(children: [Row(children: [SizedBox(width: MediaQuery.of(context).size.width * 0.25, height: double.infinity, child: Image.asset(img, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: Image.asset('assets/images/deriv.png', fit: BoxFit.cover)))), Expanded(child: Padding(padding: const EdgeInsets.only(left: 30, right: 16, top: 12, bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24), textAlign: TextAlign.left), Row(children: [Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(width: 8), const Icon(Icons.circle, size: 4, color: Colors.grey), const SizedBox(width: 8), Text(tradingOption, style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600))]), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: getRiskDecoration(risk), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.assessment, size: 14, color: Colors.white), const SizedBox(width: 4), Text(risk, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))])), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: getGreenGradientDecoration(), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified, size: 14, color: Colors.white), const SizedBox(width: 4), Text(guarantee, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]))])])))],), Positioned(left: (MediaQuery.of(context).size.width * 0.25) - 20, top: 20, child: Column(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.warning_amber_rounded, size: 12, color: riskColor), Text(guarantee, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)]))), const SizedBox(height: 4), const Icon(Icons.emoji_events, size: 24, color: Colors.amber, shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))])]))]))));
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Align(alignment: Alignment.center, child: Text('Account Balances', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), const SizedBox(height: 20), _AccountTile(label: 'Storage Balance', amount: 'R ${CurrencyHelper.format(investmentManager.storageBalance)}', icon: Icons.account_balance), _AccountTile(label: 'Returns Accrued', amount: 'R ${CurrencyHelper.format(investmentManager.returnsBalance)}', icon: Icons.trending_up, color: Colors.green), _AccountTile(label: 'Losses Accrued', amount: 'R ${CurrencyHelper.format(investmentManager.lossesBalance)}', icon: Icons.trending_down, color: Colors.red), const SizedBox(height: 40), const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Card(child: _SettingsTile(title: 'Security \u0026 Funds', icon: Icons.security, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage())))), Card(child: _SettingsTile(title: 'Notification Preferences', icon: Icons.notifications, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPreferencesPage())))), Card(child: _SettingsTile(title: 'Support', icon: Icons.help_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())))), Card(child: _SettingsTile(title: 'About Us', icon: Icons.info_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()))))]));
  }
}

class _AccountTile extends StatelessWidget {
  final String label, amount;
  final IconData icon;
  final Color? color;
  const _AccountTile({required this.label, required this.amount, required this.icon, this.color});
  @override
  Widget build(BuildContext context) { return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: Container(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: (color ?? Colors.orange).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]), child: Icon(icon, color: color ?? Colors.orange)), title: Text(label, textAlign: TextAlign.center), trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center))); }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _SettingsTile({required this.title, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) { return ListTile(onTap: onTap, trailing: const Icon(Icons.chevron_right, color: Color(0xFFBA8858)), title: Text(title, textAlign: TextAlign.left), leading: Container(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))]), child: Icon(icon, color: const Color(0xFFCE2029)))); }
}
