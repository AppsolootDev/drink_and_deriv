import 'dart:ui';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'investment_data.dart';
import 'notifications_screen.dart';
import '../helpers/risk_helper.dart';
import '../helpers/currency_helper.dart';

class VehicleInvestmentScreen extends StatefulWidget {
  final String name;
  final String investment;
  final String lotSize;
  final String risk;
  final String guarantee;
  final String img;

  const VehicleInvestmentScreen({
    super.key,
    required this.name,
    required this.investment,
    required this.lotSize,
    required this.risk,
    required this.guarantee,
    required this.img,
  });

  @override
  State<VehicleInvestmentScreen> createState() => _VehicleInvestmentScreenState();
}

class _VehicleInvestmentScreenState extends State<VehicleInvestmentScreen> with TickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    investmentManager.addListener(_onManagerUpdate);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOut));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
    end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOut));

    _contentController.forward();
  }

  @override
  void dispose() {
    investmentManager.removeListener(_onManagerUpdate);
    _contentController.dispose();
    super.dispose();
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isInvestingInThisVehicle = investmentManager.isInvestingInVehicle(widget.name);
    final riskDecoration = getRiskDecoration(widget.risk);
    final riskColor = getRiskColor(widget.risk);

    String tradingOption = "Rise/Fall";
    if (widget.name == "Levora") tradingOption = "Higher/Lower";
    if (widget.name == "Matchbox") tradingOption = "Touch/No Touch";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.img,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
            ),
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/deriv.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.stars, size: 20, color: riskColor),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Are you ready?",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey.shade100],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            widget.img,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.directions_car_filled, size: 120, color: Colors.orange);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SlideTransition(
                    position: _slideAnimation,
                    child: const Text('Asset Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 16),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildInvestmentDetailCard(riskColor),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: const Text('Trading Option', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 8),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildTradingOptionCard(tradingOption),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: const Text('Risk Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 8),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      _getRiskDescription(widget.risk),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: const Text('Market Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                  const SizedBox(height: 16),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildPerformanceStat(riskColor),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: riskDecoration,
        child: FloatingActionButton(
          onPressed: _showInvestmentConfirm, // Always allow opening new trade
          backgroundColor: Colors.transparent, 
          elevation: 4,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _getRiskDescription(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return 'This asset is considered low risk due to high historical stability and stable returns. It is backed by established logistics routes with long-term contracts.';
      case 'medium':
        return 'Moderate risk level. Returns are subject to minor market fluctuations in the transport sector. Ideal for investors looking for balanced growth.';
      case 'high':
        return 'High risk asset with potential for significant returns. Exposed to emerging logistics markets and dynamic fleet scaling strategies.';
      default:
        return 'Risk assessment is based on current market data and asset performance history.';
    }
  }

  Widget _buildInvestmentDetailCard(Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Target Amount', value: widget.investment),
          const Divider(height: 24),
          _DetailRow(label: 'Risk Degree', value: widget.risk),
          const Divider(height: 24),
          _DetailRow(label: 'Return Guarantee', value: widget.guarantee),
          const Divider(height: 24),
          _DetailRow(label: 'Trade Fee', value: 'R7.00'),
        ],
      ),
    );
  }

  Widget _buildTradingOptionCard(String option) {
    String description = "";
    switch (option) {
      case "Rise/Fall":
        description = "Predict if the exit spot will be strictly higher or lower than the entry spot.";
        break;
      case "Higher/Lower":
        description = "Predict if the exit spot will be higher or lower than a target price.";
        break;
      case "Touch/No Touch":
        description = "Predict if the market will touch or not touch a target price during the period.";
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Est. Yield', value: widget.guarantee, color: riskColor),
          Container(width: 1, height: 40, color: riskColor.withOpacity(0.3)),
          _StatItem(label: 'Risk Level', value: widget.risk, color: riskColor),
          Container(width: 1, height: 40, color: riskColor.withOpacity(0.3)),
          _StatItem(label: 'Lot Value', value: 'R850.00', color: riskColor),
        ],
      ),
    );
  }

  void _showInvestmentConfirm() {
    final nameController = TextEditingController();
    final tpController = TextEditingController();
    final slController = TextEditingController();
    final lotSizeController = TextEditingController(text: "100.00");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Investment'),
        content: StatefulBuilder(
          builder: (context, setState) {
            final double lotVal = double.tryParse(lotSizeController.text) ?? 0.0;
            final double guaranteePerc = (double.tryParse(widget.guarantee.replaceAll('%', '')) ?? 15.0) / 100.0;
            final double potWin = lotVal * guaranteePerc;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please configure your investment session:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'drive name',
                      hintText: 'e.g. My Growth',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lotSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Lot Size (Initial Session Funding)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final double stake = double.tryParse(val) ?? 0;
                      if (stake > 0) {
                        tpController.text = (stake * 1.5).toStringAsFixed(2);
                        slController.text = (stake * 1.5 * 0.1).toStringAsFixed(2);
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  // Potential Result Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Potential Outcome per Trade:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text('Estimated Winnings: R ${CurrencyHelper.format(potWin)}', style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600)),
                        Text('Estimated Loss: R ${CurrencyHelper.format(lotVal)}', style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Take Profit (R)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: slController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stop Loss (R)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Note: The lot size will be deducted from your bank balance immediately.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final String name = nameController.text.trim();
              final double? lotSize = double.tryParse(lotSizeController.text);
              final double? tp = double.tryParse(tpController.text);
              final double? sl = double.tryParse(slController.text);

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a session name')));
                return;
              }
              if (lotSize == null || lotSize <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid lot size')));
                return;
              }
              if (lotSize > investmentManager.storageBalance) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lot size cannot exceed bank balance'), backgroundColor: Colors.red));
                return;
              }
              
              if (investmentManager.activeInvestments.any((i) => i.name == name)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session name must be unique')));
                return;
              }

              investmentManager.startInvestment(
                Investment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  vehicleName: widget.name,
                  investment: widget.investment,
                  lotSize: lotSize.toStringAsFixed(2),
                  imageUrl: widget.img,
                  riskDegree: widget.risk,
                  returnGuarantee: widget.guarantee,
                  startTime: DateTime.now(),
                  takeProfit: tp,
                  stopLoss: sl,
                  initialFunding: lotSize,
                  username: DateTime.now().millisecondsSinceEpoch.toString(),
                  derivAppId: '',
                  derivAccessCode: ''
                ),
                context,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Investment "$name" started!')),
              );
            },
            child: const Text('START'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            color: color,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: const Offset(0.0, 0.0),
              ),
            ],
          )
        ),
      ],
    );
  }
}
