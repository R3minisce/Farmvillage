import 'package:bonfire/bonfire.dart';
import 'package:bonfire/tiled/model/tiled_object_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/buildings/building.dart';
import 'package:front/buildings/building_object.dart';
import 'package:front/buildings/deposit_object.dart';
import 'package:front/menus/buildings/building_menu.dart';
import 'package:front/menus/death_screen/death_screen.dart';
import 'package:front/menus/event_screen/event_screen.dart';
import 'package:front/menus/hud/hud.dart';
import 'package:front/menus/quests_sign/sign_menu.dart';
import 'package:front/menus/weather/weather_filter.dart';
import 'package:front/npcs/npc.dart';
import 'package:front/objects/collision_object.dart';
import 'package:front/objects/iron.dart';
import 'package:front/objects/sign.dart';
import 'package:front/objects/spawn_area.dart';
import 'package:front/objects/stone.dart';
import 'package:front/objects/tree.dart';
import 'package:front/players/knight.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';

class FarmVillageGame extends StatefulWidget {
  const FarmVillageGame(
      {Key? key, required this.socketManager, this.villageData})
      : super(key: key);
  final SocketManager socketManager;
  final dynamic villageData;

  @override
  State<FarmVillageGame> createState() => _FarmVillageGameState();
}

class _FarmVillageGameState extends State<FarmVillageGame>
    with WidgetsBindingObserver
    implements GameListener {
  late GameController _controller;
  late Joystick _joystick;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _controller = GameController()..addListener(this);
    _joystick = Joystick(
        directional: JoystickDirectional(
            color: Colors.grey.shade100,
            margin: const EdgeInsets.only(left: 75, bottom: 75)),
        actions: [
          JoystickAction(
            actionId: 0,
            sprite: Sprite.load('joystick/attack.png'),
            size: 80,
            margin: const EdgeInsets.only(bottom: 50, right: 50),
          ),
        ]);
    Sounds.playBackgroundSound();

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Sounds.resumeBackgroundSound();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        Sounds.pauseBackgroundSound();
        break;
      case AppLifecycleState.detached:
        Sounds.stopBackgroundSound();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    Sounds.stopBackgroundSound();
    print("la jeu est disposé");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        return BonfireTiledWidget(
          gameController: _controller,
          joystick: _joystick,
          map: TiledWorldMap('tile/map.json',
              forceTileSize: const Size(32, 32),
              objectsBuilder: _createMap(widget.villageData, watch)),
          player: Knight(
              Vector2(1300, 675), _joystick, watch, widget.socketManager),
          overlayBuilderMap: {
            'signMenu': (BuildContext context, BonfireGame game) {
              return const SignMenu();
            },
            'weatherFilter': (BuildContext context, BonfireGame game) {
              return const WeatherFilter();
            },
            'deathScreen': (BuildContext context, BonfireGame game) {
              return const DeathScreen();
            },
            'buildingMenu': (BuildContext context, BonfireGame game) {
              return const BuildingMenu();
            },
            'hud': (BuildContext context, BonfireGame game) {
              return const HUD();
            },
            'event': (BuildContext context, BonfireGame game) {
              return const EventScreen();
            }
          },
          initialActiveOverlays: const ['weatherFilter', 'hud'],
          background: BackgroundColorGame(Colors.grey.shade800),
          constructionMode: false,
          showCollisionArea: false,
          constructionModeColor: Colors.blue,
          collisionAreaColor: Colors.red,
          lightingColorGame: Colors.black.withOpacity(0.3),
          cameraConfig: CameraConfig(
            sizeMovementWindow: const Size(25, 25),
            moveOnlyMapArea: false,
            zoom: 0.8,
            smoothCameraEnable: false,
            smoothCameraSpeed: 3.0,
          ),
          showFPS: false,
          progress: const Scaffold(
            body: Center(
              child: Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, GameComponent Function(TiledObjectProperties)> _createMap(
      villageData, watch) {
    Map<String, GameComponent Function(TiledObjectProperties)> finalMap = {};
    for (int i = 1; i < 10; i++) {
      finalMap.addAll(buildBuilding(i, watch, villageData));
    }

    Map<String, GameDecoration Function(dynamic)> otherMap = {
      'collision': (params) => CollisionObject(params.position, params.size),

      // Items
      'tree': (params) => Tree(params.position),
      'big_iron_rock': (params) => BigIronRock(params.position),
      'small_iron_rock': (params) => SmallIronRock(params.position),
      'big_stone_rock': (params) => BigStoneRock(params.position),
      'small_stone_rock': (params) => SmallStoneRock(params.position),
      'tree_cut': (params) => TreeCut(params.position),
      'panel': (params) => Sign(params.position),

      // PNJs
      'ally_spawn_area': (params) =>
          SpawnArea(params.position, params.size, "ally"),
      'imp_spawn_area': (params) =>
          SpawnArea(params.position, params.size, "enemy"),
    };

    finalMap.addAll(otherMap);
    return finalMap;
  }

  Map<String, GameComponent Function(TiledObjectProperties)> buildBuilding(
      int index, watch, villageData) {
    bool check = _mustBeLoaded("B_0$index", villageData);
    return {
      // Buildings
      'build_0$index': (params) => Building(
            params.position,
            'tile/buildings/b_0$index.png',
            params.size,
            "B_0$index",
            check,
            watch,
          ),
      'dp_0$index': (params) =>
          DepositObject(params.position, params.size, "B_0$index"),
      'b_0$index': (params) =>
          BuildingObject(params.position, params.size, "B_0$index"),
      'pnj_0$index': (params) =>
          NPC(params.position, index, check, params.size, watch),
    };
  }

  bool _mustBeLoaded(String id, villageData) {
    var data = villageData['buildings'] as List;
    var index = data.indexWhere((element) {
      return (element['base_id'] as String).toUpperCase() == id.toUpperCase() &&
          element['level'] > 0;
    });
    return index != -1;
  }

  @override
  void changeCountLiveEnemies(int count) {}

  @override
  void updateGame() {}
}
