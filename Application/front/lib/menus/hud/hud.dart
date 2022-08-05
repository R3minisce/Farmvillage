import 'package:flutter/material.dart';
import 'package:front/menus/hud/components/bottom_hud.dart';
import 'package:front/menus/hud/components/mid_hud.dart';
import 'package:front/menus/hud/components/top_hud.dart';

class HUD extends StatelessWidget {
  const HUD({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        child: Flex(
          direction: Axis.vertical,
          children: const [
            TopHUD(),
            MidHUD(),
            BottomHUD(),
          ],
        ),
      ),
    );
  }
}
