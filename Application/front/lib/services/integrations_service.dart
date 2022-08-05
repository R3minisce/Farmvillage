import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/models/item.dart';
import 'package:front/providers.dart';
import 'package:front/services/service_config.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:crypto/crypto.dart';

class IntegrationsService {
  static Future<bool> tweet(String text) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('twittertoken');
    String nonce = _generateNonce();
    String timestamp = _getTimestamp().round().toString();

    String consumer = 'R6xprY3s6mbjYk7FUmXftcjBi';
    String url = "https://api.twitter.com/2/tweets";

    String consumerSecret =
        'tWIJlr1JOe2S6vJyxl43cPVv5Nr9Unl8E0Cwc57k4LRl8QUkDG';
    String? tokenSecret = prefs.getString('twittersecret');

    // URL creation

    String base = "oauth_consumer_key=$consumer&oauth_nonce=$nonce" +
        "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=$timestamp" +
        "&oauth_token=$token&oauth_version=1.0";

    String signature =
        await _getSignature(base, url, consumerSecret, tokenSecret!);

    var uri = Uri.https(twitterURL, "/2/tweets");

    final response = await Client().post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'OAuth oauth_consumer_key="$consumer",oauth_token="$token",oauth_signature_method="HMAC-SHA1",oauth_timestamp="$timestamp",oauth_nonce="$nonce",oauth_version="1.0",oauth_signature="${Uri.encodeComponent(signature)}"',
        },
        body: jsonEncode({"text": text}));

    return (response.statusCode == 200);
  }

  static String _generateNonce() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random.secure();

    return String.fromCharCodes(
      Iterable.generate(
        11,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );
  }

  static double _getTimestamp() {
    DateTime date = DateTime.now();
    return date.millisecondsSinceEpoch / 1000;
  }

  static Future<String> _getSignature(String base, String url,
      String consumerSecret, String tokenSecret) async {
    String baseV2 =
        "POST&" + Uri.encodeComponent(url) + "&" + Uri.encodeComponent(base);

    String signingKey = Uri.encodeComponent(consumerSecret) +
        "&" +
        Uri.encodeComponent(tokenSecret);

    var key = utf8.encode(signingKey);
    var bytes = utf8.encode(baseV2);

    var hmacSha1 = Hmac(sha1, key); // HMAC-SHA256
    var digest = hmacSha1.convert(bytes);

    return base64.encode(digest.bytes);
  }

  Future<List<Item>> getPotionsVeggieCrush() async {
    var uri =
        Uri.http("$gameEngineIP:$gameEngineHttpPort", "/veggiecrush/inventory");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await Client().post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {"token": token},
      ),
    );
    final parsed = jsonDecode(utf8.decode(response.bodyBytes));
    List<Item> items = [];
    parsed.forEach((item) {
      items.add(Item.fromJSON(item));
    });
    return items;
  }

  static Future<dynamic> usePotionsVeggieCrush(String potionId) async {
    var uri = Uri.http(
        "$gameEngineIP:$gameEngineHttpPort", "/veggiecrush/use/potion");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await Client().post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "token": token,
          "potion_id": potionId,
        },
      ),
    );
    if (response.statusCode == 200) {
      final parsed = jsonDecode(utf8.decode(response.bodyBytes));
      return parsed;
    }
    return null;
  }

  static Future<bool> sendResourcesBoomCraft(String label, int quantity) async {
    var uri = Uri.http(
        "$gameEngineIP:$gameEngineHttpPort", "/boomcraft/add/resource");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await Client().post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {"token": token, "label": label.toUpperCase(), "quantity": quantity},
      ),
    );
    if (response.statusCode == 200) {
      return response.body == "true";
    }
    return false;
  }
}

final integrationsServiceProvider = Provider((ref) => IntegrationsService());

final getPotionsVeggieProvider = FutureProvider<List<Item>>((ref) async {
  ref.watch(refreshProvider);
  final integrationService = ref.read(integrationsServiceProvider);
  return await integrationService.getPotionsVeggieCrush();
});
