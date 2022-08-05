import 'dart:convert';
import 'package:front/services/service_config.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static Future<bool> healAlly(String aiId) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/healally");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "ai_id": aiId}));
    if (response.statusCode == 200) return response.body == 'true';
    return false;
  }

  static Future<String?> getDadJoke() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/dadjoke");
    final response = await Client().get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) return response.body;
    return null;
  }
}
