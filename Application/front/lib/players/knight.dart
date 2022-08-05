import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/allies/ally.dart';
import 'package:front/allies/ally_remote.dart';
import 'package:front/buildings/building.dart';
import 'package:front/buildings/building_object.dart';
import 'package:front/buildings/deposit_object.dart';
import 'package:front/enemies/imp.dart';
import 'package:front/enemies/imp_remote.dart';
import 'package:front/models/event_type.dart';
import 'package:front/models/item_type.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/models/resource.dart';
import 'package:front/models/weather_type.dart';
import 'package:front/npcs/npc.dart';
import 'package:front/objects/box.dart';
import 'package:front/objects/sign.dart';
import 'package:front/objects/spawn_area.dart';
import 'package:front/players/remote_player.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';
import 'package:front/services/inventory_service.dart';
import 'package:front/sockets/interface_game_ref.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:front/utils/spriteSheets/player_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/random_sprite_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async' as d_async;

import 'package:uuid/uuid.dart';

const initialSpeed = 250.0;

/// Represents the player.
class Knight extends SimplePlayer
    with ObjectCollision, Lighting
    implements IGameRef {
  late Function boxAction;
  late Function action;
  final SocketManager socketManager;
  late Joystick joystick;
  late T Function<T>(ProviderBase<Object?, T>) watch;
  double stamina = 100;
  Map<String, RemotePlayer> players = {};
  Map<String, Imp> imps = {};
  Map<String, Ally> allies = {};
  Map<String, ImpRemote> impsRemote = {};
  Map<String, AllyRemote> alliesRemote = {};
  late final d_async.Timer _staminaTimer;
  late final d_async.Timer _updatePosTimer;
  int attackRatio = 100;
  int speedRatio = 100;

  bool initialised = false;

  Knight(Vector2 position, this.joystick, this.watch, this.socketManager)
      : super(
          position: position,
          height: 64.0 * 1.5,
          width: 64.0 * 1.5,
          life: 1000,
          speed: initialSpeed,
          initDirection: Direction.right,
          animation: PlayerSpriteSheet.playerAnimations(),
        ) {
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
    _updatePosTimer =
        d_async.Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updatePosition();
    });
    _staminaTimer =
        d_async.Timer.periodic(const Duration(milliseconds: 150), (timer) {
      _updateStamina();
    });
    socketManager.startListening(this);
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: const Size(32, 32),
            align: Vector2(30, 30),
          ),
        ],
      ),
    );
    setupLighting(
      LightingConfig(radius: 0, blurBorder: 0, color: Colors.transparent),
    );
    life = watch(hpProvider.notifier).state;
  }

  _ensureDataInitialised() {
    while (!initialised) {
      if (hasGameRef) {
        var villageData = watch(selectedVillageProvider).state;
        var deposits = gameRef.componentsByType<DepositObject>();
        var buildings = villageData['buildings'] as List;
        var validIds = ["B_02", "B_03", "B_04", "B_05"];
        for (var element in deposits) {
          if (validIds.contains(element.id)) {
            var i = buildings.indexWhere((b) => element.id == b['base_id']);
            String prod = buildings[i]['production_type'];
            element.handleBox(
                ResourceTypeParsing.fromString(prod.toLowerCase())!,
                buildings[i]['storage']);
          }
        }
        var buildingsList = watch(buildingsProvider.notifier).state;
        for (var building in buildings) {
          var trueBuilding = buildingsList[building['base_id']];
          num maxLife = building['max_hp'];
          num life = building['hp'];
          trueBuilding!.initialLife(maxLife.toDouble());
          trueBuilding.life = life.toDouble();
        }
        var initialPlayersList = watch(initialPlayers.notifier).state;
        for (var p in initialPlayersList.entries) {
          addPlayer(p.key, p.value);
        }
        for (var ally in villageData['allies']) {
          num x = ally['pos_x'];
          num y = ally['pos_y'];
          var vector;
          if (x.toDouble() == 0.0 && y.toDouble() == 0.0) {
            vector = _getAvailableSpawn("ally");
          }
          if (initialPlayersList.isEmpty) {
            Ally newAlly = vector != null
                ? Ally(Vector2(vector.x, vector.y), ally['id'])
                : Ally(Vector2(x.toDouble(), y.toDouble()), ally['id']);
            if (vector != null) {
              socketManager.emitAIPosition(
                  1, vector.x, vector.y, ally['id'], "ally");
            }
            allies[newAlly.uuid] = newAlly;
            gameRef.add(newAlly);
          } else {
            AllyRemote allyRemote =
                AllyRemote(Vector2(x.toDouble(), y.toDouble()), ally['id']);
            alliesRemote[allyRemote.uuid] = allyRemote;
            gameRef.add(allyRemote);
          }
        }
        watch(gameRefProvider.notifier).state = gameRef;
        updateDay(watch(dayProvider.notifier).state);
        initialised = true;
      }
    }
  }

  @override
  void onRemove() {
    _updatePosTimer.cancel();
    _staminaTimer.cancel();
    super.onRemove();
  }

  /// Sends the position of the player to the socket at a regular interval.
  _updatePosition() {
    if (hasGameRef) {
      socketManager.emitActionMove(position.position.x, position.position.y,
          isIdle ? -1 : lastDirection.index);
    }
  }

  _updateStamina() {
    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
    }
    watch(staminaProvider.notifier).state = stamina;
  }

  updateSpeed(int newRatio) {
    speedRatio = newRatio;
    speed = initialSpeed * (speedRatio / 100);
  }

  /// Updates the object.
  ///
  /// Also handles the update of the joystick.
  @override
  void update(double dt) {
    super.update(dt);

    _ensureDataInitialised();

    //bool fallbackNecessary = _handleBoxes() && _handleDeposit();
    bool fallbackNecessary = _handleBoxes();

    if (fallbackNecessary) _handleIdle(1);

    fallbackNecessary =
        _handleNPC() && _handleQuestsSign() && _handleBuilding();

    if (fallbackNecessary) _handleIdle(2);
  }

  /// Updates the action 1 of the joystick if a [Box] is close enough.
  bool _handleBoxes() {
    bool fallbackNecessary = true;
    seeComponentType<Box>(observed: (boxes) {
      joystick.removeAction(1);
      joystick.addAction(
        _createJoystickAction(1, 'joystick/get.png', 140),
      );
      boxAction = () async => _boxAction(boxes);
      fallbackNecessary = false;
    });
    return fallbackNecessary;
  }

  /// Action called when pressing the joystick 1 near a [Box].
  _boxAction(List<Box> boxes) async {
    var original = boxes[0];
    if (await InventoryService.pickupBoiboite(original.buildingId)) {
      Future.delayed(const Duration(milliseconds: 50), () async {
        boxes[0].removeFromParent();
        var deposits = gameRef.componentsByType<DepositObject>();
        var deposit =
            deposits.firstWhere((element) => element.id == original.buildingId);
        deposit.boiboites.removeAt(0);
        var inventory = await InventoryService.getInventory();
        watch(inventoryProvider.notifier).state = inventory;
      });
    } else {
      // TODO
      print("error");
    }
  }

  /// Updates the action [actionId] of the joystick if no distinguishable objects are near the player.
  _handleIdle(int actionId) {
    double pos = 0;
    String src = "";
    switch (actionId) {
      case 1:
        pos = 140;
        src = 'joystick/get_trans.png';
        boxAction = () {};
        break;
      case 2:
        pos = 200;
        src = 'joystick/interact_trans.png';
        action = () {};
        break;
      default:
    }
    joystick.removeAction(actionId);
    joystick.addAction(
      _createJoystickAction(actionId, src, pos),
    );
  }

  /// Updates the action 2 of the joystick if a [Wizard] is close enough.
  bool _handleNPC() {
    bool fallbackNecessary = true;

    seeComponentType<NPC>(observed: (npcs) {
      var npcsVisible = npcs.where((e) => e.mustBeVisible == true).toList();
      if (npcsVisible.isNotEmpty) {
        _resetInteract();
        action = () => _initiateConversation(npcsVisible[0]);
        fallbackNecessary = false;
      }
    });
    return fallbackNecessary;
  }

  /// /// Updates the action 2 of the joystick if a [Sign] is close enough.
  bool _handleQuestsSign() {
    bool fallbackNecessary = true;
    seeComponentType<Sign>(observed: (signs) {
      _resetInteract();
      action = () => _openQuestsSign(signs[0]);
      fallbackNecessary = false;
    });
    return fallbackNecessary;
  }

  /// Updates the action 2 of the joystick if a [BuildingObject] is close enough.
  bool _handleBuilding() {
    bool fallbackNecessary = true;
    seeComponentType<BuildingObject>(observed: (buildings) {
      _resetInteract();
      action = () => _openBuildingMenu(buildings[0]);
      fallbackNecessary = false;
    });
    return fallbackNecessary;
  }

  /// Action called when pressing the joystick 2 near a [Wizard].
  void _initiateConversation(wizard) {
    if (wizard != null) {
      wizard.discussWith();
    }
  }

  /// Action called when pressing the joystick 2 near a [Sign].
  void _openQuestsSign(Sign sign) {
    watch(dayProvider.notifier).state = true;
    sign.onInteract(joystick);
    _updateLighting();
  }

  void _updateLighting() {
    var isDay = watch(dayProvider.notifier).state;
    LightingConfig newConfig = (!isDay)
        ? LightingConfig(
            radius: width * 0.5,
            color: Colors.transparent,
            blurBorder: width * 0.5)
        : LightingConfig(
            radius: 0, color: Colors.orange.shade400, blurBorder: 0);
    setupLighting(newConfig);
  }

  /// Action called when pressing the joystick 2 near a [BuildingObject].
  void _openBuildingMenu(BuildingObject building) {
    watch(selectedBuildingId.notifier).state = building.id;
    watch(refreshProvider.notifier).state++;
    building.onInteract();
    Joystick cpy = joystick;
    joystick.shouldRemove = true;
    watch(menuCallbackProvider.notifier).state = () async => _closeMenu(cpy);
  }

  void _closeMenu(Joystick joystick) async {
    socketManager.emitUpdateVillageResources();
    gameRef.overlays.remove('buildingMenu');
    gameRef.overlays.add('hud');
    gameRef.add(joystick);
  }

  /// Creates a [JoystickAction].
  JoystickAction _createJoystickAction(
      int actionId, String spriteSrc, double offset) {
    return JoystickAction(
      actionId: actionId,
      sprite: Sprite.load(spriteSrc),
      size: 50,
      margin: EdgeInsets.only(bottom: 50, right: offset),
    );
  }

  void _resetInteract() {
    joystick.removeAction(2);
    joystick.addAction(
      _createJoystickAction(2, 'joystick/interact.png', 200),
    );
  }

  /// Handles the actions of the button.
  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      attack();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      boxAction();
    }

    if (event.id == 2 && event.event == ActionEvent.DOWN) {
      action();
    }
    super.joystickAction(event);
  }

  /// Allow to attack an enemy.
  void attack() {
    if (stamina < 10) {
      return;
    }
    socketManager.emitAttack();
    Sounds.attackPlayerMelee();
    decrementStamina(10);
    simpleAttackMelee(
      damage: 25.0 * (attackRatio / 100),
      animationBottom: PlayerSpriteSheet.attackEffectBottom(),
      animationLeft: PlayerSpriteSheet.attackEffectLeft(),
      animationRight: PlayerSpriteSheet.attackEffectRight(),
      animationTop: PlayerSpriteSheet.attackEffectTop(),
      height: 32,
      width: 32,
    );
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  /// Called when the player takes damage.
  ///
  /// Shows the damage on top of its head.
  @override
  void receiveDamage(double damage, dynamic id) async {
    if (isDead) return;
    showDamage(
      damage,
      config: const TextPaintConfig(
        fontSize: 15,
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    var sp = await SharedPreferences.getInstance();
    String? username = sp.getString('username');
    SocketManager().emitPlayerReceivedDamage(username!, damage);
    super.receiveDamage(damage, id);
    watch(hpProvider.notifier).state = life;
  }

  void receiveDamage2(double damage, dynamic id) async {
    if (isDead) return;
    showDamage(
      damage,
      config: const TextPaintConfig(
        fontSize: 15,
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(damage, id);
    watch(hpProvider.notifier).state = life;
  }

  @override
  void die() {
    gameRef.overlays.remove("hud");
    gameRef.overlays.add('deathScreen');
    gameRef.add(
      AnimatedObjectOnce(
        animation: RandomSpriteSheet.smokeExplosion(),
        position: position,
      ),
    );
    removeFromParent();
    super.die();
  }

  /// Called to update the position of other players.
  @override
  void updateOtherPlayerPos(
      String username, int directionIndex, double x, double y) {
    if (hasGameRef) {
      if (players.containsKey(username)) {
        players[username]!.position =
            Vector2Rect(Vector2(x, y), Vector2(64 * 1.5, 64 * 1.5));
        switch (directionIndex) {
          case 0:
            players[username]!.moveLeft(speed);
            break;
          case 1:
            players[username]!.moveRight(speed);
            break;
          case 2:
            players[username]!.moveUp(speed);
            break;
          case 3:
            players[username]!.moveDown(speed);
            break;
          case 4:
            players[username]!.moveUpLeft(speed / 2, speed / 2);
            break;
          case 5:
            players[username]!.moveUpRight(speed / 2, speed / 2);
            break;
          case 6:
            players[username]!.moveDownLeft(speed, speed);
            break;
          case 7:
            players[username]!.moveDownRight(speed, speed);
            break;
          default:
            players[username]!.idle();
            break;
        }
      }
    }
  }

  @override
  void createAI(String type, int nb) {
    // todo : gérer le nombre et la position
    if (hasGameRef) {
      for (var i = 0; i < nb; i++) {
        Vector2 position = _getAvailableSpawn(type);
        if (type == "ally") {
          var ally = Ally(position, const Uuid().v4());
          allies[ally.uuid] = ally;
          gameRef.add(ally);
          socketManager.emitAllySpawn(ally);
          watch(alliesProvider.notifier).state = allies;
          watch(refreshAlliesProvider.notifier).state++;
        } else {
          var imp = Imp(position, const Uuid().v4());
          imps[imp.uuid] = imp;
          gameRef.add(imp);
          socketManager.emitEnemySpawn(imp);
        }
      }
    }
  }

  Vector2 _getAvailableSpawn(String type) {
    var spawnAreas = gameRef
        .componentsByType<SpawnArea>()
        .where((element) => element.type == type)
        .toList();
    Random r = Random();
    var index = r.nextInt(spawnAreas.length);
    var chosenArea = spawnAreas[index];

    var vector2 = chosenArea.position.rect.bottomLeft.toVector2();
    var minX = vector2.x;
    var maxX = minX + chosenArea.width;
    var minY = vector2.y;
    var maxY = minY - chosenArea.height;

    var randX = r.nextDouble() * (maxX - minX + 1) + minX;
    var randY = r.nextDouble() * (maxY - minY + 1) + minY;

    return Vector2(randX, randY);
  }

  @override
  void createAIRemote(String type, num x, num y, String id) {
    if (hasGameRef) {
      if (type == "ally") {
        var ally = AllyRemote(Vector2(x.toDouble(), y.toDouble()), id);
        alliesRemote[ally.uuid] = ally;
        gameRef.add(ally);
        watch(alliesRemoteProvider.notifier).state = alliesRemote;
        watch(refreshAlliesProvider.notifier).state++;
      } else {
        var imp = ImpRemote(Vector2(x.toDouble(), y.toDouble()), id);
        impsRemote[imp.uuid] = imp;
        gameRef.add(imp);
      }
    }
  }

  @override
  void updateAIPosition(
      String id, int directionIndex, num x, num y, String type) {
    if (type == "ally") {
      if (alliesRemote.containsKey(id)) {
        var ally = alliesRemote[id];
        ally!.position = Vector2Rect(
            Vector2(x.toDouble(), y.toDouble()), Vector2(32 * 2, 32 * 2));
        switch (directionIndex) {
          case 0:
            ally.moveLeft(ally.speed);
            break;
          case 1:
            ally.moveRight(ally.speed);
            break;
          case 2:
            ally.moveUp(ally.speed);
            break;
          case 3:
            ally.moveDown(ally.speed);
            break;
          case 4:
            ally.moveUpLeft(ally.speed / 2, ally.speed / 2);
            break;
          case 5:
            ally.moveUpRight(ally.speed / 2, ally.speed / 2);
            break;
          case 6:
            ally.moveDownLeft(ally.speed / 2, ally.speed / 2);
            break;
          case 7:
            ally.moveDownRight(ally.speed / 2, ally.speed / 2);
            break;
          default:
            ally.idle();
            break;
        }
      }
    } else {
      if (impsRemote.containsKey(id)) {
        var imp = impsRemote[id];
        imp!.position =
            Vector2Rect(Vector2(x.toDouble(), y.toDouble()), Vector2(32, 32));
        switch (directionIndex) {
          case 0:
            imp.moveLeft(imp.speed);
            break;
          case 1:
            imp.moveRight(imp.speed);
            break;
          case 2:
            imp.moveUp(imp.speed);
            break;
          case 3:
            imp.moveDown(imp.speed);
            break;
          case 4:
            imp.moveUpLeft(imp.speed / 2, imp.speed / 2);
            break;
          case 5:
            imp.moveUpRight(imp.speed / 2, imp.speed / 2);
            break;
          case 6:
            imp.moveDownLeft(imp.speed / 2, imp.speed / 2);
            break;
          case 7:
            imp.moveDownRight(imp.speed / 2, imp.speed / 2);
            break;
          default:
            imp.idle();
            break;
        }
      }
    }
  }

  @override
  void animateAttack(String username) {
    players[username]!.attack();
  }

  @override
  void animateAIAttack(String id, int directionIndex, String type) {
    if (type == "ally") {
      alliesRemote[id]!.execAttack(directionIndex);
    } else {
      impsRemote[id]!.execAttack(directionIndex);
    }
  }

  @override
  void damageAI(String id, num damage, String type) {
    if (type == "ally") {
      if (allies.isNotEmpty) {
        allies[id]!.takeDamage(damage.toDouble(), null, false);
      } else {
        alliesRemote[id]!.takeDamage(damage.toDouble(), null, false);
      }
    } else {
      if (imps.isNotEmpty) {
        imps[id]!.takeDamage(damage.toDouble(), null, false);
      } else {
        impsRemote[id]!.takeDamage(damage.toDouble(), null, false);
      }
    }
  }

  @override
  void spawnResource(String baseId, String productionType, num storage) {
    if (hasGameRef) {
      var deposit = gameRef.componentsByType<DepositObject>().firstWhere(
          (element) => element.id.toUpperCase() == baseId.toUpperCase());
      deposit.handleBox(
          ResourceTypeParsing.fromString(productionType)!, storage.toInt());
    }
  }

  @override
  void updateResources(
      List<Resource> villageResources, List<Resource> playerResources) {
    watch(inventoryProvider.notifier).state = playerResources;
    watch(villageResourcesProvider.notifier).state = villageResources;
  }

  @override
  void stopBuff(String targetString) {
    Target target = TargetParsing.fromString(targetString)!;
    switch (target) {
      case Target.damage:
        attackRatio = 100;
        break;
      case Target.speed:
        updateSpeed(100);
        break;
      default:
        break;
    }
  }

  @override
  void updateWeather(String weather) {
    if (!watch(lockWeatherProvider.notifier).state) {
      WeatherType type = WeatherTypeParsing.fromString(weather)!;
      watch(weatherProvider.notifier).state = type;
    }
  }

  @override
  void updateDay(bool isDay) {
    var lightingLayers = gameRef.componentsByType<LightingComponent>();
    if (lightingLayers.length > 1) gameRef.remove(lightingLayers.last);
    watch(dayProvider.notifier).state = isDay;
    var buildings = gameRef.componentsByType<Building>();
    for (var building in buildings) {
      building.updateLighting();
    }

    var npcs = gameRef.componentsByType<NPC>();
    for (var npc in npcs) {
      npc.updateLighting();
    }

    var otherPlayers = gameRef.componentsByType<RemotePlayer>();
    for (var other in otherPlayers) {
      other.updateLighting();
    }

    _updateLighting();

    if (!isDay) {
      gameRef.add(LightingComponent(color: Colors.black.withOpacity(0.8)));
    }
  }

  @override
  void handleBuildingSpawn(String buildingId) {
    Map<String, Building> buildings = watch(buildingsProvider).state;
    buildings[buildingId]!.build();
    int id = int.parse(buildingId.substring(2));
    var npcs = watch(npcsProvider).state;
    npcs[id]!.spawn();
  }

  @override
  void damageBuilding(String buildingId, double damage) {
    var buildings = watch(buildingsProvider.notifier).state;
    buildings[buildingId]!.takeDamage(damage, null);
  }

  @override
  void repairBuilding(String buildingId) {
    var buildings = watch(buildingsProvider.notifier).state;
    buildings[buildingId]!.life = buildings[buildingId]!.maxLife;
  }

  @override
  void healAI(String id, double newLife) {
    if (allies.isNotEmpty) {
      allies[id]!.life = newLife;
    } else {
      alliesRemote[id]!.life = newLife;
    }
  }

  @override
  Future<void> heal(String username, double hp) async {
    if (!players.containsKey(username)) {
      life = hp;
      watch(hpProvider.notifier).state = life;
    } else {
      players[username]!.life = hp;
    }
  }

  @override
  Future<void> handleEventNotification(
      EventType type, int level, double duration) async {
    switch (type) {
      case EventType.calamity:
        gameRef.camera.shake(duration: duration * 6, intensity: 5.0 * level);
        watch(weatherProvider.notifier).state = WeatherType.lava;
        watch(lockWeatherProvider.notifier).state = true;
        break;
      case EventType.invasion:
        gameRef.camera.moveToPositionAnimated(
          const Offset(1000, 1400),
          zoom: 0.8,
          duration: const Duration(seconds: 1),
          finish: () async {
            gameRef.camera.shake(duration: 10, intensity: 5);
            await Future.delayed(const Duration(seconds: 1));
            gameRef.camera.moveToPlayerAnimated(
              zoom: 0.8,
            );
          },
        );
        break;
      case EventType.heal:
        gameRef.camera.shake(duration: 5, intensity: 5);
        break;
      default:
        break;
    }
  }

  @override
  void handleEventStart(EventType type, int level) {
    switch (type) {
      case EventType.calamity:
        watch(lockWeatherProvider.notifier).state = false;
        watch(weatherProvider).state = WeatherType.rain;
        break;
      default:
        break;
    }
  }

  @override
  void addPlayer(String username, double hp) {
    var newPlayer = RemotePlayer(Vector2(1300, 675), username, watch, hp);
    players[username] = newPlayer;
    gameRef.add(newPlayer);
  }

  @override
  void removePlayer(String username) async {
    if (players.containsKey(username)) {
      players[username]!.die();
      players.remove(username);
    }
  }

  @override
  void endGame() {
    die();
  }

  @override
  void takeDamage(String username, double damage) {
    if (!players.containsKey(username)) {
      receiveDamage2(damage, null);
    } else {
      players[username]!.receiveDamage2(damage, null);
    }
  }
}
