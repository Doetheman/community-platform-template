import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../brand_theme.dart';

class ThemedButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final String text;

  const ThemedButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandThemeProvider);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: brand.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
