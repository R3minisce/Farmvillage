enum WeatherType { snow, rain, fog, clear, lava }

extension WeatherTypeParsing on WeatherType {
  String toShortString() {
    return toString().split('.').last;
  }

  static WeatherType? fromString(String string) {
    switch (string.toLowerCase()) {
      case "snow":
        return WeatherType.snow;
      case "rain":
        return WeatherType.rain;
      case "thunderstorm":
        return WeatherType.rain;
      case "mist":
        return WeatherType.fog;
      case "fog":
        return WeatherType.fog;
      case "clear":
        return WeatherType.clear;
      case "lava":
        return WeatherType.lava;
      default:
        return WeatherType.clear;
    }
  }
}
