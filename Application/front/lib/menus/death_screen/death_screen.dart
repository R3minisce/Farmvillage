import 'package:flutter/material.dart';
import 'package:front/components/icon_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/screens/rooms_screen.dart';
import 'package:front/sockets/socket_manager.dart';

/// Menu opened when YOU DIE
class DeathScreen extends StatelessWidget {
  const DeathScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
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
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: const Center(
                  child: Text(
                    "WASTED",
                    style: TextStyle(color: Colors.red, fontSize: 32),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: IconActionButton(
                    color: Colors.black,
                    icon: Icons.close,
                    iconColor: Colors.red,
                    borderFunc: shadowBorder(32, 32, Colors.grey.shade900),
                    onTap: () => _leaveGame(context),
                  ),
                ),
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
  }

  _leaveGame(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) =>
              RoomsScreen(socketManager: SocketManager()),
        ),
        (route) => false);
  }
}
