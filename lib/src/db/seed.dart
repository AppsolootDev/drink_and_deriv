import 'package:drink_and_deryve/src/models/user_model.dart';
import 'package:drink_and_deryve/src/models/vehicle_model.dart';
import 'package:drink_and_deryve/src/models/investment_model.dart';
import 'package:drink_and_deryve/src/db/db_helper.dart';

class DatabaseSeeder {
  static Future<void> seedData() async {
    final db = DatabaseService();
    await db.clearAll();

    // Seed 10 Users with Cell Numbers
    for (int i = 1; i <= 10; i++) {
      final user = User(
        id: 'user_$i',
        fullName: i == 1 ? 'John Doe' : i == 2 ? 'Jane Smith' : i == 3 ? 'Mike Ross' : 'User $i',
        email: 'user$i@example.com',
        cellNumber: '+27 82 000 000$i',
        profileImageUrl: 'https://placeholder.com/user$i.png',
        memberSince: DateTime(2023, 1, 15),
        totalInvested: 5000.0 * i,
        totalWins: i * 2,
        totalTrades: i * 3,
        access: i % 4 == 0 ? 'Restricted' : 'Full',
      );
      await db.insert('users', user.toMap());
    }

    // Seed Vehicles with fixed image assets
    final vehicles = [
      InvestmentVehicle(
        id: 'v_01',
        name: 'Kentucky Rounder',
        type: 'Fleet Asset',
        tradingOption: 'Rise/Fall',
        targetAmount: 25000.0,
        lotSize: 40,
        lotPrice: 625.0,
        status: 'Open',
        expectedRoi: 15.0,
        maturityMonths: 24,
        description: 'The Kentucky Rounder is a high-performance long-haul fleet vehicle.',
        imageUrl: 'assets/images/car_1.jpeg',
      ),
      InvestmentVehicle(
        id: 'v_02',
        name: 'Levora',
        type: 'Logistics Asset',
        tradingOption: 'Higher/Lower',
        targetAmount: 18500.0,
        lotSize: 25,
        lotPrice: 740.0,
        status: 'Open',
        expectedRoi: 12.5,
        maturityMonths: 18,
        description: 'The Levora specializes in urban logistics.',
        imageUrl: 'assets/images/car_2.jpeg',
      ),
      InvestmentVehicle(
        id: 'v_03',
        name: 'Matchbox',
        type: 'Economy Asset',
        tradingOption: 'Touch/No Touch',
        targetAmount: 12000.0,
        lotSize: 15,
        lotPrice: 800.0,
        status: 'Open',
        expectedRoi: 10.0,
        maturityMonths: 12,
        description: 'Our Matchbox tier focuses on compact economy fleet scaling.',
        imageUrl: 'assets/images/car_3.jpeg',
      ),
    ];

    for (var vehicle in vehicles) {
      await db.insert('vehicles', vehicle.toMap());
    }

    // Seed 3 User Investments
    final investments = [
      UserInvestment(
        id: 'inv_01', userId: 'user_01', vehicleId: 'v_01', vehicleName: 'Kentucky Rounder',
        amountInvested: 25000.0, investedAt: DateTime.now().subtract(const Duration(days: 30)),
        status: 'Active', currentReturns: 1200.0,
      ),
      UserInvestment(
        id: 'inv_02', userId: 'user_01', vehicleId: 'v_02', vehicleName: 'Levora',
        amountInvested: 18500.0, investedAt: DateTime.now().subtract(const Duration(days: 15)),
        status: 'Paused', currentReturns: 800.0,
      ),
      UserInvestment(
        id: 'inv_03', userId: 'user_01', vehicleId: 'v_03', vehicleName: 'Matchbox',
        amountInvested: 12000.0, investedAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Active', currentReturns: 400.0,
      ),
    ];

    for (var inv in investments) {
      await db.insert('investments', inv.toMap());
    }
  }
}
