import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/building_file.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';

class HQRow extends StatelessWidget {
  const HQRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${data.storage} / ${data.maxStorage}",
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
          flex: 3,
          child: Consumer(
            builder: (context, watch, _) {
              return Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  //decoration: shadowBorder(32, 32, color),
                  decoration: shadowBorder(16, 16,
                      data.hp != 0 ? Colors.lightGreen : Colors.grey.shade600),
                  width: double.infinity,
                  child: Material(
                    type: MaterialType.transparency,
                    elevation: 6.0,
                    color: Colors.transparent,
                    shadowColor: Colors.grey[50],
                    child: InkWell(
                      splashColor: const Color.fromARGB(100, 75, 150, 230)
                          .withOpacity(0.6),
                      onTap: data.hp != 0
                          ? () async => _addVillager(watch)
                          : () {},
                      child: Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text("enroll a villager"),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("200"),
                                  const SizedBox(width: 16.0),
                                  Image.asset(
                                    "assets/images/items/food.png",
                                    height: 25,
                                    width: 25,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }

  _addVillager(watch) async {
    var result = await BuildingService.buyVillager();
    if (result != null && result != false) {
      watch(refreshProvider).state++;
    }
  }
}
