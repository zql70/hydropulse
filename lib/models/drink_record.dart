enum DrinkType {
  water,
  coffee,
  tea,
  isotonic,
  alcohol;

  String get label {
    switch (this) {
      case DrinkType.water:
        return '纯水';
      case DrinkType.coffee:
        return '咖啡';
      case DrinkType.tea:
        return '茶饮';
      case DrinkType.isotonic:
        return '运动饮料';
      case DrinkType.alcohol:
        return '酒精饮品';
    }
  }

  double get coefficient {
    switch (this) {
      case DrinkType.water:
        return 1.0;
      case DrinkType.coffee:
        return 0.8;
      case DrinkType.tea:
        return 0.9;
      case DrinkType.isotonic:
        return 1.2;
      case DrinkType.alcohol:
        return -2.0;
    }
  }
}

class DrinkRecord {
  final String id;
  final DrinkType type;
  final int volume;
  final DateTime timestamp;
  final double coefficient;

  DrinkRecord({
    required this.id,
    required this.type,
    required this.volume,
    required this.timestamp,
  }) : coefficient = type.coefficient;

  double get effectiveVolume => volume * coefficient;
}
