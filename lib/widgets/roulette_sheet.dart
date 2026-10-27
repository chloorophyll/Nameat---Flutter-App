import 'dart:math';
import 'package:flutter/material.dart';
import '../models/place.dart';
import '../utils/format.dart';
import 'budget_badge.dart';

class RouletteSheet extends StatefulWidget {
  final List<Place> places;

  const RouletteSheet({super.key, required this.places});

  @override
  State<RouletteSheet> createState() => _RouletteSheetState();
}

class _RouletteSheetState extends State<RouletteSheet> {
  final _random = Random();
  Place? _current;
  bool _spinning = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _spin());
  }

  
  Future<void> _spin() async {
    final pool = widget.places;
    if (pool.isEmpty) return;
    setState(() {
      _spinning = true;
      _done = false;
    });
    final winner = pool[_random.nextInt(pool.length)];
    var delay = 60;
    for (var i = 0; i < 14; i++) {
      if (!mounted) return;
      setState(() => _current = pool[_random.nextInt(pool.length)]);
      await Future.delayed(Duration(milliseconds: delay));
      delay += 25;
    }
    if (!mounted) return;
    setState(() {
      _current = winner;
      _spinning = false;
      _done = true;
    });
  }

  void _open() {
    final place = _current;
    if (place == null) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed('/details', arguments: place);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pool = widget.places;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Can't decide?",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text('Picking from ${pool.length} places'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: pool.isEmpty
                  ? const Text(
                      'No places to pick from. Try clearing your filters.',
                      textAlign: TextAlign.center,
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 120),
                      child: Column(
                        key: ValueKey(_current?.id),
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 36,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _current?.name ?? '...',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_current != null) ...[
                            const SizedBox(height: 4),
                            Text(prettyCuisine(_current!.cuisine)),
                            const SizedBox(height: 8),
                            BudgetBadge(level: _current!.budgetLevel),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_spinning || pool.isEmpty) ? null : _spin,
                    icon: const Icon(Icons.casino_outlined),
                    label: const Text('Spin again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _done ? _open : null,
                    child: const Text("Let's go!"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
