import 'package:bonfire/base/bonfire_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/allies/ally.dart';
import 'package:front/allies/ally_remote.dart';
import 'package:front/buildings/building.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/models/weather_type.dart';
import 'package:front/npcs/npc.dart';

final hpProvider = StateProvider<double>((ref) => 1000.0);
final staminaProvider = StateProvider<double>((ref) => 100.0);
final menuCallbackProvider = StateProvider<VoidCallback>((ref) => () {});

final passwordProvider = StateProvider((ref) => "");
final visibilityProvider = StateProvider<bool>((ref) => true);

final villagesProvider = StateProvider<List>((ref) => []);
final selectedVillageProvider = StateProvider<dynamic>((ref) => null);
final buildingsProvider = StateProvider<Map<String, Building>>((ref) => {});
final npcsProvider = StateProvider<Map<int, NPC>>((ref) => {});
final alliesProvider = StateProvider<Map<String, Ally>>((ref) => {});
final alliesRemoteProvider =
    StateProvider<Map<String, AllyRemote>>((ref) => {});
final refreshAlliesProvider = StateProvider<int>((ref) => 0);
final refreshProvider = StateProvider<int>((ref) => 0);

final gameRefProvider = StateProvider<BonfireGame?>((ref) => null);

final dayProvider = StateProvider<bool>((ref) => true);
final weatherProvider = StateProvider<WeatherType>((ref) => WeatherType.clear);
final lockWeatherProvider = StateProvider<bool>((ref) => false);

final veggieMenuProvider = StateProvider<bool>((ref) => false);
final boomCraftMenuProvider = StateProvider<bool>((ref) => false);
final loginsProvider = StateProvider<Map<AuthType, bool>>(
  (ref) => {
    AuthType.BoomCraft: false,
    AuthType.Facebook: false,
    AuthType.VeggieCrush: false,
    AuthType.Twitter: false
  },
);

final initialPlayers = StateProvider<Map<String, double>>(
  (ref) => {},
);
