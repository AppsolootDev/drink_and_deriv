import 'package:flutter/material.dart';

Color getRiskColor(String risk) {
  switch (risk.toLowerCase()) {
    case 'low':
      return Colors.yellow;
    case 'medium':
      return Colors.orange;
    case 'high':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
