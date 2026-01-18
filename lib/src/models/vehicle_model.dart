import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class InvestmentVehicle {
  final String id;
  final String name;
  final String type; // e.g., Fleet, Luxury, Logistics
  final String tradingOption; // e.g., Rise/Fall, Higher/Lower, Touch/No Touch
  final double targetAmount;
  final int lotSize;
  final double lotPrice;
  final String status; // e.g., Open, Funded, Active
  final double expectedRoi;
  final int maturityMonths;
  final String description;
  final String? imageUrl; // Path to asset or URL
  final String? base64Image; // Raw image data stored in DB

  InvestmentVehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.tradingOption,
    required this.targetAmount,
    required this.lotSize,
    required this.lotPrice,
    required this.status,
    required this.expectedRoi,
    required this.maturityMonths,
    required this.description,
    this.imageUrl,
    this.base64Image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'tradingOption': tradingOption,
      'targetAmount': targetAmount,
      'lotSize': lotSize,
      'lotPrice': lotPrice,
      'status': status,
      'expectedRoi': expectedRoi,
      'maturityMonths': maturityMonths,
      'description': description,
      'imageUrl': imageUrl,
      'base64Image': base64Image,
    };
  }

  factory InvestmentVehicle.fromMap(Map<String, dynamic> map) {
    return InvestmentVehicle(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      tradingOption: map['tradingOption'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      lotSize: map['lotSize'] ?? 0,
      lotPrice: (map['lotPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? '',
      expectedRoi: (map['expectedRoi'] ?? 0.0).toDouble(),
      maturityMonths: map['maturityMonths'] ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      base64Image: map['base64Image'],
    );
  }

  /// Helper to resolve the image widget
  Widget getImageWidget({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(base64Image!);
        return Image.memory(bytes, width: width, height: height, fit: fit, errorBuilder: _errorBuilder);
      } catch (e) {
        return _errorBuilder(null, null, null);
      }
    }
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('assets/')) {
        return Image.asset(imageUrl!, width: width, height: height, fit: fit, errorBuilder: _errorBuilder);
      } else {
        return Image.network(imageUrl!, width: width, height: height, fit: fit, errorBuilder: _errorBuilder);
      }
    }

    return _errorBuilder(null, null, null);
  }

  Widget _errorBuilder(BuildContext? context, Object? error, StackTrace? stackTrace) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.directions_car, color: Colors.orange),
    );
  }
}
