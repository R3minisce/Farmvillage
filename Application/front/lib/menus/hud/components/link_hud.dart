import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/menus/hud/components/connect_popup.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/providers.dart';
import 'package:front/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_login/twitter_login.dart';

class LinkItem extends StatelessWidget {
  final bool isLinked;
  final AuthType type;
  final String image;
  final String title;
  final GlobalKey<FormBuilderState> formKey;

  const LinkItem({
    required this.isLinked,
    required this.type,
    required this.image,
    required this.title,
    required this.formKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 2,
            child: Container(color: Colors.transparent),
          ),
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent, child: Text(title)),
          ),
          Expanded(
            flex: 4,
            child: Image.asset(image, height: 50, width: 50),
          ),
          Expanded(
            child: Material(
              child: InkWell(
                  child: !isLinked
                      ? const Icon(Icons.link, color: Colors.blue, size: 30)
                      : const Icon(Icons.check, color: Colors.green, size: 30),
                  onTap: !isLinked
                      ? () async => _linkService(type, context)
                      : () {}),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  _linkService(AuthType type, BuildContext context) async {
    switch (type) {
      case AuthType.BoomCraft:
        _openConnectDialog(context, type, "Email");
        break;
      case AuthType.VeggieCrush:
        _openConnectDialog(context, type, "Username");
        break;
      case AuthType.Facebook:
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['public_profile', 'email'],
        );
        if (result.status == LoginStatus.success) {
          final userData = await FacebookAuth.instance.getUserData();
          var result2 = await AuthenticationService.linkExternal(
              userData['name'],
              userData['email'],
              type.toShortString(),
              userData['id'].toString(),
              null,
              null,
              null);
          if (result2) {
            var logins = Map.of(context.read(loginsProvider.notifier).state);
            logins[AuthType.Facebook] = true;
            context.read(loginsProvider.notifier).state = logins;
          }
        } else {}
        break;
      case AuthType.Twitter:
        final twitterLogin = TwitterLogin(
          apiKey: 'R6xprY3s6mbjYk7FUmXftcjBi',
          apiSecretKey: 'tWIJlr1JOe2S6vJyxl43cPVv5Nr9Unl8E0Cwc57k4LRl8QUkDG',
          redirectURI: 'com.example.front://login-callback',
        );
        final authResult = await twitterLogin.loginV2();
        if (authResult.status == TwitterLoginStatus.loggedIn) {
          var result2 = await AuthenticationService.linkExternal(
              authResult.user!.name,
              null,
              type.toShortString(),
              authResult.user!.id.toString(),
              null,
              authResult.authToken,
              authResult.authTokenSecret);
          if (result2) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setString('twittertoken', authResult.authToken!);
            prefs.setString('twittersecret', authResult.authTokenSecret!);
            var logins = Map.of(context.read(loginsProvider.notifier).state);
            logins[AuthType.Twitter] = true;
            context.read(loginsProvider.notifier).state = logins;
          } else {}
        } else {}
        break;
      default:
        break;
    }
  }

  void _openConnectDialog(BuildContext context, AuthType type, String label) {
    var name = type.toShortString();
    showDialog(
      context: context,
      builder: (context) {
        return ConnectPopup(
            name: name, formKey: formKey, label: label, type: type);
      },
    );
  }
}

class LinkingPopup extends StatelessWidget {
  const LinkingPopup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        child: Container(
          margin: const EdgeInsets.all(48.0),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 1,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    const Expanded(
                      flex: 10,
                      child: Text("Link your other accounts !",
                          style: TextStyle(fontSize: 20)),
                    ),
                    Expanded(
                      child: Material(
                        child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close,
                                color: Colors.red, size: 30)),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
              LinkingPanel(),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
            ],
          ),
          decoration: shadowBorder(
            32,
            32,
            Colors.white,
          ),
        ),
      ),
    );
  }
}

class LinkingPanel extends StatelessWidget {
  LinkingPanel({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var loginsMap = watch(loginsProvider).state;
        return Expanded(
          flex: 8,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Container(color: Colors.transparent),
              ),
              LinkItem(
                isLinked: loginsMap[AuthType.Facebook]!,
                type: AuthType.Facebook,
                image: "assets/other/facebook.png",
                title: "Facebook",
                formKey: _formKey,
              ),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
              LinkItem(
                isLinked: loginsMap[AuthType.Twitter]!,
                type: AuthType.Twitter,
                image: "assets/other/twitter.png",
                title: "Twitter",
                formKey: _formKey,
              ),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
              LinkItem(
                  isLinked: loginsMap[AuthType.VeggieCrush]!,
                  type: AuthType.VeggieCrush,
                  image: "assets/other/veggiecrush.png",
                  title: "VeggieCrush",
                  formKey: _formKey),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
              LinkItem(
                  isLinked: loginsMap[AuthType.BoomCraft]!,
                  type: AuthType.BoomCraft,
                  image: "assets/other/boomcraft.png",
                  title: "BoomCraft",
                  formKey: _formKey),
              Expanded(
                child: Container(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }
}
