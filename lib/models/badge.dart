import 'package:flutter/material.dart';

class AppBadge {
  final String id;
  final String name;
  final IconData icon;
  final bool isUnlocked;
  final String description;

  const AppBadge({
    required this.id,
    required this.name,
    required this.icon,
    required this.isUnlocked,
    this.description = '',
  });
}
