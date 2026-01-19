import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Db? _db;
  
  // Localhost connection string
  static const String _host = "127.0.0.1";
  static const String _port = "27017";
  static const String _dbName = "drink_and_deryve";
  static const String _url = "mongodb://$_host:$_port/$_dbName";

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    
    try {
      debugPrint("[DB LOG] Attempting to connect to MongoDB at $_url...");
      _db = await Db.create(_url);
      await _db!.open();
      debugPrint("[DB LOG] Successfully connected to Localhost MongoDB");
    } catch (e) {
      debugPrint("[DB LOG] MongoDB Connection Error: $e");
      rethrow;
    }
  }

  Db get db {
    if (_db == null) throw Exception("Database not initialized. Call connect() first.");
    return _db!;
  }

  Future<void> insert(String collectionName, Map<String, dynamic> data) async {
    debugPrint("[DB LOG] Inserting data into collection '$collectionName'...");
    var collection = db.collection(collectionName);
    await collection.insertOne(data);
    debugPrint("[DB LOG] Data successfully moved to DB.");
  }

  Future<List<Map<String, dynamic>>> query(String collectionName) async {
    debugPrint("[DB LOG] Querying collection '$collectionName'...");
    var collection = db.collection(collectionName);
    final results = await collection.find().toList();
    debugPrint("[DB LOG] Query returned ${results.length} items.");
    return results;
  }

  Future<void> clearAll() async {
    debugPrint("[DB LOG] Clearing all collections...");
    await db.collection('users').remove({});
    await db.collection('vehicles').remove({});
    await db.collection('investments').remove({});
    debugPrint("[DB LOG] Database wiped clean.");
  }
}
