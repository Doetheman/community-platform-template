import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandThemeConfig {
  final String name;
  final Color primaryColor;
  final String? logoUrl;
  final String? logoAsset;
  final String? fontFamily;

  const BrandThemeConfig({
    required this.name,
    required this.primaryColor,
    this.logoUrl,
    this.logoAsset,
    this.fontFamily,
  });
}

// Static fallback or default config (for now)
final brandThemeProvider = Provider<BrandThemeConfig>((ref) {
  return const BrandThemeConfig(
    name: "Clockout",
    primaryColor: Color(0xFF6C63FF),
    logoAsset: "assets/images/logo.png",
    fontFamily: 'Inter',
  );
});
