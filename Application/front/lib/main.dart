import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/icon_button.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/models/resource.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/providers.dart';
import 'package:front/screens/register_screen.dart';
import 'package:front/screens/rooms_screen.dart';
import 'package:front/services/authentication_service.dart';
import 'package:front/services/inventory_service.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/shadow_border.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setOrientation(DeviceOrientation.landscapeLeft);
  await Sounds.initialize();
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: const HomePage(),
        theme: ThemeData(textTheme: GoogleFonts.comfortaaTextTheme()),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          FormBuilderLocalizations.delegate,
        ],
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool showSplash = true;
  late SocketManager socketManager;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showSplash ? buildSplash() : buildMenu(context),
    );
  }

  Widget buildSplash() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: (BuildContext context) {
        setState(() {
          showSplash = false;
        });
      },
    );
  }

  Widget buildMenu(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              height: double.infinity,
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FormBuilderTextField(
                        name: "username",
                        validator: FormBuilderValidators.required(context),
                        decoration: const InputDecoration(
                          filled: false,
                          labelText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FormBuilderTextField(
                        name: "password",
                        validator: FormBuilderValidators.required(context),
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: false,
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 400,
                        height: 50,
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(child: Container()),
                            Expanded(
                              flex: 8,
                              child: ActionButton(
                                  color: Colors.white,
                                  textColor: Colors.lightBlue,
                                  label: "register",
                                  borderFunc: const BoxDecoration(),
                                  onPressed: _register),
                            ),
                            Expanded(child: Container()),
                            Expanded(
                              flex: 2,
                              child: ImageActionButton(
                                  borderFunc: shadowBorder(16, 16, Colors.blue),
                                  onTap: () async =>
                                      _validateAction(AuthType.Facebook),
                                  image: "assets/other/facebook.png"),
                            ),
                            Expanded(child: Container()),
                            Expanded(
                              flex: 2,
                              child: ImageActionButton(
                                  borderFunc: shadowBorder(16, 16, Colors.red),
                                  onTap: () async =>
                                      _validateAction(AuthType.BoomCraft),
                                  image: "assets/other/boomcraft.png"),
                            ),
                            Expanded(child: Container()),
                            Expanded(
                              flex: 2,
                              child: ImageActionButton(
                                  borderFunc:
                                      shadowBorder(16, 16, Colors.orange),
                                  onTap: () async =>
                                      _validateAction(AuthType.VeggieCrush),
                                  image: "assets/other/veggiecrush.png"),
                            ),
                            Expanded(child: Container()),
                            Expanded(
                              flex: 2,
                              child: ImageActionButton(
                                  borderFunc:
                                      shadowBorder(16, 16, Colors.white),
                                  onTap: () async =>
                                      _validateAction(AuthType.FarmVillage),
                                  image: "assets/other/farmvillage.png"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/other/map.png'),
                  alignment: Alignment.topLeft,
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  height: 100,
                  child: Center(
                    child: Text(
                      "FarmVillage",
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAction(AuthType type) async {
    if (_formKey.currentState!.saveAndValidate() || type == AuthType.Facebook) {
      var username = _formKey.currentState!.value['username'];
      var password = _formKey.currentState!.value['password'];

      dynamic res;

      switch (type) {
        case AuthType.FarmVillage:
          res = await AuthenticationService.login(username, password);
          break;
        case AuthType.BoomCraft:
          var tmp =
              await AuthenticationService.loginBoomCraft(username, password);
          if (tmp != null) {
            res = await AuthenticationService.loginExternal(
                tmp['id_user'].toString(), type.toShortString());
          } else {
            // TODO error
          }
          break;
        case AuthType.VeggieCrush:
          var tmp =
              await AuthenticationService.loginVeggieCrush(username, password);
          if (tmp != null) {
            var result = await AuthenticationService.getProfilVeggieCrush(
                tmp['access_token']);
            if (result != null) {
              res = await AuthenticationService.loginExternal(
                  result['id'].toString(), type.toShortString());
            } else {}
          } else {}
          break;
        case AuthType.Facebook:
          final LoginResult result = await FacebookAuth.instance.login(
            permissions: ['public_profile', 'email'],
          );
          if (result.status == LoginStatus.success) {
            final userData = await FacebookAuth.instance.getUserData();
            res = await AuthenticationService.loginExternal(
                userData['id'].toString(), type.toShortString());
          } else {}
          break;
        default:
      }

      if (res != null) {
        context.read(villagesProvider.notifier).state = res['villages'];
        var player = res['player'];
        var playerInventory = player['inventory'] as List;
        var playerResources = playerInventory
            .map((e) => Resource(ResourceTypeParsing.fromString(e['label'])!,
                e['quantity'], e['max_quantity']))
            .toList();
        num hp = player['hp'];
        context.read(hpProvider.notifier).state = hp.toDouble();
        context.read(inventoryProvider.notifier).state = playerResources;
        await _updateLogins(res['external_logins'], context);
        socketManager = SocketManager();
        socketManager.connectToServer();
        socketManager.registerToken();
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                RoomsScreen(socketManager: socketManager),
          ),
        );
      } else {
        // gérer pb de login
      }
    }
  }

  _updateLogins(dynamic externalLogins, BuildContext context) async {
    var logins = Map.of(context.read(loginsProvider.notifier).state);
    for (var login in externalLogins) {
      logins[AuthTypeParsing.fromString(login['type'])!] = true;
      if (login['type'] == 'Twitter') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('twittertoken', login['access_token']);
        await prefs.setString('twittersecret', login['access_token_secret']);
      }
    }
    context.read(loginsProvider.notifier).state = logins;
  }

  void _register() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _showSuccessSnackBar() {
    var snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      content: Text(
        'Register successful.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
