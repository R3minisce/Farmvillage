import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/models/resource.dart';
import 'package:front/services/service_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class InventoryService {
  static Future<List<Resource>> getInventory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri = Uri.http(
        "$gameEngineIP:$gameEngineHttpPort", "/player/$token/inventory");
    final response = await Client().get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final List<dynamic> parsed = jsonDecode(utf8.decode(response.bodyBytes));
    var res = parsed
        .map((e) => Resource(ResourceTypeParsing.fromString(e['label'])!,
            e['quantity'], e['max_quantity']))
        .toList();
    return res;
  }

  static Future<bool> pickupBoiboite(String buildingId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/pickbox");
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
}

final inventoryServiceProvider = Provider((ref) => InventoryService());

final inventoryProvider = StateProvider<List<Resource>>((ref) => []);
final villageResourcesProvider = StateProvider<List<Resource>>((ref) => []);
