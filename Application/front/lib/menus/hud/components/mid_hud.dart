import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/menus/hud/components/inventory_row.dart';
import 'package:front/menus/hud/components/village_resources_row.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/models/resource.dart';
import 'package:front/services/inventory_service.dart';

class MidHUD extends StatelessWidget {
  const MidHUD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconSize = 25;
    return Consumer(
      builder: (context, watch, child) {
        var test = watch(inventoryProvider).state;
        var resources = watch(villageResourcesProvider).state;
        return Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.only(right: 8.0),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 1,
                  child: Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.vertical,
                    children: _buildInventory(test),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VillageResourcesRow(
                          amount: resources[resources.indexWhere(
                                  (e) => e.label == ResourceType.ally)]
                              .quantity,
                          maxAmount: resources[resources.indexWhere(
                                  (e) => e.label == ResourceType.ally)]
                              .maxQuantity,
                          icon: Image.asset("assets/images/items/biquette.png",
                              height: iconSize, width: iconSize)),
                      const SizedBox(height: 8.0),
                      VillageResourcesRow(
                          amount: resources[resources.indexWhere(
                                  (e) => e.label == ResourceType.enemy)]
                              .quantity,
                          maxAmount: resources[resources.indexWhere(
                                  (e) => e.label == ResourceType.enemy)]
                              .maxQuantity,
                          icon: Image.asset("assets/images/items/ally.png",
                              height: iconSize, width: iconSize)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildInventory(List<Resource> inventory) {
    double iconSize = 25;
    return List.generate(
      inventory.length,
      (index) {
        if (inventory[index].label != ResourceType.gold &&
            inventory[index].quantity != 0) {
          var indexEnum = inventory[index].label.index;

          var type = ResourceType.values[indexEnum].toShortString();
          return InventoryRow(
            amount: inventory[index].quantity,
            icon: Image.asset("assets/images/items/$type.png",
                height: iconSize, width: iconSize),
          );
        }
        return Container();
      },
    );
  }
}
