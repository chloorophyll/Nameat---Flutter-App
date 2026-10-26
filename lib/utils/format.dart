String prettyCuisine(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'Cuisine not specified';
  return raw
      .split(';')
      .map((s) => s.replaceAll('_', ' ').trim())
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase() + s.substring(1))
      .join(', ');
}
