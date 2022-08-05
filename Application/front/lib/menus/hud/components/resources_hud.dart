import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/menus/hud/components/village_resources_row.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/services/inventory_service.dart';

class ResourcesHUD extends StatelessWidget {
  const ResourcesHUD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 25;
    return Expanded(
      flex: 30,
      child: Consumer(
        builder: (context, watch, _) {
          var resources = watch(villageResourcesProvider).state;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
            child: Flex(
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.vertical,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VillageResourcesRow(
                        amount: resources[resources.indexWhere(
                                (e) => e.label == ResourceType.villager)]
                            .quantity,
                        maxAmount: resources[resources.indexWhere(
                                (e) => e.label == ResourceType.villager)]
                            .maxQuantity
                            .toInt(),
                        icon: Image.asset("assets/images/items/villager.png",
                            height: iconSize, width: iconSize)),
                    const SizedBox(width: 8.0),
                    VillageResourcesRow(
                        amount: resources[resources.indexWhere(
                                (e) => e.label == ResourceType.food)]
                            .quantity,
                        icon: Image.asset("assets/images/items/food.png",
                            height: iconSize, width: iconSize)),
                    const SizedBox(width: 8.0),
                    VillageResourcesRow(
                        amount: resources[resources.indexWhere(
                                (e) => e.label == ResourceType.wood)]
                            .quantity,
                        icon: Image.asset("assets/images/items/wood.png",
                            height: iconSize, width: iconSize)),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VillageResourcesRow(
                        amount: resources[resources.indexWhere(
                                (e) => e.label == ResourceType.stone)]
                            .quantity,
                        icon: Image.asset("assets/images/items/stone.png",
                            height: iconSize, width: iconSize)),
                    const SizedBox(width: 8.0),
                    VillageResourcesRow(
                        amount: resources[resources.indexWhere(
                                (e) => e.label == ResourceType.iron)]
                            .quantity,
                        icon: Image.asset("assets/images/items/iron.png",
                            height: iconSize, width: iconSize)),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
