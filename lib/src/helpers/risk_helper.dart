import 'package:flutter/material.dart';

Color getRiskColor(String risk) {
  switch (risk.toLowerCase()) {
    case 'low':
      return const Color(0xFFFFD700); // Gold
    case 'medium':
      return const Color(0xFFC0C0C2); // Silver
    case 'high':
      return const Color(0xFFE5E4E2); // Platinum Base
    default:
      return Colors.grey;
  }
}

Decoration getRiskDecoration(String risk) {
  final riskLower = risk.toLowerCase();
  if (riskLower == 'high') {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFADD8E6), // Light Blue
          Color(0xFFE5E4E2), // Platinum
        ],
      ),
    );
  } else if (riskLower == 'low') {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFFFD700), // Gold
          Colors.grey,       // Gray
        ],
      ),
    );
  } else if (riskLower == 'medium') {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFC0C0C2), // Silver
          Colors.grey,       // Gray
        ],
      ),
    );
  }
  return BoxDecoration(
    color: getRiskColor(risk),
    borderRadius: BorderRadius.circular(8),
  );
}

Decoration getGreenGradientDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF90EE90), // Light Green
        Color(0xFF006400), // Dark Green
      ],
    ),
  );
}
