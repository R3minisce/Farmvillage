import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';

class InventoryRow extends StatelessWidget {
  final String label;
  final int amount;
  final int requiredAmount;
  final bool repairMode;

  const InventoryRow({
    Key? key,
    required this.label,
    required this.amount,
    required this.requiredAmount,
    required this.repairMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = repairMode
        ? amount.toString()
        : amount.toString() + "/" + requiredAmount.toString();
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/images/items/$label.png",
              height: 25,
              width: 25,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
        if (amount < requiredAmount && !repairMode)
          Expanded(
            flex: 1,
            child: Consumer(
              builder: (context, watch, _) {
                return Container(
                  padding: const EdgeInsets.all(4.0),
                  child: ActionButton(
                    color: Colors.black,
                    label: "+",
                    textColor: Colors.black,
                    borderFunc: shadowBorder(16, 16, Colors.lightGreen),
                    onPressed: () async => _addResource(
                      watch(selectedBuildingId.notifier).state,
                      label,
                      watch,
                    ),
                  ),
                );
              },
            ),
          ),
        if (amount >= requiredAmount)
          Expanded(
            flex: 1,
            child: Container(),
          ),
      ],
    );
  }

  _addResource(String buildingId, String label, watch) async {
    if (await BuildingService.updateBuildingResources(buildingId, label, 100)) {
      watch(refreshProvider).state++;
    } else {
      //TODO show snackbar ?
    }
  }
}
