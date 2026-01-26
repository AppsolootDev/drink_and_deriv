import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'admin_create_vehicle_page.dart';
import 'admin_user_detail_screen.dart';
import 'investment_data.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/animated_nav_bar.dart';
import '../helpers/currency_helper.dart';

class AdminLandingPage extends StatefulWidget {
  const AdminLandingPage({super.key});

  @override
  State<AdminLandingPage> createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isNavCollapsed = false;
  bool _isChangingPage = false;

  static final List<String> _titles = ['Admin Dashboard', 'User Management', 'Vehicle Management', 'Trade Management'];
  static final List<IconData> _icons = [Icons.dashboard, Icons.people, Icons.directions_bus, Icons.query_stats];

  static final List<Widget> _widgetOptions = <Widget>[
    const AdminHomePage(),
    const UserManagementPage(),
    const AdminVehicleListPage(),
    const TradeSearchPage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _isChangingPage = true;
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
          _isChangingPage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4, 
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: Icon(Icons.notifications_none, size: 28, color: Colors.grey.shade400),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
              child: ClipOval(child: Image.asset('assets/images/deriv_beer.png', width: 16, height: 16, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 10),
            Text(_titles[_selectedIndex], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, size: 28, color: Colors.grey.shade400),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen(isAdmin: true))),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
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
      floatingActionButton: _selectedIndex == 2 
        ? FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCreateVehiclePage())),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add_road, color: Colors.white),
          )
        : null,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isNavCollapsed = !_isNavCollapsed),
            child: Container(
              width: 60, height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
              ),
              child: Icon(_isNavCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: Colors.orange),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isNavCollapsed ? 0 : 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
            ),
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

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Oversight', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _SummaryCard(
            label: 'Total Revenue (Fees)', 
            value: CurrencyHelper.format(investmentManager.totalFees), 
            color: Colors.amber, 
            meta: 'All initial and per-trade fees accumulated.',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeesPaidPage())),
          ),
          _SummaryCard(
            label: 'Total Cash Deposited', 
            value: '500,000.00', 
            color: Colors.blue, 
            meta: 'Total liquidity added by users.',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CashDepositedPage())),
          ),
          const SizedBox(height: 20),
          const Text('Trader Rankings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _RankingCard(title: 'Top Trader (Day)', name: 'Jane Smith', amount: '12,400', color: Colors.green),
          _RankingCard(title: 'Top Trader (Week)', name: 'John Doe', amount: '85,000', color: Colors.blue),
          _RankingCard(title: 'Top Trader (Month)', name: 'Mike Ross', amount: '340,000', color: Colors.purple),
          const SizedBox(height: 24),
          const Text('Vehicle Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _PerformanceTile(label: 'BEST: Kentucky Rounder', value: '250,000', color: Colors.green),
          _PerformanceTile(label: 'WORST: Matchbox', value: '45,000', color: Colors.red),
          const SizedBox(height: 24),
          const Text('Investment Segmentation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _InvestmentSegmentationCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InvestmentSegmentationCard extends StatefulWidget {
  @override
  State<_InvestmentSegmentationCard> createState() => _InvestmentSegmentationCardState();
}

class _InvestmentSegmentationCardState extends State<_InvestmentSegmentationCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Users by Investment Type', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    _buildSection(0, Colors.orange, 45, 'Rise/Fall', Icons.trending_up),
                    _buildSection(1, Colors.blue, 30, 'Higher/Lower', Icons.swap_vert),
                    _buildSection(2, Colors.green, 25, 'Touch/No Touch', Icons.ads_click),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.orange, label: 'Rise/Fall'),
                SizedBox(width: 16),
                _LegendItem(color: Colors.blue, label: 'Higher/Lower'),
                SizedBox(width: 16),
                _LegendItem(color: Colors.green, label: 'Touch/No Touch'),
              ],
            )
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildSection(int index, Color color, double value, String title, IconData icon) {
    final isTouched = touchedIndex == index;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 70.0 : 60.0;

    return PieChartSectionData(
      color: color,
      value: value,
      title: isTouched ? title : '${value.toInt()}%',
      radius: radius,
      titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
      badgeWidget: _Badge(icon, size: isTouched ? 40 : 30, borderColor: color),
      badgePositionPercentageOffset: .98,
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;

  const _Badge(this.icon, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(icon, color: borderColor, size: size * .6),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SummaryCard extends StatefulWidget {
  final String label, value, meta;
  final Color color;
  final VoidCallback onTap;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.meta, required this.onTap});
  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2, 
        margin: const EdgeInsets.only(bottom: 12), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: double.infinity, 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), 
            color: Colors.white,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Text(widget.label, style: const TextStyle(color: Colors.grey, fontSize: 14)), 
                            const SizedBox(height: 8), 
                            Text('R ${widget.value}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                          ]
                        ), 
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20)
                      ]
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeesPaidPage extends StatelessWidget {
  const FeesPaidPage({super.key});
  @override
  Widget build(BuildContext context) {
    final fees = [
      {'user': 'John Doe', 'source': 'Investment Start', 'amount': '150.00', 'date': '2023-10-27'},
      {'user': 'Jane Smith', 'source': 'Trade Fee', 'amount': '7.00', 'date': '2023-10-27'},
      {'user': 'Mike Ross', 'source': 'Investment Start', 'amount': '150.00', 'date': '2023-10-26'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Fees Paid')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fees.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(fees[index]['user']!),
            subtitle: Text(fees[index]['source']!),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('R ${fees[index]['amount']!}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(fees[index]['date']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CashDepositedPage extends StatelessWidget {
  const CashDepositedPage({super.key});
  @override
  Widget build(BuildContext context) {
    final deposits = [
      {'user': 'John Doe', 'amount': '10,000.00', 'fee': '50.00', 'datetime': '2023-10-27 14:20'},
      {'user': 'Jane Smith', 'amount': '5,000.00', 'fee': '25.00', 'datetime': '2023-10-27 09:15'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Deposits')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deposits.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(deposits[index]['user']!),
            subtitle: Text(deposits[index]['datetime']!),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('R ${deposits[index]['amount']!}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Fee: R ${deposits[index]['fee']!}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final String title, name, amount;
  final Color color;
  const _RankingCard({required this.title, required this.name, required this.amount, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.emoji_events, color: color)), 
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)), 
        subtitle: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
        trailing: Text('R $amount', style: TextStyle(color: color, fontWeight: FontWeight.bold))
      )
    );
  }
}

class _PerformanceTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PerformanceTile({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.2))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)), Text('R $value', style: const TextStyle(fontWeight: FontWeight.bold))]));
  }
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});
  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _searchTimer;
  final List<Map<String, dynamic>> _allUsers = [
    {'name': 'John Doe', 'access': 'Full', 'wins': 12, 'total': 15, 'activity': 150},
    {'name': 'Jane Smith', 'access': 'Restricted', 'wins': 5, 'total': 10, 'activity': 80},
    {'name': 'Mike Ross', 'access': 'Full', 'wins': 8, 'total': 8, 'activity': 200},
    {'name': 'Harvey Specter', 'access': 'Full', 'wins': 20, 'total': 22, 'activity': 350},
    {'name': 'Donna Paulsen', 'access': 'Full', 'wins': 5, 'total': 5, 'activity': 50},
  ];
  void _onSearchChanged(String query) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    setState(() => _isSearching = query.isNotEmpty);
    if (query.isEmpty) { setState(() { _searchQuery = ""; _isSearching = false; }); return; }
    _searchTimer = Timer(const Duration(seconds: 2), () { if (mounted) setState(() { _searchQuery = query; _isSearching = false; }); });
  }
  @override
  void dispose() { _searchTimer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> usersToDisplay;
    bool showingTopActive = false;
    if (_searchQuery.isEmpty && !_isSearching) {
      usersToDisplay = List.from(_allUsers)..sort((a, b) => b['activity'].compareTo(a['activity']));
      usersToDisplay = usersToDisplay.take(3).toList();
      showingTopActive = true;
    } else {
      usersToDisplay = _allUsers.where((user) => user['name']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16.0), child: TextField(onChanged: _onSearchChanged, decoration: InputDecoration(hintText: 'Search for users...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade100))),
      if (showingTopActive) const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Align(alignment: Alignment.centerLeft, child: Text('Top 3 Most Active Users', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)))),
      Expanded(child: _isSearching ? const SpinningRedLoader() : usersToDisplay.isEmpty ? const Center(child: Text('No users found.')) : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), itemCount: usersToDisplay.length, itemBuilder: (context, index) {
        final user = usersToDisplay[index];
        final ratio = user['total'] == 0 ? 0.0 : user['wins'] / user['total'];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)), 
            title: Text(user['name']), 
            subtitle: Row(children: [
              Text(
                'Ratio: ${(ratio * 100).toStringAsFixed(0)}%', 
                style: const TextStyle(
                  color: Color(0xFFD2B48C), // Light Brown
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    )
                  ]
                )
              ), 
              const SizedBox(width: 12), 
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)), child: Text(user['access'], style: const TextStyle(fontSize: 10, color: Colors.grey)))
            ]),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminUserDetailScreen(userName: user['name']))), 
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(value: user['access'] == 'Full', onChanged: (val) {}),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete User'),
                        content: Text('Are you sure you want to delete ${user['name']}? This will send them their Deriv details and remove platform assets.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                          TextButton(
                            onPressed: () {
                              // Simulated delete logic
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user['name']} deleted successfully.')));
                            },
                            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          )
        );
      })),
    ]);
  }
}

class AdminVehicleListPage extends StatelessWidget {
  const AdminVehicleListPage({super.key});
  @override
  Widget build(BuildContext context) {
    final vehicles = [
      {'name': 'Kentucky Rounder', 'img': 'assets/images/car_1.jpeg', 'trades': 150, 'gains': 45000.0, 'losses': 5000.0, 'users': 45, 'rating': 4.5, 'type': 'Fleet Asset', 'option': 'Rise/Fall', 'status': 'Open', 'lot': 40},
      {'name': 'Levora', 'img': 'assets/images/car_2.jpeg', 'trades': 80, 'gains': 22500.0, 'losses': 2000.0, 'users': 20, 'rating': 4.2, 'type': 'Logistics Asset', 'option': 'Higher/Lower', 'status': 'Open', 'lot': 25},
      {'name': 'Matchbox', 'img': 'assets/images/car_3.jpeg', 'trades': 40, 'gains': 12000.0, 'losses': 1500.0, 'users': 12, 'rating': 3.8, 'type': 'Economy Asset', 'option': 'Touch/No Touch', 'status': 'Open', 'lot': 15},
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final v = vehicles[index];
        return Card(
          color: Colors.white, elevation: 2, margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(v['img']!.toString(), width: 60, height: 40, fit: BoxFit.cover)),
              title: Text(v['name']!.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(v['type']!.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Analytics Card
                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(child: _VehiclePerformanceCard(gains: v['gains'] as double, losses: v['losses'] as double)),
                              const SizedBox(width: 12),
                              Expanded(child: _VehicleInvestmentCard(invested: (v['gains'] as double) * 2, gains: v['gains'] as double, losses: v['losses'] as double)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DetailRow(label: 'Trading Option', value: v['option']!.toString()),
                      _DetailRow(label: 'Current Status', value: v['status']!.toString(), color: Colors.green),
                      _DetailRow(label: 'Total Lots', value: v['lot']!.toString()),
                      _DetailRow(label: 'Active Investors', value: v['users']!.toString()),
                      _DetailRow(label: 'Total Trades', value: v['trades']!.toString()),
                      _DetailRow(label: 'Net Returns', value: 'R ${CurrencyHelper.format((v['gains'] as double) - (v['losses'] as double))}', color: Colors.blue),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehiclePerformanceCard extends StatelessWidget {
  final double gains, losses;
  const _VehiclePerformanceCard({required this.gains, required this.losses});
  @override
  Widget build(BuildContext context) {
    final total = gains + losses;
    final winRatio = total == 0 ? 0.0 : gains / total;
    return Column(
      children: [
        const Text('Performance', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        SizedBox(height: 60, width: 60, child: PieChart(PieChartData(sectionsSpace: 0, centerSpaceRadius: 20, sections: [
          PieChartSectionData(color: Colors.green, value: gains, radius: 10, showTitle: false),
          PieChartSectionData(color: Colors.red, value: losses, radius: 10, showTitle: false),
        ]))),
        const SizedBox(height: 8),
        Text('${(winRatio * 100).toStringAsFixed(0)}% Win', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }
}

class _VehicleInvestmentCard extends StatelessWidget {
  final double invested, gains, losses;
  const _VehicleInvestmentCard({required this.invested, required this.gains, required this.losses});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Financials', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        SizedBox(height: 60, child: BarChart(BarChartData(
          gridData: FlGridData(show: false), titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: invested / 1000, color: Colors.blue, width: 6)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: gains / 1000, color: Colors.green, width: 6)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: losses / 1000, color: Colors.red, width: 6)]),
          ],
        ))),
        const SizedBox(height: 8),
        const Text('Inv/Gain/Loss', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _DetailRow({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black, fontSize: 14))]));
  }
}

class TradeSearchPage extends StatefulWidget {
  const TradeSearchPage({super.key});
  @override
  State<TradeSearchPage> createState() => _TradeSearchPageState();
}

class _TradeSearchPageState extends State<TradeSearchPage> {
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _searchTimer;
  final List<Map<String, String>> _allTrades = [
    {'id': 't1', 'user': 'John Doe', 'vehicle': 'Kentucky Rounder', 'gains': 'R 1,200', 'losses': 'R 50', 'balance': 'R 10,000', 'time': '2023-10-27 10:30', 'option': 'Rise/Fall', 'value': 'R 500'},
    {'id': 't2', 'user': 'Jane Smith', 'vehicle': 'Levora', 'gains': 'R 800', 'losses': 'R 20', 'balance': 'R 5,000', 'time': '2023-10-27 11:15', 'option': 'Higher/Lower', 'value': 'R 300'},
    {'id': 't3', 'user': 'Mike Johnson', 'vehicle': 'Matchbox', 'gains': 'R 400', 'losses': 'R 100', 'balance': 'R 2,500', 'time': '2023-10-27 09:45', 'option': 'Touch/No Touch', 'value': 'R 200'},
  ];
  void _onSearchChanged(String query) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    setState(() => _isSearching = query.isNotEmpty);
    if (query.isEmpty) { setState(() { _searchQuery = ""; _isSearching = false; }); return; }
    _searchTimer = Timer(const Duration(seconds: 2), () { if (mounted) setState(() { _searchQuery = query; _isSearching = false; }); });
  }
  @override
  void dispose() { _searchTimer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> tradesToDisplay;
    bool showingRecent = false;
    if (_searchQuery.isEmpty && !_isSearching) {
      tradesToDisplay = List.from(_allTrades)..sort((a, b) => b['time']!.compareTo(a['time']!));
      tradesToDisplay = tradesToDisplay.take(1).toList();
      showingRecent = true;
    } else {
      tradesToDisplay = _allTrades.where((trade) => trade['user']!.toLowerCase().contains(_searchQuery.toLowerCase()) || trade['vehicle']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16.0), child: TextField(onChanged: _onSearchChanged, decoration: InputDecoration(hintText: 'Search for vehicles or users...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade100))),
      if (showingRecent) const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Align(alignment: Alignment.centerLeft, child: Text('Most Recent Trade', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)))),
      Expanded(child: _isSearching ? const SpinningRedLoader() : tradesToDisplay.isEmpty ? const Center(child: Text('No trades found.')) : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), itemCount: tradesToDisplay.length, itemBuilder: (context, index) {
        final trade = tradesToDisplay[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16), 
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TradeDetailPage(trade: trade))),
            title: Text(trade['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(trade['vehicle']!),
            trailing: const Icon(Icons.chevron_right),
          )
        );
      })),
    ]);
  }
}

class TradeDetailPage extends StatelessWidget {
  final Map<String, String> trade;
  const TradeDetailPage({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final double gains = double.parse(trade['gains']!.replaceAll('R', '').replaceAll(',', '').trim());
    final double losses = double.parse(trade['losses']!.replaceAll('R', '').replaceAll(',', '').trim());
    final bool isProfit = gains >= losses;

    return Scaffold(
      appBar: AppBar(title: const Text('Trade Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('User Overall Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text('R ${trade['balance']!}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Trader', value: trade['user']!),
            _DetailRow(label: 'Trade Time', value: trade['time']!),
            const Divider(height: 32),
            const Text('VEHICLE DETAILS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 12),
            _DetailRow(label: 'Vehicle Name', value: trade['vehicle']!),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: isProfit ? Colors.green : Colors.red, size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trade['option']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('Trade Result', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _DetailRow(label: 'Trade Value', value: 'R ${trade['value']!}'),
                    _DetailRow(label: 'Trade Time', value: trade['time']!),
                    _DetailRow(label: 'Net Effect', value: 'R ${trade['gains']!}', color: Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('PLATFORM REVENUE IMPACT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
              child: _DetailRow(label: 'Fee Revenue Contribution', value: 'R 7.00', color: Colors.amber.shade900),
            ),
          ],
        ),
      ),
    );
  }
}
