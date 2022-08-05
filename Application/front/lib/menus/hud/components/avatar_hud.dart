import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/icon_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/menus/hud/components/link_hud.dart';
import 'package:front/providers.dart';
import 'package:front/screens/rooms_screen.dart';
import 'package:front/services/authentication_service.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/custom_sprite_animation_widget.dart';
import 'package:front/utils/spriteSheets/player_sprite_sheet.dart';

class AvatarHUD extends StatelessWidget {
  const AvatarHUD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: InkWell(
        onTap: () => _openCodeDialog(context),
        child: SizedBox(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: shadowBorder(
              16,
              16,
              Colors.black.withOpacity(0.2),
            ),
            child: Center(
              child: CustomSpriteAnimationWidget(
                animation: PlayerSpriteSheet.idleRight(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            child: Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(color: Colors.transparent),
                ),
                Expanded(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        child: Container(color: Colors.transparent),
                      ),
                      MenuItem(
                          icon: Icons.close,
                          iconColor: Colors.red,
                          func: () => Navigator.of(context).pop()),
                      MenuItem(
                          icon: Icons.link,
                          iconColor: Colors.white,
                          func: () => _openLinkDialog(context)),
                      MenuItem(
                          icon: Icons.logout,
                          iconColor: Colors.white,
                          func: () => _logout(context)),
                      Expanded(
                        child: Container(color: Colors.transparent),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _logout(BuildContext context) async {
    var res = await AuthenticationService.logoutVillage();
    if (res != null) {
      context.read(villagesProvider.notifier).state = res;
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                RoomsScreen(socketManager: SocketManager()),
          ),
          (route) => false);
    } else {}
  }

  void _openLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const LinkingPopup();
      },
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback func;

  const MenuItem({
    required this.icon,
    required this.iconColor,
    required this.func,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: IconActionButton(
            color: Colors.black,
            icon: icon,
            iconColor: iconColor,
            borderFunc: shadowBorder(32, 32, Colors.grey.shade900),
            onTap: func,
          ),
        ),
      ),
    );
  }
}
