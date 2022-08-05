import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/building_file.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';

class VillagerRow extends StatelessWidget {
  const VillagerRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${data.productionRate}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 16.0),
              Image.asset(
                "assets/images/items/${data.productionType.toShortString()}.png",
                height: 25,
                width: 25,
              ),
              const SizedBox(width: 4.0),
              const Text(
                "/hour",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        Expanded(
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(child: Container()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Consumer(builder: (context, watch, _) {
                    return ActionButton(
                      color: Colors.black,
                      label: "-",
                      textColor: data.villagers.isNotEmpty
                          ? Colors.black
                          : Colors.grey.shade600,
                      borderFunc: shadowBorder(
                          16,
                          16,
                          data.villagers.isNotEmpty
                              ? Colors.lightGreen
                              : Colors.grey.shade800),
                      onPressed: data.villagers.isNotEmpty
                          ? () => _removeVillager(
                              watch(selectedBuildingId.notifier).state, watch)
                          : () {},
                    );
                  }),
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${data.villagers.length} / ${data.maxVillager}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 16.0),
                    Image.asset(
                      "assets/images/items/villager.png",
                      height: 25,
                      width: 25,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Consumer(
                    builder: (context, watch, _) {
                      return ActionButton(
                        color: Colors.black,
                        label: "+",
                        textColor: (data.villagers.length < data.maxVillager)
                            ? Colors.black
                            : Colors.grey.shade600,
                        borderFunc: shadowBorder(
                            16,
                            16,
                            (data.villagers.length < data.maxVillager)
                                ? Colors.lightGreen
                                : Colors.grey.shade800),
                        onPressed: (data.villagers.length < data.maxVillager)
                            ? () => _addVillager(
                                watch(selectedBuildingId.notifier).state, watch)
                            : () {},
                      );
                    },
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ],
    );
  }

  _addVillager(String buildingId, watch) async {
    if (await BuildingService.addVillagerToBuilding(buildingId)) {
      watch(refreshProvider).state++;
    } else {
      //TODO
      print("erreur");
    }
  }

  _removeVillager(String buildingId, watch) async {
    if (await BuildingService.removeVillagerFromBuilding(buildingId)) {
      watch(refreshProvider).state++;
    } else {
      //TODO
      print("erreur");
    }
  }
}
