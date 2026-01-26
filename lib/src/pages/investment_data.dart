import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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

enum InvestmentStatus { active, closed }

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

class Trade {
  final String id;
  final double lot;
  final double fee;
  final bool isWin;
  final double profitLoss;
  final double totalCost;
  final double balanceBefore;
  final double balanceAfter;
  final double sessionBalanceBefore;
  final double sessionBalanceAfter;
  final DateTime time;
  final TradeType type;
  final String vehicleName;
  final String sessionName;
  final double? takeProfit;
  final double? stopLoss;
  
  final String username;
  final String derivAppId;
  final String derivAccessCode;

  Trade({
    required this.id,
    required this.lot,
    required this.fee,
    required this.isWin,
    required this.profitLoss,
    required this.totalCost,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.sessionBalanceBefore,
    required this.sessionBalanceAfter,
    required this.time,
    required this.type,
    required this.vehicleName,
    required this.sessionName,
    required this.username,
    required this.derivAppId,
    required this.derivAccessCode,
    this.takeProfit,
    this.stopLoss,
  });
}

class AppNotification {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final String? vehicleName;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    this.icon = Icons.notifications,
    this.vehicleName,
  });
}

class Investment {
  final String id;
  final String name; 
  final String vehicleName;
  final String investment;
  final double initialFunding; 
  final String lotSize; 
  final String imageUrl;
  final String riskDegree;
  final String returnGuarantee;
  final DateTime startTime;
  DateTime? endTime;
  
  final String username;
  final String derivAppId;
  final String derivAccessCode;

  final BehaviorSubject<InvestmentStatus> statusSubject;
  final BehaviorSubject<List<Trade>> tradesSubject;
  final BehaviorSubject<double> sessionBalanceSubject;
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
    required this.initialFunding,
    required this.lotSize,
    required this.imageUrl,
    required this.riskDegree,
    required this.returnGuarantee,
    required this.startTime,
    required this.username,
    required this.derivAppId,
    required this.derivAccessCode,
    InvestmentStatus initialStatus = InvestmentStatus.active,
    List<Trade>? initialTrades,
    this.sessionGains = 0.0,
    this.sessionLosses = 0.0,
    this.takeProfit,
    this.stopLoss,
  }) : 
    statusSubject = BehaviorSubject<InvestmentStatus>.seeded(initialStatus),
    tradesSubject = BehaviorSubject<List<Trade>>.seeded(initialTrades ?? []),
    sessionBalanceSubject = BehaviorSubject<double>.seeded(initialFunding);

  Stream<InvestmentStatus> get statusStream => statusSubject.stream.takeUntil(_stopSubject);
  Stream<List<Trade>> get tradesStream => tradesSubject.stream.takeUntil(_stopSubject);
  Stream<double> get balanceStream => sessionBalanceSubject.stream.takeUntil(_stopSubject);

  InvestmentStatus get status => statusSubject.value;
  bool get isClosed => status == InvestmentStatus.closed;
  List<Trade> get trades => tradesSubject.value;
  double get sessionBalance => sessionBalanceSubject.value;

  Duration get activeDuration {
    DateTime end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  void stop() {
    if (_stopSubject.isClosed) return;
    _stopSubject.add(null);
    _stopSubject.close();
    statusSubject.add(InvestmentStatus.closed);
    statusSubject.close();
    tradesSubject.close();
    sessionBalanceSubject.close();
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

  String currentUsername = "John Doe";
  String currentDerivAppId = "12345";
  String currentDerivAccessCode = "ABCDE-FGHIJ-KLMNO";

  late IO.Socket socket;
  Timer? _connectionTimeoutTimer;

  final BehaviorSubject<AccountBalances> balanceSubject = BehaviorSubject<AccountBalances>.seeded(AccountBalances(
    storageBalance: 100000.0,
    returnsAccrued: 0.0,
    lossesAccrued: 0.0,
  ));

  final BehaviorSubject<List<Trade>> _allTradesSubject = BehaviorSubject<List<Trade>>.seeded([]);
  final PublishSubject<void> _managerStopSubject = PublishSubject<void>();

  InvestmentManager() {
    _initSocket();
  }

  void _initSocket() {
    final String socketUrl = Platform.isAndroid ? 'http://10.0.2.2:7500' : 'http://localhost:7500';
    print('Connecting to socket at $socketUrl');
    
    _startConnectionTimeout();

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionAttempts': 5,
    });

    socket.onConnect((_) {
      print('Connected to Socket.io server');
      _connectionTimeoutTimer?.cancel();
      // Re-emit start for all active investments on reconnect
      for (var inv in _activeInvestments) {
        if (inv.status == InvestmentStatus.active) {
          socket.emit('start_investment', {
            'investmentId': inv.id,
            'username': inv.username,
            'derivAppId': inv.derivAppId,
            'derivAccessCode': inv.derivAccessCode,
          });
        }
      }
    });

    socket.onConnectError((err) {
      print('Connection Error: $err');
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.io server - Emergency shutdown triggered');
      _terminateAllActiveInvestments("Connection lost: Session terminated for safety.");
    });

    socket.on('trade_update', (data) {
      print('Received trade update via socket: $data');
      final String invId = data['investmentId'];
      final bool isWin = data['isWin'];
      final double profitLoss = data['profitLoss'].toDouble();

      _handleSocketTrade(invId, isWin, profitLoss);
    });
  }

  void _startConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!socket.connected) {
        print('Server not reached within 10s. Closing connection.');
        socket.disconnect();
        _terminateAllActiveInvestments("Server unavailable: Connection timeout.");
      }
    });
  }

  void _terminateAllActiveInvestments(String reason) {
    if (_activeInvestments.isEmpty) return;
    
    addNotification('Safety Shutdown', reason, Icons.security_rounded);
    
    // Create a copy to avoid concurrent modification issues
    final activeIds = _activeInvestments.map((inv) => inv.id).toList();
    for (var id in activeIds) {
      stopInvestment(id);
    }
    notifyListeners();
  }

  void _handleSocketTrade(String id, bool isWin, double profitLoss) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index == -1 || _activeInvestments[index].status != InvestmentStatus.active) return;

    final inv = _activeInvestments[index];
    final lot = double.tryParse(inv.lotSize) ?? 100.0;
    final fee = lot * 0.01;

    final sessionBalanceBefore = inv.sessionBalance;
    final mainBalanceBefore = _storageBalance;

    if (isWin) {
      inv.sessionGains += profitLoss;
      _totalGains += profitLoss;
      _winsCount++;
    } else {
      inv.sessionLosses += profitLoss.abs();
      _totalLosses += profitLoss.abs();
      _lossesCount++;
    }

    final newSessionBalance = sessionBalanceBefore - fee + profitLoss;
    inv.sessionBalanceSubject.add(newSessionBalance);
    _totalFees += fee;

    final newTrade = Trade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lot: lot,
      fee: fee,
      isWin: isWin,
      profitLoss: profitLoss,
      totalCost: lot + fee,
      balanceBefore: mainBalanceBefore,
      balanceAfter: _storageBalance,
      sessionBalanceBefore: sessionBalanceBefore,
      sessionBalanceAfter: newSessionBalance,
      time: DateTime.now(),
      type: TradeType.riseFall,
      vehicleName: inv.vehicleName,
      sessionName: inv.name,
      username: inv.username,
      derivAppId: inv.derivAppId,
      derivAccessCode: inv.derivAccessCode,
    );

    inv.tradesSubject.add([newTrade, ...inv.trades]);
    _allTradesSubject.add([newTrade, ..._allTradesSubject.value]);

    updateLastResult(id, isWin ? '+' : '-');
    _updateBalanceStream();
    notifyListeners();
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

  void startInvestment(Investment investment, BuildContext context) {
    if (_storageBalance < investment.initialFunding + _initialTradeFee) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance'), backgroundColor: Colors.red));
      return;
    }

    _storageBalance -= investment.initialFunding;
    _storageBalance -= _initialTradeFee;
    _totalFees += _initialTradeFee;
    
    _activeInvestments.add(investment);
    
    print('Emitting start_investment for ${investment.id}');
    socket.emit('start_investment', {
      'investmentId': investment.id,
      'username': investment.username,
      'derivAppId': investment.derivAppId,
      'derivAccessCode': investment.derivAccessCode,
    });

    _updateBalanceStream();
    addNotification('Investment Started', 'Started "${investment.name}" using ${investment.vehicleName}.', Icons.play_arrow, investment.vehicleName);
    notifyListeners();
  }

  void stopInvestment(String id) {
    final index = _activeInvestments.indexWhere((i) => i.id == id);
    if (index != -1) {
      final inv = _activeInvestments[index];
      inv.endTime = DateTime.now();

      _storageBalance += inv.sessionBalance;
      
      if (socket.connected) {
        socket.emit('stop_investment', {'investmentId': id});
      }
      
      inv.stop();
      _completedInvestments.insert(0, inv);
      _activeInvestments.removeAt(index);
      addNotification('Investment Stopped', 'The investment session "${inv.name}" has been closed.', Icons.stop, inv.vehicleName);
      _updateBalanceStream();
      notifyListeners();
    }
  }

  void addNotification(String title, String message, [IconData icon = Icons.notifications, String? vehicleName]) {
    _notifications.insert(0, AppNotification(
      title: title,
      message: message,
      time: DateTime.now(),
      icon: icon,
      vehicleName: vehicleName,
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

  bool isInvestingInVehicle(String vehicleName) {
    return _activeInvestments.any((i) => i.vehicleName == vehicleName);
  }

  @override
  void dispose() {
    _connectionTimeoutTimer?.cancel();
    socket.disconnect();
    _managerStopSubject.add(null);
    _managerStopSubject.close();
    balanceSubject.close();
    _allTradesSubject.close();
    super.dispose();
  }
}

final investmentManager = InvestmentManager();
