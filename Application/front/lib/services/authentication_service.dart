import 'dart:convert';
import 'package:front/services/service_config.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  static Future<dynamic> login(String username, String password) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/login");
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"username": username, "password": password}));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', parsed['token']);
      prefs.setString('username', parsed['username']);
      return parsed;
    }
    return null;
  }

  static Future<dynamic> loginExternal(String id, String type) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/login/external");
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"id": id, "type": type}));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', parsed['token']);
      return parsed;
    }
    return null;
  }

  static Future<dynamic> register(
      String username, String email, String password) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/register");
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {"username": username, "email": email, "password": password}));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', parsed['token']);
      return parsed;
    }
    return null;
  }

  static Future<bool> linkExternal(
      String username,
      String? email,
      String type,
      String id,
      String? refreshToken,
      String? accessToken,
      String? accessTokenSecret) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/link/external");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "token": token,
          "refresh_token": refreshToken,
          "access_token": accessToken,
          "access_token_secret": accessTokenSecret,
          "username": username,
          "email": email,
          "type": type,
          "id": id
        }));
    return response.statusCode == 200;
  }

  static Future<dynamic> loginBoomCraft(String email, String password) async {
    var uri = Uri.http("$boomCraftIP:$boomCraftPort", "/user/connect",
        {"mail_user": email, "password": password});
    final response = await Client().get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<dynamic> getProfilVeggieCrush(String accessToken) async {
    var uri = Uri.http("$veggieCrushIP:$veggieCrushPort", "/users/me");
    final response = await Client().get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + accessToken
      },
    );
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<dynamic> loginVeggieCrush(
      String username, String password) async {
    var uri = Uri.http(
      "$veggieCrushIP:$veggieCrushPort",
      "/login",
    );
    final response = await Client().post(uri, headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    }, body: {
      "username": username,
      "password": password,
    });
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<dynamic> joinVillage(String villageId) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/join/village");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "village_id": villageId}));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<dynamic> joinFriend(String username) async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/join/friend");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token, "username": username}));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<dynamic> logoutVillage() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/logout/village");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token}));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<bool> logout() async {
    var uri = Uri.http("$gameEngineIP:$gameEngineHttpPort", "/logout");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": token}));
    return response.statusCode == 200;
  }
}
