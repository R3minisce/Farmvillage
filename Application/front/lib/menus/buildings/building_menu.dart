import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/buildings/building.dart';
import 'package:front/components/icon_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/menus/buildings/components/building_actions.dart';
import 'package:front/menus/buildings/components/building_card.dart';
import 'package:front/models/building_file.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';

/// Menu opened when interacting with a building.
class BuildingMenu extends StatelessWidget {
  const BuildingMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: shadowBorder(32, 32, Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        margin: const EdgeInsets.all(32.0),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                color: Colors.white,
                child: Consumer(
                  builder: (context, watch, _) {
                    var callBack = watch(menuCallbackProvider.notifier).state;
                    return IconActionButton(
                      color: Colors.black,
                      icon: Icons.close,
                      iconColor: Colors.red,
                      borderFunc: const BoxDecoration(),
                      onTap: callBack,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 15,
              child: Consumer(
                builder: (context, watch, _) {
                  final responseAsyncValue = watch(getInfosBuildingProvider);
                  return responseAsyncValue.map(
                    data: (data) {
                      var buildingData = BuildingFile.fromJSON(data.value);
                      _updateBuildingLife(buildingData, watch);
                      return Flex(
                        direction: Axis.horizontal,
                        children: [
                          BuildingCard(data: buildingData),
                          BuildingActions(data: buildingData),
                        ],
                      );
                    },
                    loading: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_) => const Center(
                      child: Text("An error occurred. Please try again later."),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateBuildingLife(BuildingFile buildingFile, watch) {
    var buildings =
        watch(buildingsProvider.notifier).state as Map<String, Building>;
    buildings[buildingFile.baseId]!
        .updateLife(buildingFile.hp, buildingFile.maxHp);
  }
}
