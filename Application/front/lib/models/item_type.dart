enum ItemType {
  potion,
  ally,
}

extension ItemTypeParsing on ItemType {
  String toShortString() {
    return toString().split('.').last;
  }

  static ItemType? fromString(String string) {
    switch (string.toLowerCase()) {
      case "potion":
        return ItemType.potion;
      case "ally":
        return ItemType.ally;
      default:
        return null;
    }
  }
}

enum Target { health, damage, speed }

extension TargetParsing on Target {
  String toShortString() {
    return toString().split('.').last;
  }

  static Target? fromString(String string) {
    switch (string.toLowerCase()) {
      case "health":
        return Target.health;
      case "damage":
        return Target.damage;
      case "speed":
        return Target.speed;
      default:
        return null;
    }
  }
}
