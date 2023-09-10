import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

Color getContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .primaryContainer
      .harmonizeWith(theme.colorScheme.primary);
}

Color getOnContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .onPrimaryContainer
      .harmonizeWith(theme.colorScheme.primary);
}

Color getSecondaryContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .secondaryContainer
      .harmonizeWith(theme.colorScheme.primary);
}

Color getOnSecondaryContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .onSecondaryContainer
      .harmonizeWith(theme.colorScheme.primary);
}

Color getPrimaryColorHarmonized(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .primary
      .harmonizeWith(theme.colorScheme.primary);
}

Color getOnPrimaryColorHarmonized(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .onPrimary
      .harmonizeWith(theme.colorScheme.primary);
}
