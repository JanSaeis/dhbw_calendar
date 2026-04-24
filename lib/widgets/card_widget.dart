import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SettingsCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}
