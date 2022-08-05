enum EventType { invasion, calamity, heal }

extension EventTypeParsing on EventType {
  String toShortString() {
    return toString().split('.').last;
  }

  static EventType? fromString(String string) {
    switch (string.toLowerCase()) {
      case "invasion":
        return EventType.invasion;
      case "calamity":
        return EventType.calamity;
      case "heal":
        return EventType.heal;
      default:
        return null;
    }
  }
}
