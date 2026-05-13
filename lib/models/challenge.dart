import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String name;
  final String description;
  final int current;
  final int target;
  final IconData icon;
  final bool hasReward;
  final String unit;

  const Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.current,
    required this.target,
    required this.icon,
    this.hasReward = false,
    this.unit = '天',
  });

  double get progress => target > 0 ? current / target : 0;
  bool get isCompleted => current >= target;
}
