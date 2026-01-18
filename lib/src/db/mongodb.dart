import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class MongoDatabase {
  // Collections
  static const String usersCollection = "users";
  static const String vehiclesCollection = "vehicles";
  static const String investmentsCollection = "investments";
  static const String tradesCollection = "trades";
  static const String feesCollection = "fees";

  static late Db db;
  static late DbCollection userCol;
  static late DbCollection vehicleCol;
  static late DbCollection investmentCol;
  static late DbCollection tradeCol;
  static late DbCollection feeCol;

  // Connection String - Replace with your actual Atlas SRV string
  static const String _connectionString = 
      "mongodb+srv://<username>:<password>@cluster0.mongodb.net/drink_and_deryve?retryWrites=true&w=majority";

  static Future<void> connect() async {
    try {
      db = await Db.create(_connectionString);
      await db.open();
      inspect(db);
      
      userCol = db.collection(usersCollection);
      vehicleCol = db.collection(vehiclesCollection);
      investmentCol = db.collection(investmentsCollection);
      tradeCol = db.collection(tradesCollection);
      feeCol = db.collection(feesCollection);
      
      if (kDebugMode) {
        print("Successfully connected to MongoDB Atlas Cloud");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error connecting to MongoDB: $e");
      }
    }
  }

  // --- USER OPERATIONS ---
  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    return await userCol.find().toList();
  }

  static Future<void> updateUserAccess(String userId, String accessLevel) async {
    await userCol.updateOne(where.id(ObjectId.parse(userId)), modify.set('access', accessLevel));
  }

  // --- VEHICLE OPERATIONS ---
  static Future<List<Map<String, dynamic>>> fetchVehicles() async {
    return await vehicleCol.find().toList();
  }

  static Future<void> createVehicle(Map<String, dynamic> vehicleData) async {
    await vehicleCol.insertOne(vehicleData);
  }

  // --- INVESTMENT OPERATIONS ---
  static Future<void> startInvestment(Map<String, dynamic> investmentData) async {
    await investmentCol.insertOne(investmentData);
  }

  static Future<void> updateInvestmentStatus(String invId, bool isPaused, bool isClosed) async {
    await investmentCol.updateOne(
      where.id(ObjectId.parse(invId)),
      modify.set('isPaused', isPaused).set('isClosed', isClosed),
    );
  }

  // --- TRADE & FEE OPERATIONS ---
  static Future<void> recordTrade(Map<String, dynamic> tradeData) async {
    await tradeCol.insertOne(tradeData);
  }

  static Future<void> recordFee(Map<String, dynamic> feeData) async {
    await feeCol.insertOne(feeData);
  }

  static Future<double> getTotalFees() async {
    final pipeline = [
      {
        '\$group': {
          '_id': null,
          'total': {'\$sum': '\$amount'}
        }
      }
    ];
    final result = await feeCol.aggregate(pipeline).toList();
    if (result.isNotEmpty) {
      return result[0]['total'].toDouble();
    }
    return 0.0;
  }

  static Future<void> close() async {
    await db.close();
  }
}

extension FutureMapToList on Future<Map<String, dynamic>> {
  Future<List<Map<String, dynamic>>> toList() async {
    final Map<String, dynamic> result = await this;
    return [result];
  }
}
