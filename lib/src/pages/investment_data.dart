import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../helpers/currency_helper.dart';

enum TradeType { digitOptions, binaryOptions }

class Trade {
  final String id;
  final double amount;
  final double fee;
  final bool isWin;
  final double profitLoss;
  final double totalCost;
  final double balanceAfter;
  final DateTime time;
  final TradeType type;
  final String vehicleName;

  Trade({
    required this.id,
    required this.amount,
    required this.fee,
    required this.isWin,
    required this.profitLoss,
    required this.totalCost,
    required this.balanceAfter,
    required this.time,
    required this.type,
    required this.vehicleName,
  });
}

class AppNotification {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    this.icon = Icons.notifications,
  });
}

class Investment {
  final String id;
  final String name; // Unique Name
  final String vehicleName;
  final String investment;
  final String lotSize;
  final String imageUrl;
  final String riskDegree;
  final String returnGuarantee;
  final DateTime startTime;
  bool isPaused;
  bool isClosed;
  String? lastTradeResult;
  final BehaviorSubject<List<Trade>> tradesSubject;
  double sessionGains;
  double sessionLosses;
  double? takeProfit;
  double? stopLoss;

  Investment({
    required this.id,
    required this.name,
    required this.vehicleName,
    required this.investment,
    required this.lotSize,
    required this.imageUrl,
    required this.riskDegree,
    required this.returnGuarantee,
    required this.startTime,
    this.isPaused = false,
    this.isClosed = false,
    this.lastTradeResult,
    this.sessionGains = 0.0,
    this.sessionLosses = 0.0,
    this.takeProfit,
    this.stopLoss,
    List<Trade>? initialTrades,
  }) : tradesSubject = BehaviorSubject<List<Trade>>.seeded(initialTrades ?? []);

  List<Trade> get trades => tradesSubject.value;

  void dispose() {
    tradesSubject.close();
  }
}

class InvestmentManager extends ChangeNotifier {
  final List<Investment> _activeInvestments = [];
  final List<Investment> _completedInvestments = [];
  final List<AppNotification> _notifications = [];
  
  double _storageBalance = 100000.0;
  double _totalGains = 0.0;
  double _totalLosses = 0.0;
  double _totalFees = 0.0;
  double _highestDeposit = 0.0;
  
  int _winsCount = 0;
  int _lossesCount = 0;
  final double _initialTradeFee = 150.0;

  // Global defaults
  double? defaultTakeProfit;
  double? defaultStopLoss;

  Timer? _hourlyTimer;

  InvestmentManager() {
    _startHourlyTimer();
  }

  List<Investment> get activeInvestments => _activeInvestments;
  List<Investment> get completedInvestments => _completedInvestments;
  List<AppNotification> get notifications => _notifications;
  double get storageBalance => _storageBalance;
  double get returnsBalance => _totalGains;
  double get lossesBalance => _totalLosses;
  double get totalFees => _totalFees;
  int get winsCount => _winsCount;
  int get lossesCount => _lossesCount;
  int get totalTrades => _winsCount + _lossesCount;

  void _startHourlyTimer() {
    _hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (_activeInvestments.isNotEmpty) {
        addNotification(
          'Active Investment Update',
          'You currently have ${_activeInvestments.length} active investments running. Check your dashboard for details.',
          Icons.update,
        );
      }
    });
  }

  void addNotification(String title, String message, [IconData icon = Icons.notifications]) {
    _notifications.insert(0, AppNotification(
      title: title,
      message: message,
      time: DateTime.now(),
      icon: icon,
    ));
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void startInvestment(Investment investment, BuildContext context) {
    if (_activeInvestments.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 10 concurrent trades'), backgroundColor: Colors.red));
      return;
    }
    if (_storageBalance - _initialTradeFee < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient funds'), backgroundColor: Colors.red));
      return;
    }

    // Apply mandatory stop loss logic
    if (investment.stopLoss == null) {
      investment.stopLoss = defaultStopLoss ?? (_highestDeposit * 0.1);
    }
    if (investment.takeProfit == null) {
      investment.takeProfit = defaultTakeProfit;
    }

    _storageBalance -= _initialTradeFee;
    _totalFees += _initialTradeFee;
    _activeInvestments.add(investment);
    
    addNotification('Investment Started', 'Successfully started "${investment.name}" using ${investment.vehicleName}.', Icons.play_arrow);
    notifyListeners();
  }

  void stopInvestment(String id) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index != -1) {
      final inv = _activeInvestments[index];
      inv.isClosed = true;
      _completedInvestments.add(inv);
      _activeInvestments.removeAt(index);
      addNotification('Investment Stopped', 'The investment session "${inv.name}" has been closed.', Icons.stop);
      notifyListeners();
    }
  }

  void recordTrade(String id, double amount, bool isWin, TradeType type) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index == -1 || _activeInvestments[index].isPaused) return;

    final inv = _activeInvestments[index];
    final fee = amount * 0.15; // 15% trade fee
    final totalCost = amount + fee;
    final profitLoss = isWin ? amount * 0.30 : -amount;

    _storageBalance -= fee;
    _totalFees += fee;

    if (isWin) {
      _storageBalance += profitLoss;
      _totalGains += profitLoss;
      inv.sessionGains += profitLoss;
      _winsCount++;
    } else {
      _storageBalance += profitLoss;
      _totalLosses += profitLoss.abs();
      inv.sessionLosses += profitLoss.abs();
      _lossesCount++;
    }

    final newTrade = Trade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      fee: fee,
      isWin: isWin,
      profitLoss: profitLoss,
      totalCost: totalCost,
      balanceAfter: _storageBalance,
      time: DateTime.now(),
      type: type,
      vehicleName: inv.vehicleName,
    );

    inv.tradesSubject.add([newTrade, ...inv.trades]);
    updateLastResult(id, isWin ? '+' : '-');

    // Check Take Profit / Stop Loss
    if (inv.takeProfit != null && inv.sessionGains >= inv.takeProfit!) {
      stopInvestment(id);
      addNotification('Take Profit Reached', 'Session "${inv.name}" reached your take profit limit.', Icons.auto_graph);
    } else if (inv.stopLoss != null && inv.sessionLosses >= inv.stopLoss!) {
      stopInvestment(id);
      addNotification('Stop Loss Reached', 'Session "${inv.name}" reached your stop loss limit.', Icons.warning);
    } else if (_storageBalance < 10) {
      stopInvestment(id);
      addNotification('Auto Termination', 'Session "${inv.name}" stopped because balance reached R10.', Icons.error_outline);
    }

    notifyListeners();
  }

  void updateLastResult(String id, String result) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index != -1) {
      _activeInvestments[index].lastTradeResult = result;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () {
        final i = _activeInvestments.indexWhere((i) => i.id == id);
        if (i != -1) {
          _activeInvestments[i].lastTradeResult = null;
          notifyListeners();
        }
      });
    }
  }

  void togglePause(String id) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index != -1) {
      _activeInvestments[index].isPaused = !_activeInvestments[index].isPaused;
      addNotification(
        _activeInvestments[index].isPaused ? 'Investment Paused' : 'Investment Resumed',
        'Session "${_activeInvestments[index].name}" has been ${_activeInvestments[index].isPaused ? 'paused' : 'resumed'}.',
        _activeInvestments[index].isPaused ? Icons.pause : Icons.play_arrow,
      );
      notifyListeners();
    }
  }

  void topUp(double amount) {
    _storageBalance += amount;
    if (amount > _highestDeposit) _highestDeposit = amount;
    addNotification('Funds Deposited', 'Successfully deposited R${CurrencyHelper.format(amount)} to your storage balance.', Icons.account_balance_wallet);
    notifyListeners();
  }

  void withdraw(double amount) {
    _storageBalance -= amount;
    addNotification('Withdrawal Requested', 'Your request to withdraw R${CurrencyHelper.format(amount)} is being processed (3 business days).', Icons.money_off);
    notifyListeners();
  }

  bool isInvestingInVehicle(String vehicleName) {
    return _activeInvestments.any((i) => i.vehicleName == vehicleName);
  }
}

final investmentManager = InvestmentManager();
