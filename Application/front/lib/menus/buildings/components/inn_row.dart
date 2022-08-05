import 'package:bonfire/enemy/simple_enemy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/building_file.dart';
import 'package:front/providers.dart';
import 'package:front/services/ai_service.dart';
import 'package:front/utils/custom_sprite_animation_widget.dart';
import 'package:front/utils/spriteSheets/biquette_sprite_sheet.dart';

class INNRow extends StatelessWidget {
  const INNRow({
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
          child: Container(),
        ),
        Expanded(
          flex: 8,
          child: Consumer(
            builder: (context, watch, _) {
              watch(refreshAlliesProvider).state;
              var data = watch(alliesProvider).state.isEmpty
                  ? Map<String, SimpleEnemy>.from(
                      watch(alliesRemoteProvider).state)
                  : Map<String, SimpleEnemy>.from(watch(alliesProvider).state);
              data.removeWhere(
                  (key, value) => value.isDead || value.life == value.maxLife);

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return AlliesItem(data: data, index: index, watch: watch);
                },
              );
            },
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}

class AlliesItem extends StatelessWidget {
  const AlliesItem({
    Key? key,
    required this.data,
    required this.index,
    this.watch,
  }) : super(key: key);

  final Map<String, SimpleEnemy> data;
  final int index;
  final watch;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      width: 100,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: shadowBorder(
                16,
                16,
                Colors.black.withOpacity(0.2),
              ),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: data.entries.elementAt(index).value.life.toInt(),
                    child: Container(
                      decoration: shadowBorder(
                        16,
                        16,
                        Colors.blue.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: data.entries.elementAt(index).value.maxLife.toInt() -
                        data.entries.elementAt(index).value.life.toInt(),
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 24.0,
              ),
              child: Center(
                child: CustomSpriteAnimationWidget(
                  animation: BiquetteSpriteSheet.runRight(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: ActionButton(
              color: Colors.black,
              label: "heal",
              textColor: Colors.white,
              borderFunc: shadowBorder(8, 8, Colors.lightGreen),
              onPressed: () async =>
                  _heal(data.entries.elementAt(index).key, watch),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${data.entries.elementAt(index).value.maxLife.toInt() - data.entries.elementAt(index).value.life.toInt()}",
                  ),
                  Image.asset(
                    "assets/images/items/gold.png",
                    height: 12,
                    width: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _heal(String uuid, watch) async {
    if (await AIService.healAlly(uuid)) {
      var allies = watch(alliesProvider).state.isEmpty
          ? Map<String, SimpleEnemy>.from(watch(alliesRemoteProvider).state)
          : Map<String, SimpleEnemy>.from(watch(alliesProvider).state);
      var trueAlly = allies[uuid];
      trueAlly!.life = trueAlly.maxLife;
      watch(refreshAlliesProvider.notifier).state++;
    } else {
      print("T'es pauvre !!");
    }
  }
}
