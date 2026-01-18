class UserInvestment {
  final String id;
  final String userId;
  final String vehicleId;
  final String vehicleName;
  final double amountInvested;
  final DateTime investedAt;
  final String status; // Active, Paused, Completed
  final double currentReturns;

  UserInvestment({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.vehicleName,
    required this.amountInvested,
    required this.investedAt,
    required this.status,
    required this.currentReturns,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'amountInvested': amountInvested,
      'investedAt': investedAt.toIso8601String(),
      'status': status,
      'currentReturns': currentReturns,
    };
  }

  factory UserInvestment.fromMap(Map<String, dynamic> map) {
    return UserInvestment(
      id: map['id'],
      userId: map['userId'],
      vehicleId: map['vehicleId'],
      vehicleName: map['vehicleName'],
      amountInvested: map['amountInvested'],
      investedAt: DateTime.parse(map['investedAt']),
      status: map['status'],
      currentReturns: map['currentReturns'],
    );
  }
}
