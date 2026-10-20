import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';

class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({super.key});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  int _budgetLevel = 1;
  Place? _editing;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Place) {
      _editing = args;
      _nameController.text = args.name;
      _cuisineController.text = args.cuisine ?? '';
      _addressController.text = args.address ?? '';
      _notesController.text = args.notes ?? '';
      _budgetLevel = args.budgetLevel == 0 ? 1 : args.budgetLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _optional(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PlacesProvider>();

    final place = Place(
      id: _editing?.id ?? -DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      cuisine: _optional(_cuisineController.text),
      address: _optional(_addressController.text),
      notes: _optional(_notesController.text),
      type: _editing?.type ?? 'restaurant',
      latitude: _editing?.latitude ?? 0,
      longitude: _editing?.longitude ?? 0,
      budgetLevel: _budgetLevel,
      isCustom: true,
    );

    if (_editing == null) {
      await provider.addPlace(place);
    } else {
      await provider.updatePlace(place);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Place' : 'Add Place')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cuisineController,
                decoration: const InputDecoration(
                  labelText: 'Cuisine (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Budget'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 2, 3].map((level) {
                  return ChoiceChip(
                    label: Text('₱' * level),
                    selected: _budgetLevel == level,
                    onSelected: (_) => setState(() => _budgetLevel = level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Submit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}