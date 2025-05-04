import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandThemeConfig {
  final String name;
  final Color primaryColor;
  final String logoUrl;
  final String? fontFamily;

  const BrandThemeConfig({
    required this.name,
    required this.primaryColor,
    required this.logoUrl,
    this.fontFamily,
  });
}

// Static fallback or default config (for now)
final brandThemeProvider = Provider<BrandThemeConfig>((ref) {
  return const BrandThemeConfig(
    name: "Clockout",
    primaryColor: Color(0xFF6C63FF),
    logoUrl: "https://via.placeholder.com/100x100.png?text=Clockout",
    fontFamily: 'Inter',
  );
});
