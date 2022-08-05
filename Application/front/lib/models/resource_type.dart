enum ResourceType {
  stone,
  wood,
  iron,
  food,
  villager,
  gold,
  potions,
  storage,
  healing,
  ally,
  enemy
}

extension ResourceTypeParsing on ResourceType {
  String toShortString() {
    return toString().split('.').last;
  }

  static ResourceType? fromString(String string) {
    switch (string.toLowerCase()) {
      case "wood":
        return ResourceType.wood;
      case "stone":
        return ResourceType.stone;
      case "iron":
        return ResourceType.iron;
      case "food":
        return ResourceType.food;
      case "villager":
        return ResourceType.villager;
      case "gold":
        return ResourceType.gold;
      case "potions":
        return ResourceType.potions;
      case "storage":
        return ResourceType.storage;
      case "healing":
        return ResourceType.healing;
      case "ally":
        return ResourceType.ally;
      case "enemy":
        return ResourceType.enemy;
      default:
        return null;
    }
  }
}
