import 'package:front/allies/ally.dart';
import 'package:front/enemies/imp.dart';
import 'package:front/models/event_type.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/models/resource.dart';
import 'package:front/services/service_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:front/sockets/interface_game_ref.dart';

class SocketManager {
  static late io.Socket socket;
  String url = 'http://$gameEngineIP:$gameEngineSocketPort';
  //String url = 'http://192.168.1.19:3000';
  //String url = 'http://192.113.50.2:21001';
  String actionLabel = "action";
  String connectionLabel = "connection";
  String aiLabel = "AI";
  String villageLabel = "village";
  String buildingLabel = "building";
  String playerLabel = 'player update';

  static final SocketManager _singleton = SocketManager._internal();

  factory SocketManager() {
    return _singleton;
  }

  SocketManager._internal();

  void connectToServer() {
    socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableReconnection()
            .build());

    socket.onConnect((_) {
      print("connected");
    });

    // connection lost to server
    socket.onDisconnect((_) => print('disconnect'));
  }

  void registerToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    socket.emit("register token", {"token": token});
  }

  void startListening(IGameRef gRef) {
    //listen to type 'message' response
    socket.on(
      playerLabel,
      (data) {
        switch (data['action']) {
          case "move":
            gRef.updateOtherPlayerPos(
                data['username'],
                data['direction'],
                data['position']['x'].toDouble(),
                data['position']['y'].toDouble());
            break;
          case "attack":
            gRef.animateAttack(data['username']);
            break;
          case 'damage':
            num damage = data['damage'];
            gRef.takeDamage(data['username'], damage.toDouble());
            break;
          case "hp":
            num hp = data['hp'];
            gRef.heal(data['username'], hp.toDouble());
            break;
          case 'connection':
            num hp = data['hp'];
            gRef.addPlayer(data['username'], hp.toDouble());
            break;
          default:
            break;
        }
      },
    );
    socket.on(aiLabel, (data) {
      switch (data['action']) {
        case "create":
          gRef.createAI(data['type'], data['number']);
          break;
        case "spawn":
          num x = data['position']['x'];
          num y = data['position']['y'];
          gRef.createAIRemote(
            data['type'],
            x,
            y,
            data['id'],
          );
          break;
        case "move":
          num x = data['position']['x'];
          num y = data['position']['y'];
          gRef.updateAIPosition(
              data['id'], data['direction'], x, y, data['type']);
          break;
        case "attack":
          gRef.animateAIAttack(data['id'], data['direction'], data['type']);
          break;
        case "damage":
          gRef.damageAI(data['id'], data['damage'], data['type']);
          break;
        case "hp":
          num hp = data['hp'];
          gRef.healAI(data['id'], hp.toDouble());
          break;
        default:
          break;
      }
    });
    socket.on("update box", (data) {
      gRef.spawnResource(
          data['base_id'], data['production_type'], data['storage']);
    });
    socket.on("effect", (data) {
      if (data['action'] == "stop") {
        gRef.stopBuff(data['target']);
      }
    });
    socket.on("update resources", (data) {
      if (data['action'] == "resources") {
        var villageInventory = data['resources_village'] as List;
        var villageResources = villageInventory
            .map((e) => Resource(ResourceTypeParsing.fromString(e['label'])!,
                e['quantity'], e['max_quantity']))
            .toList();
        var playerInventory = data['resources_player'] as List;
        var playerResources = playerInventory
            .map((e) => Resource(ResourceTypeParsing.fromString(e['label'])!,
                e['quantity'], e['max_quantity']))
            .toList();
        gRef.updateResources(villageResources, playerResources);
      }
    });
    socket.on("building", (data) {
      switch (data['action']) {
        case "upgraded":
          if (data['level'] == 1) gRef.handleBuildingSpawn(data['building_id']);
          break;
        case "damage":
          num damage = data['damage'];
          gRef.damageBuilding(data['building_id'], damage.toDouble());
          break;
        case "repaired":
          gRef.repairBuilding(data['building_id']);
          break;
        default:
          break;
      }
    });
    socket.on("event", (data) {
      switch (data['action']) {
        case "notification":
          var type = EventTypeParsing.fromString(data['type']);
          num level = data['level'];
          num duration = data['countdown'] / 1000;
          gRef.handleEventNotification(
              type!, level.toInt(), duration.toDouble());
          break;
        case "start":
          var type = EventTypeParsing.fromString(data['type']);
          num level = data['level'];
          gRef.handleEventStart(type!, level.toInt());
          break;
        default:
          break;
      }
    });
    socket.on("weather update", (data) {
      gRef.updateWeather(data);
    });
    socket.on("day update", (data) {
      var dataString = data as String;
      gRef.updateDay(dataString.toUpperCase() == "DAY");
    });
    socket.on("player left", (data) {
      gRef.removePlayer(data['username']);
    });
    socket.on("game ended", (data) {
      gRef.endGame();
    });
    socket.on("error", (data) => print(data));
  }

  /// Send new position to the server
  void emitActionMove(double newposX, double newPosY, int directionIndex) {
    socket.emit(actionLabel, {
      "action": "move",
      "direction": directionIndex,
      "position": {'x': newposX, 'y': newPosY}
    });
  }

  void emitPlayerReceivedDamage(String username, num damage) {
    socket.emit(actionLabel,
        {"action": "damage", "username": username, "damage": damage});
  }

  /// Send that an attack is performed
  void emitAttack() {
    socket.emit(actionLabel, {"action": "attack"});
  }

  /// Send that a new enemy has spawned
  void emitEnemySpawn(Imp enemy) {
    socket.emit(aiLabel, enemy.toJSON());
  }

  /// Send that a new ally has spawned
  void emitAllySpawn(Ally ally) {
    socket.emit(aiLabel, ally.toJSON());
  }

  /// Send the new posiion of an AI
  void emitAIPosition(
      int directionIndex, double x, double y, String id, String type) {
    socket.emit(aiLabel, {
      "action": "move",
      "direction": directionIndex,
      "position": {"x": x, "y": y},
      "id": id,
      "type": type
    });
  }

  /// Send that an AI's attack is performed
  void emitAIAttack(String id, int directionIndex, String type) {
    socket.emit(aiLabel, {
      "action": "attack",
      "id": id,
      "direction": directionIndex,
      "type": type
    });
  }

  /// Send that an AI received damage
  void emitAIReceivedDamage(String id, num damage, String type) {
    socket.emit(aiLabel,
        {"action": "damage", "id": id, "damage": damage, "type": type});
  }

  void emitUpdateVillageResources() {
    socket.emit(villageLabel, {"action": "get resources"});
  }

  void emitBuildingReceiveDamage(String buildingId, num damage) {
    socket.emit(buildingLabel,
        {"action": "damage", "building_id": buildingId, "damage": damage});
  }
}
