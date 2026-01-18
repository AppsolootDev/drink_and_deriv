class User {
  final String id;
  final String fullName;
  final String email;
  final String cellNumber;
  final String profileImageUrl;
  final DateTime memberSince;
  final double totalInvested;
  final int totalWins;
  final int totalTrades;
  final String access;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.cellNumber,
    required this.profileImageUrl,
    required this.memberSince,
    required this.totalInvested,
    this.totalWins = 0,
    this.totalTrades = 0,
    this.access = 'Full',
  });

  double get winRatio => totalTrades == 0 ? 0 : totalWins / totalTrades;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'cellNumber': cellNumber,
      'profileImageUrl': profileImageUrl,
      'memberSince': memberSince.toIso8601String(),
      'totalInvested': totalInvested,
      'totalWins': totalWins,
      'totalTrades': totalTrades,
      'access': access,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      cellNumber: map['cellNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      memberSince: DateTime.parse(map['memberSince']),
      totalInvested: map['totalInvested']?.toDouble() ?? 0.0,
      totalWins: map['totalWins'] ?? 0,
      totalTrades: map['totalTrades'] ?? 0,
      access: map['access'] ?? 'Full',
    );
  }
}
