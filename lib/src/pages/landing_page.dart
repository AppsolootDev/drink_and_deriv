import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'deriv_webview_screen.dart';
import 'login_page.dart';
import 'profile_screen.dart';
import 'vehicle_investment_screen.dart';
import 'investment_data.dart';
import 'summary_screen.dart';
import 'notifications_screen.dart';
import 'investment_details_view.dart';
import 'security_page.dart';
import 'signup_page.dart'; 
import 'notification_preferences_page.dart';
import 'support_screen.dart';
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
    
    setState(() {
      _isChangingPage = true;
    });

    // Buffer set to 1 second as requested
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
        leading: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _bellController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _bellController.value * 0.2,
                  child: child,
                );
              },
              child: IconButton(
                icon: const Icon(Icons.notifications_none, size: 28, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
            ),
            if (investmentManager.notifications.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${investmentManager.notifications.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DerivWebViewScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/deriv.png',
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Icon(_icons[_selectedIndex], size: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              onSelected: _handleProfileMenu,
              icon: const Icon(Icons.person_outline, color: Colors.grey, size: 28),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('My Profile'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
          if (_isChangingPage)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: const SpinningRedLoader(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isNavCollapsed = !_isNavCollapsed),
            child: Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Icon(
                _isNavCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.orange,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isNavCollapsed ? 0 : 80,
            color: Colors.white,
            curve: Curves.easeInOut,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_icons.length, (index) {
                return AnimatedNavBarItem(
                  icon: _icons[index],
                  isSelected: _selectedIndex == index,
                  isChanging: _isChangingPage,
                  onTap: () => _onItemTapped(index),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  double _calculateTotalRisk() {
    double totalRiskValue = 0;
    for (var inv in investmentManager.activeInvestments) {
      switch (inv.riskDegree.toLowerCase()) {
        case 'low': totalRiskValue += 1; break;
        case 'medium': totalRiskValue += 2; break;
        case 'high': totalRiskValue += 3; break;
      }
    }
    return totalRiskValue;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = investmentManager.activeInvestments.length;
    final totalRisk = _calculateTotalRisk();
    final riskRatio = activeCount == 0 ? 0.0 : (totalRisk / (activeCount * 3));
    
    final totalTrades = investmentManager.totalTrades;
    final winsRatio = totalTrades == 0 ? 0.0 : (investmentManager.winsCount / totalTrades);
    final lossesRatio = totalTrades == 0 ? 0.0 : (investmentManager.lossesCount / totalTrades);

    return Column(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              _BalanceCard(
                title: 'Running Balance',
                amount: CurrencyHelper.format(investmentManager.storageBalance),
                color: Colors.blue,
                isFullWidth: true,
              ),
              const SizedBox(height: 24),
              
              if (activeCount > 0 || investmentManager.completedInvestments.isNotEmpty) ...[
                const SectionTitle(title: 'Trade Feedback'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _BalanceCard(
                        title: 'Returns Accrued',
                        amount: '${(winsRatio * 100).toStringAsFixed(0)}%',
                        color: Colors.green,
                        child: _MiniRatioChart(ratio: winsRatio, label: 'Wins', color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _BalanceCard(
                        title: 'Losses Accrued',
                        amount: '${(lossesRatio * 100).toStringAsFixed(0)}%',
                        color: Colors.red,
                        child: _MiniRatioChart(ratio: lossesRatio, label: 'Losses', color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _BalanceCard(
                  title: 'Portfolio Risk',
                  amount: '${(riskRatio * 100).toStringAsFixed(0)}%',
                  color: Colors.blue,
                  isFullWidth: true,
                  child: _RiskPieChart(ratio: riskRatio),
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
        Expanded(
          child: const ListRunningInvestments(),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}

class _RiskPieChart extends StatelessWidget {
  final double ratio;
  const _RiskPieChart({required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: ratio,
                strokeWidth: 8,
                backgroundColor: Colors.blue.shade100,
                color: ratio > 0.7 ? Colors.red : ratio > 0.4 ? Colors.orange : Colors.green,
              ),
              Center(
                child: Text('${(ratio * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Risk Exposure', style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
      ],
    );
  }
}

class _MiniRatioChart extends StatelessWidget {
  final double ratio;
  final String label;
  final Color color;
  const _MiniRatioChart({required this.ratio, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 40, width: 40,
          child: CircularProgressIndicator(
            value: ratio,
            strokeWidth: 4,
            backgroundColor: color.withOpacity(0.1),
            color: color,
          ),
        ),
      ],
    );
  }
}

class InvestmentTipsWidget extends StatefulWidget {
  const InvestmentTipsWidget({super.key});

  @override
  State<InvestmentTipsWidget> createState() => _InvestmentTipsWidgetState();
}

class _InvestmentTipsWidgetState extends State<InvestmentTipsWidget> {
  String _tip = 'Loading investment tip...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTip();
  }

  Future<void> _fetchTip() async {
    try {
      final response = await http.get(Uri.parse('https://api.adviceslip.com/advice'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() { _tip = data['slip']['advice']; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _tip = 'Stay diversified and invest for the long term!'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.yellow.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.yellow.shade700)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lightbulb, color: Colors.yellow.shade900, size: 20), const SizedBox(width: 8), Text('Investment Tip', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.shade900))]),
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
    final active = investmentManager.activeInvestments;
    final completed = investmentManager.completedInvestments;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 100.0),
      children: [
        if (active.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No active investments.')),
          )
        else
          ...active.map((inv) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Stack(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InvestmentDetailsView(investment: inv)));
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(inv.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.orange))),
                    ),
                    title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    subtitle: Center(child: _LiveTimer(startTime: inv.startTime)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(inv.isPaused ? Icons.play_arrow : Icons.pause, color: inv.isPaused ? Colors.green : Colors.orange),
                          onPressed: () => investmentManager.togglePause(inv.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop_circle, color: Colors.red),
                          onPressed: () {
                            investmentManager.stopInvestment(inv.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (inv.lastTradeResult != null)
                    Positioned(
                      top: 8, right: 8,
                      child: Text(inv.lastTradeResult!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: inv.lastTradeResult == '+' ? Colors.green : Colors.red)),
                    ),
                ],
              ),
            );
          }).toList(),
        
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionTitle(title: 'Investment History'),
          const SizedBox(height: 12),
          ...completed.map((inv) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => InvestmentDetailsView(investment: inv)));
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(inv.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.orange))),
                ),
                title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                subtitle: const Center(child: Text('Session Closed', style: TextStyle(color: Colors.grey))),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => InvestmentDetailsView(investment: inv)));
                  },
                  child: const Text('TRADE REVIEW'),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }
}

class _LiveTimer extends StatefulWidget {
  final DateTime startTime;
  const _LiveTimer({required this.startTime});
  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late Timer _timer;
  late int _seconds;
  @override
  void initState() {
    super.initState();
    _seconds = DateTime.now().difference(widget.startTime).inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { if (mounted) setState(() => _seconds++); });
  }
  @override
  void dispose() { _timer.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return Text('Live Session: $_seconds s', textAlign: TextAlign.center); }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final bool isFullWidth;
  final Widget? child;
  const _BalanceCard({required this.title, required this.amount, required this.color, this.isFullWidth = false, this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Left aligned settings
        children: [
          const Align(alignment: Alignment.center, child: Text('Account Balances', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          _AccountTile(label: 'Storage Balance', amount: CurrencyHelper.format(investmentManager.storageBalance), icon: Icons.account_balance),
          _AccountTile(label: 'Returns Accrued', amount: CurrencyHelper.format(investmentManager.returnsBalance), icon: Icons.trending_up, color: Colors.green),
          _AccountTile(label: 'Losses Accrued', amount: CurrencyHelper.format(investmentManager.lossesBalance), icon: Icons.trending_down, color: Colors.red),
          const SizedBox(height: 40),
          const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: _SettingsTile(
              title: 'Security & Funds',
              icon: Icons.security,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage())),
            ),
          ),
          Card(
            child: _SettingsTile(
              title: 'Notification Preferences',
              icon: Icons.notifications,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPreferencesPage())),
            ),
          ),
          Card(
            child: _SettingsTile(
              title: 'Support',
              icon: Icons.help_outline,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
      title: Text(title, textAlign: TextAlign.left),
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFCE2029)), // Deriv/Default Red
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color? color;
  const _AccountTile({required this.label, required this.amount, required this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.orange).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color ?? Colors.orange),
        ), 
        title: Text(label, textAlign: TextAlign.center), 
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)
      ),
    );
  }
}

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      children: const [
        VehicleCard(name: 'Kentucky Rounder', investment: 'R25,000', lotSize: '40 Units', risk: 'Medium', guarantee: '15%', img: 'assets/images/car_1.jpeg', type: 'Fleet Asset', tradingOption: 'Rise/Fall'),
        VehicleCard(name: 'Levora', investment: 'R18,500', lotSize: '25 Units', risk: 'Low', guarantee: '12%', img: 'assets/images/car_2.jpeg', type: 'Logistics Asset', tradingOption: 'Higher/Lower'),
        VehicleCard(name: 'Matchbox', investment: 'R12,000', lotSize: '15 Units', risk: 'High', guarantee: '20%', img: 'assets/images/car_3.jpeg', type: 'Economy Asset', tradingOption: 'Touch/No Touch'),
      ],
    );
  }
}

class VehicleCard extends StatelessWidget {
  final String name;
  final String investment;
  final String lotSize;
  final String risk;
  final String guarantee;
  final String img;
  final String type;
  final String tradingOption;

  const VehicleCard({
    super.key,
    required this.name,
    required this.investment,
    required this.lotSize,
    required this.risk,
    required this.guarantee,
    required this.img,
    required this.type,
    required this.tradingOption,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = getRiskColor(risk);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleInvestmentScreen(name: name, investment: investment, lotSize: lotSize, risk: risk, guarantee: guarantee, img: img)));
        },
        child: SizedBox(
          height: 140,
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: double.infinity,
                    child: Image.asset(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Image.asset('assets/images/deriv.png', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 16, top: 12, bottom: 12), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.left),
                          Row(
                            children: [
                              Text(type, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 8),
                              const Icon(Icons.circle, size: 4, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(tradingOption, style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8), 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start, 
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: riskColor, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.assessment, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(risk, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ), 
                              const SizedBox(width: 8), 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(guarantee, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ]
                          )
                        ]
                      )
                    )
                  ),
                ],
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width * 0.25) - 20, 
                top: 20, 
                child: Column(
                  children: [
                    Container(
                      width: 40, height: 40, 
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        shape: BoxShape.circle, 
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                      ), 
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: riskColor), 
                            Text(guarantee, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                          ]
                        )
                      )
                    ), 
                    const SizedBox(height: 4), 
                    const Icon(
                      Icons.emoji_events, 
                      size: 24, 
                      color: Colors.amber,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    )
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
