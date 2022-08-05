// ignore_for_file: constant_identifier_names

enum AuthType { FarmVillage, VeggieCrush, BoomCraft, Facebook, Twitter }

extension AuthTypeParsing on AuthType {
  String toShortString() {
    return toString().split('.').last;
  }

  static AuthType? fromString(String string) {
    switch (string.toLowerCase()) {
      case "boomcraft":
        return AuthType.BoomCraft;
      case "veggiecrush":
        return AuthType.VeggieCrush;
      case "farmvillage":
        return AuthType.FarmVillage;
      case "facebook":
        return AuthType.Facebook;
      case "twitter":
        return AuthType.Twitter;
      default:
        return null;
    }
  }
}
