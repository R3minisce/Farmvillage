import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/buildings/building.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/buttons.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/menus/buildings/components/inventory_row.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/models/building_file.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';
import 'package:front/services/integrations_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildingActions extends StatelessWidget {
  const BuildingActions({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(flex: 2, child: Container()),
          Upgrade(data: data),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}

class Upgrade extends StatelessWidget {
  const Upgrade({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: !data.isRepairable
                  ? _buildUpgradeResources()
                  : _buildRepairResources(),
            ),
          ),
          Expanded(child: Container()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Consumer(builder: (context, watch, _) {
                return ActionButton(
                  color: Colors.black,
                  label: !data.isRepairable ? "upgrade" : "repair",
                  textColor:
                      data.isUpgradable ? Colors.black : Colors.grey.shade600,
                  borderFunc: shadowBorder(
                      16,
                      16,
                      !data.isRepairable
                          ? data.isUpgradable
                              ? Colors.lightGreen
                              : Colors.grey.shade800
                          : data.isRepairable
                              ? Colors.lightGreen
                              : Colors.grey.shade800),
                  onPressed: !data.isRepairable
                      ? data.isUpgradable
                          ? () => _upgradeBuilding(
                              watch(selectedBuildingId.notifier).state,
                              watch,
                              data,
                              context)
                          : () {}
                      : data.isRepairable
                          ? () => _repairBuilding(
                              watch(selectedBuildingId.notifier).state,
                              watch,
                              data)
                          : () {},
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  _upgradeBuilding(
      String buildingId, watch, BuildingFile data, BuildContext context) async {
    if (await BuildingService.upgradeBuilding(buildingId)) {
      watch(refreshProvider).state++;
      if (data.level == 0) {
        Map<String, Building> buildings = watch(buildingsProvider).state;
        buildings[buildingId]!.build();
        int id = int.parse(buildingId.substring(2));
        var npcs = watch(npcsProvider).state;
        npcs[id]!.spawn();
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<AuthType, bool> logins = watch(loginsProvider.notifier).state;
      if (logins[AuthType.Twitter] == true) {
        _tweet(context);
      }
    } else {
      //TODO
      print("erreur");
    }
  }

  List<Widget> _buildUpgradeResources() {
    return List.generate(
      data.upgradeResources.length,
      (index) {
        var upgradeResource = data.upgradeResources[index];
        if (upgradeResource.maxQuantity != 0) {
          return Expanded(
            child: InventoryRow(
              label: upgradeResource.label.toShortString(),
              amount: upgradeResource.quantity,
              requiredAmount: upgradeResource.maxQuantity.toInt(),
              repairMode: data.isRepairable,
            ),
          );
        } else {
          return Expanded(child: Container(color: Colors.transparent));
        }
      },
    );
  }

  void _tweet(BuildContext context) {
    Widget cancelButton = const CancelButton();
    Widget continueButton = const ContinueButton();

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Tweet request"),
      content: const Text("Do you want to tweet this event?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    Future confirmation = showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    confirmation.then((value) async {
      if (value != null && value) {
        IntegrationsService.tweet(
            "My ${data.label} is now level ${data.level + 1} in FarmVillage Mobile Game <3 !!");
      }
    });
  }

  _repairBuilding(String buildingId, watch, BuildingFile data) async {
    if (await BuildingService.repairBuilding(buildingId)) {
      watch(refreshProvider).state++;
    } else {
      //TODO
      print("erreur");
    }
  }

  List<Widget> _buildRepairResources() {
    return List.generate(
      data.repairResources.length,
      (index) {
        var repairResources = data.repairResources[index];
        if (repairResources.maxQuantity != 0) {
          return Expanded(
            child: InventoryRow(
              label: repairResources.label.toShortString(),
              amount: repairResources.quantity,
              requiredAmount: repairResources.maxQuantity.toInt(),
              repairMode: data.isRepairable,
            ),
          );
        } else {
          return Expanded(child: Container(color: Colors.transparent));
        }
      },
    );
  }
}
