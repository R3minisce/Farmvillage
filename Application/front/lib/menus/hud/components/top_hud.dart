import 'package:flutter/material.dart';
import 'package:front/menus/hud/components/avatar_hud.dart';
import 'package:front/menus/hud/components/bars_hud.dart';
import 'package:front/menus/hud/components/resources_hud.dart';

class TopHUD extends StatelessWidget {
  const TopHUD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          const AvatarHUD(),
          const BarsHUD(),
          Expanded(flex: 10, child: Container()),
          const ResourcesHUD(),
        ],
      ),
    );
  }
}
