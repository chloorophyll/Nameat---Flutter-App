import 'package:flutter/material.dart';

class BudgetBadge extends StatelessWidget {
  final int level; // 0 = not set, 1 to 3 = P, PP, PPP

  const BudgetBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level == 0 ? 'Budget not set' : '₱' * level,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}