import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../helpers/currency_helper.dart';

enum TradeType { 
  digitMatchesDiffers, 
  evenOdd, 
  overUnder, 
  riseFall, 
  higherLower, 
  touchNoTouch, 
  endsBetweenOutside, 
  staysBetweenGoesOutside, 
  asianOptions 
}

extension TradeTypeExtension on TradeType {
  String get name {
    switch (this) {
      case TradeType.digitMatchesDiffers: return 'Digit Matches/Differs';
      case TradeType.evenOdd: return 'Even/Odd';
      case TradeType.overUnder: return 'Over/Under';
      case TradeType.riseFall: return 'Rise/Fall';
      case TradeType.higherLower: return 'Higher/Lower';
      case TradeType.touchNoTouch: return 'Touch/No Touch';
      case TradeType.endsBetweenOutside: return 'Ends Between/Outside';
      case TradeType.staysBetweenGoesOutside: return 'Stays Between/Goes Outside';
      case TradeType.asianOptions: return 'Asian Options';
    }
  }

  IconData get icon {
    switch (this) {
      case TradeType.digitMatchesDiffers: return Icons.fingerprint;
      case TradeType.evenOdd: return Icons.exposure_zero;
      case TradeType.overUnder: return Icons.unfold_more;
      case TradeType.riseFall: return Icons.trending_up;
      case TradeType.higherLower: return Icons.swap_vert;
      case TradeType.touchNoTouch: return Icons.ads_click;
      case TradeType.endsBetweenOutside: return Icons.settings_ethernet;
      case TradeType.staysBetweenGoesOutside: return Icons.border_vertical;
      case TradeType.asianOptions: return Icons.public;
    }
  }
}

enum InvestmentStatus { active, paused, closed }

class AccountBalances {
  final double storageBalance;
  final double returnsAccrued;
  final double lossesAccrued;

  AccountBalances({
    required this.storageBalance,
    required this.returnsAccrued,
    required this.lossesAccrued,
  });
}

class PauseEvent {
  final DateTime startTime;
  DateTime? endTime;

  PauseEvent({required this.startTime, this.endTime});

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}

class Trade {
  final String id;
  final double amount;
  final double fee;
  final bool isWin;
  final double profitLoss;
  final double totalCost;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime time;
  final TradeType type;
  final String vehicleName;
  final String sessionName;
  final double? takeProfit;
  final double? stopLoss;

  Trade({
    required this.id,
    required this.amount,
    required this.fee,
    required this.isWin,
    required this.profitLoss,
    required this.totalCost,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.time,
    required this.type,
    required this.vehicleName,
    required this.sessionName,
    this.takeProfit,
    this.stopLoss,
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
  final String name; 
  final String vehicleName;
  final String investment;
  final String lotSize;
  final String imageUrl;
  final String riskDegree;
  final String returnGuarantee;
  final DateTime startTime;
  DateTime? endTime;
  final double stakeAmount;
  
  final List<PauseEvent> pauseEvents = [];
  final BehaviorSubject<InvestmentStatus> statusSubject;
  final BehaviorSubject<List<Trade>> tradesSubject;
  final PublishSubject<void> _stopSubject = PublishSubject<void>();
  
  String? lastTradeResult;
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
    required this.stakeAmount,
    InvestmentStatus initialStatus = InvestmentStatus.active,
    List<Trade>? initialTrades,
    this.sessionGains = 0.0,
    this.sessionLosses = 0.0,
    this.takeProfit,
    this.stopLoss,
  }) : 
    statusSubject = BehaviorSubject<InvestmentStatus>.seeded(initialStatus),
    tradesSubject = BehaviorSubject<List<Trade>>.seeded(initialTrades ?? []);

  Stream<InvestmentStatus> get statusStream => statusSubject.stream.takeUntil(_stopSubject);
  Stream<List<Trade>> get tradesStream => tradesSubject.stream.takeUntil(_stopSubject);

  InvestmentStatus get status => statusSubject.value;
  bool get isPaused => status == InvestmentStatus.paused;
  bool get isClosed => status == InvestmentStatus.closed;
  List<Trade> get trades => tradesSubject.value;

  Duration get activeDuration {
    Duration totalPause = Duration.zero;
    for (var event in pauseEvents) {
      totalPause += event.duration;
    }
    DateTime end = endTime ?? DateTime.now();
    return end.difference(startTime) - totalPause;
  }

  Duration get currentPauseDuration {
    if (status != InvestmentStatus.paused || pauseEvents.isEmpty) return Duration.zero;
    return pauseEvents.last.duration;
  }

  void stop() {
    if (_stopSubject.isClosed) return;
    _stopSubject.add(null);
    _stopSubject.close();
    statusSubject.add(InvestmentStatus.closed);
    statusSubject.close();
    tradesSubject.close();
  }

  void dispose() {
    stop();
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

  double? defaultTakeProfit;
  double? defaultStopLoss;

  Timer? _tradeGenerationTimer;

  final BehaviorSubject<AccountBalances> balanceSubject = BehaviorSubject<AccountBalances>.seeded(AccountBalances(
    storageBalance: 100000.0,
    returnsAccrued: 0.0,
    lossesAccrued: 0.0,
  ));

  // Global Trades stream for Rides Overview
  final BehaviorSubject<List<Trade>> _allTradesSubject = BehaviorSubject<List<Trade>>.seeded([]);
  final PublishSubject<void> _managerStopSubject = PublishSubject<void>();

  InvestmentManager() {
    _startContinuousTrading();
  }

  Stream<AccountBalances> get balanceStream => balanceSubject.stream.takeUntil(_managerStopSubject);
  Stream<List<Trade>> get allTradesStream => _allTradesSubject.stream.takeUntil(_managerStopSubject);

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

  void _updateBalanceStream() {
    balanceSubject.add(AccountBalances(
      storageBalance: _storageBalance,
      returnsAccrued: _totalGains,
      lossesAccrued: _totalLosses,
    ));
  }

  void resetForNewUser() {
    // Create a copy to safely iterate and stop investments
    final activeCopy = List<Investment>.from(_activeInvestments);
    for (var inv in activeCopy) {
      inv.stop();
    }
    _activeInvestments.clear();
    _completedInvestments.clear();
    _notifications.clear();
    _storageBalance = 100000.0;
    _totalGains = 0.0;
    _totalLosses = 0.0;
    _totalFees = 0.0;
    _highestDeposit = 0.0;
    _winsCount = 0;
    _lossesCount = 0;
    _allTradesSubject.add([]);
    _updateBalanceStream();
    notifyListeners();
  }

  void _startContinuousTrading() {
    _tradeGenerationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Create a copy to avoid concurrent modification if an investment stops during iteration
      final activeCopy = List<Investment>.from(_activeInvestments);
      for (var inv in activeCopy) {
        if (inv.status == InvestmentStatus.active) {
          _generateTradeForInvestment(inv);
        }
      }
    });
  }

  void _generateTradeForInvestment(Investment inv) {
    if (_storageBalance < 10) return;

    final random = Random();
    // Use stake amount for the trade
    final amount = inv.stakeAmount;
    final type = TradeType.values[random.nextInt(TradeType.values.length)];
    final isWin = random.nextBool();

    recordTrade(inv.id, amount, isWin, type);
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

  void topUp(double amount) {
    _storageBalance += amount;
    if (amount > _highestDeposit) _highestDeposit = amount;
    _updateBalanceStream();
    addNotification('Funds Deposited', 'Successfully deposited R ${CurrencyHelper.format(amount)} to your storage balance.', Icons.account_balance_wallet);
    notifyListeners();
  }

  void withdraw(double amount) {
    _storageBalance -= amount;
    _updateBalanceStream();
    addNotification('Withdrawal Requested', 'Your request to withdraw R ${CurrencyHelper.format(amount)} is being processed (3 business days).', Icons.money_off);
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

    investment.stopLoss ??= defaultStopLoss ?? (_highestDeposit * 0.1);
    investment.takeProfit ??= defaultTakeProfit;

    _storageBalance -= _initialTradeFee;
    _totalFees += _initialTradeFee;
    _activeInvestments.add(investment);
    
    _updateBalanceStream();
    addNotification('Investment Started', 'Successfully started "${investment.name}" using ${investment.vehicleName}.', Icons.play_arrow);
    notifyListeners();
  }

  void stopInvestment(String id) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index != -1) {
      final inv = _activeInvestments[index];
      inv.endTime = DateTime.now();
      if (inv.pauseEvents.isNotEmpty && inv.pauseEvents.last.endTime == null) {
        inv.pauseEvents.last.endTime = inv.endTime;
      }
      inv.stop();
      _completedInvestments.insert(0, inv);
      _activeInvestments.removeAt(index);
      addNotification('Investment Stopped', 'The investment session "${inv.name}" has been closed.', Icons.stop);
      _updateBalanceStream();
      notifyListeners();
    }
  }

  void recordTrade(String id, double amount, bool isWin, TradeType type) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index == -1 || _activeInvestments[index].status != InvestmentStatus.active) return;

    final inv = _activeInvestments[index];
    final fee = 7.0; // Fixed flat fee of R7
    final totalCost = amount + fee;
    final profitLoss = isWin ? amount * 0.30 : -amount;

    final balanceBefore = _storageBalance;
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
      balanceBefore: balanceBefore,
      balanceAfter: _storageBalance,
      time: DateTime.now(),
      type: type,
      vehicleName: inv.vehicleName,
      sessionName: inv.name,
      takeProfit: inv.takeProfit,
      stopLoss: inv.stopLoss,
    );

    inv.tradesSubject.add([newTrade, ...inv.trades]);
    
    // Add to global trades list
    final currentAll = _allTradesSubject.value;
    _allTradesSubject.add([newTrade, ...currentAll]);

    updateLastResult(id, isWin ? '+' : '-');

    if (inv.takeProfit != null && inv.sessionGains >= inv.takeProfit!) {
      stopInvestment(id);
      addNotification('Take Profit Reached', 'Session "${inv.name}" reached your take profit limit.', Icons.auto_graph);
    } else if (inv.stopLoss != null && inv.sessionLosses >= inv.stopLoss!) {
      stopInvestment(id);
      addNotification('Stop Loss Reached', 'Session "${inv.name}" reached your stop loss limit.', Icons.warning);
    } else if (_storageBalance < 10) {
      stopInvestment(id);
      addNotification('Auto Termination', 'Session "${inv.name}" stopped because balance reached R 10.', Icons.error_outline);
    }

    _updateBalanceStream();
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
      final inv = _activeInvestments[index];
      if (inv.status == InvestmentStatus.active) {
        inv.statusSubject.add(InvestmentStatus.paused);
        inv.pauseEvents.add(PauseEvent(startTime: DateTime.now()));
        addNotification('Investment Paused', 'Session "${inv.name}" has been paused.', Icons.pause);
      } else if (inv.status == InvestmentStatus.paused) {
        inv.statusSubject.add(InvestmentStatus.active);
        if (inv.pauseEvents.isNotEmpty) {
          inv.pauseEvents.last.endTime = DateTime.now();
        }
        addNotification('Investment Resumed', 'Session "${inv.name}" has been resumed.', Icons.play_arrow);
      }
      _updateBalanceStream();
      notifyListeners();
    }
  }

  bool isInvestingInVehicle(String vehicleName) {
    return _activeInvestments.any((i) => i.vehicleName == vehicleName);
  }

  @override
  void dispose() {
    _tradeGenerationTimer?.cancel();
    _managerStopSubject.add(null);
    _managerStopSubject.close();
    balanceSubject.close();
    _allTradesSubject.close();
    super.dispose();
  }
}

final investmentManager = InvestmentManager();
