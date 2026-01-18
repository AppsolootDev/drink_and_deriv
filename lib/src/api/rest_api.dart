import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/investment_model.dart';

class RestApi {
  // Use 10.0.2.2 for Android emulator to reach localhost, 
  // or localhost for other platforms.
  static final String _baseUrl = Platform.isAndroid 
      ? 'http://10.0.2.2:3000/api' 
      : 'http://localhost:3000/api';

  // --- AUTH OPERATIONS ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Invalid credentials'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection failed: $e'};
    }
  }

  // --- USER CRUD ---
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    return [];
  }

  Future<void> createUser(User user) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toMap()),
      );
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/users/$userId'));
      if (response.statusCode == 200) {
        print('User deleted successfully via API');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // --- VEHICLE CRUD ---
  Future<List<InvestmentVehicle>> getAllVehicles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/vehicles'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InvestmentVehicle.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
    return [];
  }

  Future<void> addVehicle(InvestmentVehicle vehicle) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.toMap()),
      );
    } catch (e) {
      print('Error adding vehicle: $e');
    }
  }

  // --- INVESTMENT OPERATIONS ---
  Future<void> startInvestment(UserInvestment investment) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/investments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(investment.toMap()),
      );
    } catch (e) {
      print('Error starting investment: $e');
    }
  }

  Future<List<UserInvestment>> getUserInvestments(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/investments/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserInvestment.fromMap(json)).toList();
      }
    } catch (e) {
      print('Error fetching investments: $e');
    }
    return [];
  }
}
