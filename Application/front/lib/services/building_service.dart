import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/models/item.dart';
import 'package:front/providers.dart';
import 'package:front/services/service_config.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildingService {
  Future<dynamic> getInfosBuilding(String buildingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/building/");
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "building_id": buildingId}));
    final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    return parsed;
  }

  static Future<bool> updateBuildingResources(
      String buildingId, String label, int quantity) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri = Uri.http(
        "$gameEngineIP:$gameEngineHttpPort", "/building/upgrade/resource");
    final response = await Client().put(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "token": token,
          "building_id": buildingId,
          "label": label.toUpperCase(),
          "quantity": quantity
        }));
    // final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return response.body == 'true';
    return false;
  }

  static Future<bool> addVillagerToBuilding(String buildingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri =
        Uri.http("$gameEngineIP:$gameEngineHttpPort", "/building/villager");
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "token": token,
          "building_id": buildingId,
        }));
    // final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return response.body == 'true';
    return false;
  }

  static Future<bool> removeVillagerFromBuilding(String buildingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri =
        Uri.http("$gameEngineIP:$gameEngineHttpPort", "/building/villager");
    final response = await Client().delete(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "token": token,
          "building_id": buildingId,
        }));
    if (response.statusCode == 200) return response.body == 'true';
    return false;
  }

  static Future<bool> upgradeBuilding(String buildingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri =
        Uri.http("$gameEngineIP:$gameEngineHttpPort", "/building/upgrade");
    final response = await Client().put(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "building_id": buildingId}));
    // final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    return response.statusCode == 200;
  }

  static Future<bool> repairBuilding(String buildingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/building/repair");
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "building_id": buildingId}));
    // final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return response.body == 'true';
    return false;
  }

  Future<List<Item>> getPotions() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/item/potion");
    final response = await Client().get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    List<Item> items = [];
    parsed.forEach((item) {
      items.add(Item.fromJSON(item));
    });
    return items;
  }

  Future<List<Item>> getBankItems() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/bank/item");
    final response = await Client().get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    List<Item> items = [];
    parsed.forEach((item) {
      items.add(Item.fromJSON(item));
    });
    return items;
  }

  static Future<dynamic> buyItem(String itemId) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/buy/item");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "item_id": itemId}));
    if (response.statusCode == 200) {
      if (response.body == "false") return false;

      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<bool> buyItemPaypal(
      String itemId, String nonce, String deviceData) async {
    var uri = Uri.http(
        "$gameEngineIP:$gameEngineHttpPort", "/paypal/buy/item/$itemId");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {"token": token, "nonce": nonce, "device_data": deviceData}));
    return response.statusCode == 200;
  }

  static Future<dynamic> buyVillager() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/buy/villager");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token}));
    if (response.statusCode == 200) {
      if (response.body == "false") return false;

      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<dynamic> buyAlly() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/buy/ally");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token}));
    if (response.statusCode == 200) {
      if (response.body == "false") return false;

      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<bool> handleBuildingResources(
      String buildingId, String label, int quantity) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri =
        Uri.http("$gameEngineIP:$gameEngineHttpPort", "/building/resource");
    final response = await Client().put(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "token": token,
          "building_id": buildingId,
          "label": label.toUpperCase(),
          "quantity": quantity
        }));
    // final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return response.body == 'true';
    return false;
  }
}

final buildingServiceProvider = Provider((ref) => BuildingService());

final getInfosBuildingProvider = FutureProvider<dynamic>((ref) async {
  String buildingId = ref.watch(selectedBuildingId).state;
  ref.watch(refreshProvider);
  final buildingService = ref.read(buildingServiceProvider);
  return await buildingService.getInfosBuilding(buildingId);
});

final getPotionsProvider = FutureProvider<List<Item>>((ref) async {
  ref.watch(refreshProvider);
  final buildingService = ref.read(buildingServiceProvider);
  return await buildingService.getPotions();
});

final getBankItemsProvider = FutureProvider<List<Item>>((ref) async {
  ref.watch(refreshProvider);
  final buildingService = ref.read(buildingServiceProvider);
  return await buildingService.getBankItems();
});

final selectedBuildingId = StateProvider<String>((ref) => '');
