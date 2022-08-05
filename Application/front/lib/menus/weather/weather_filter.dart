import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/models/weather_type.dart';
import 'package:front/providers.dart';

class WeatherFilter extends StatelessWidget {
  const WeatherFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        WeatherType weather = watch(weatherProvider).state;
        return Container(
          width: double.infinity,
          decoration: _getWeather(weather),
        );
      },
    );
  }

  BoxDecoration _getWeather(WeatherType weather) {
    switch (weather) {
      case WeatherType.snow:
        return _weatherDecoration(
          Colors.blue.shade100.withOpacity(0.25),
          0.3,
          "snow",
        );
      case WeatherType.rain:
        return _weatherDecoration(
          Colors.transparent,
          0.3,
          "rain",
        );
      case WeatherType.fog:
        return _weatherDecoration(
          Colors.blue.shade100.withOpacity(0.5),
          0.25,
          "fog",
        );
      case WeatherType.clear:
        return _weatherDecoration(
          Colors.yellow.shade100.withOpacity(0.02),
          0.0,
          "rain",
        );

      case WeatherType.lava:
        return _weatherDecoration(
          Colors.deepOrange.shade700.withOpacity(0.5),
          0.4,
          "fog",
        );

      default:
        return _weatherDecoration(
          Colors.yellow.shade100.withOpacity(0.02),
          0.0,
          "rain",
        );
    }
  }

  BoxDecoration _weatherDecoration(
    Color backgroundColor,
    double gifOpacity,
    String gifName,
  ) {
    return BoxDecoration(
      color: backgroundColor,
      image: DecorationImage(
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
            Colors.transparent.withOpacity(gifOpacity), BlendMode.dstIn),
        image: AssetImage(
          'assets/images/background/$gifName.gif',
        ),
      ),
    );
  }
}
