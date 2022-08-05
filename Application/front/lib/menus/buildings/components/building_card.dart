import 'package:flutter/material.dart';
import 'package:front/menus/buildings/components/villager_row.dart';
import 'package:front/menus/buildings/components/warehouse_row.dart';
import 'package:front/menus/buildings/components/bank_row.dart';
import 'package:front/menus/buildings/components/hq_row.dart';
import 'package:front/menus/buildings/components/inn_row.dart';
import 'package:front/menus/buildings/components/alchemist_row.dart';
import 'package:front/models/building_file.dart';

class BuildingCard extends StatelessWidget {
  const BuildingCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.start,
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 2,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(),
                    child: Center(
                      child: Image.asset(
                          "assets/images/tile/buildings/${data.baseId.toLowerCase()}.png"),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Flex(
                      direction: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.label.toLowerCase(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              "lvl ${data.level}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Text("${data.storage} / ${data.maxStorage}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (data.level >= 1)
            Expanded(
              flex: 3,
              child: Container(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                  child: _getCorrectChild()),
            ),
          if (data.level == 0)
            Expanded(
              flex: 3,
              child: Container(),
            ),
        ],
      ),
    );
  }

  Widget _getCorrectChild() {
    switch (data.label) {
      case "WAREHOUSE":
        return WareHouseRow(data: data);
      case "INN":
        return INNRow(data: data);
      case "HQ":
        return HQRow(data: data);
      case "BANK":
        return BankRow(data: data);
      case "ALCHEMIST HUT":
        return AlchemistRow(data: data);
      default:
        return VillagerRow(data: data);
    }
  }
}
