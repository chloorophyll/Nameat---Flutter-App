import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../utils/format.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlacesProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: provider.clearFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cuisine', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: provider.cuisineFilter == null,
                  onSelected: (_) => provider.setCuisineFilter(null),
                ),
                ...provider.cuisines.map(
                  (c) => ChoiceChip(
                    label: Text(prettyCuisine(c)),
                    selected: provider.cuisineFilter == c,
                    onSelected: (_) => provider.setCuisineFilter(c),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Budget', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Any'),
                  selected: provider.budgetFilter == 0,
                  onSelected: (_) => provider.setBudgetFilter(0),
                ),
                ...[1, 2, 3].map(
                  (level) => ChoiceChip(
                    label: Text('₱' * level),
                    selected: provider.budgetFilter == level,
                    onSelected: (_) => provider.setBudgetFilter(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Show results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
