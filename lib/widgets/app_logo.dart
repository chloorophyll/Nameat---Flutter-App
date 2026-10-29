import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  final bool tint;

  const AppLogo({super.key, this.size = 40, this.tint = true});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    final image = Image.asset(
      'assets/icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.restaurant_menu, size: size, color: color),
    );

    if (!tint) return image;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: image,
    );
  }
}
