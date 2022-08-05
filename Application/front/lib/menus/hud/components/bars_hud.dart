import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/menus/hud/components/hp_bar.dart';
import 'package:front/menus/hud/components/stamina_bar.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/providers.dart';
import 'package:front/services/inventory_service.dart';

class BarsHUD extends StatelessWidget {
  const BarsHUD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 20,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: Container(color: Colors.transparent),
          ),
          const HpBar(),
          Expanded(
            child: Container(color: Colors.transparent),
          ),
          const StaminaBar(),
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
          Expanded(
            flex: 2,
            child: Consumer(
              builder: (context, watch, _) {
                var resources = watch(inventoryProvider).state;
                var goldIndex = resources.indexWhere(
                    (element) => element.label == ResourceType.gold);
                var gold =
                    (goldIndex != -1) ? resources[goldIndex].quantity : 0;
                return Row(
                  children: [
                    Text(
                      "$gold",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 8.0),
                    Image.asset(
                      "assets/images/items/gold.png",
                      height: 24,
                      width: 24,
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
