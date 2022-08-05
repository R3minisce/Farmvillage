import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/models/building_file.dart';
import 'package:front/models/item.dart';
import 'package:front/models/item_type.dart';
import 'package:front/players/knight.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';
import 'package:front/services/integrations_service.dart';

class AlchemistRow extends StatelessWidget {
  const AlchemistRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      var isVeggie = watch(veggieMenuProvider).state;
      var logins = watch(loginsProvider).state;
      var isConnectedVeggieCrush = logins[AuthType.VeggieCrush];
      return Flex(
        direction: Axis.vertical,
        children: [
          if (!isVeggie)
            Expanded(
              flex: 16,
              child: Consumer(
                builder: (context, watch, _) {
                  final responseAsyncValue = watch(getPotionsProvider);
                  return responseAsyncValue.map(
                    data: (data) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          return PotionsItem(
                              data: data.value[index],
                              watch: watch,
                              isVeggie: isVeggie);
                        },
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
          if (isVeggie)
            Expanded(
              flex: 16,
              child: Consumer(
                builder: (context, watch, _) {
                  final responseAsyncValue = watch(getPotionsVeggieProvider);
                  return responseAsyncValue.map(
                    data: (data) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          return PotionsItem(
                              data: data.value[index],
                              watch: watch,
                              isVeggie: isVeggie);
                        },
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
          Expanded(flex: 2, child: Container()),
          Expanded(
            flex: 4,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  flex: 4,
                  child: InkWell(
                    child: Container(
                      decoration: shadowBorder(8, 8,
                          isVeggie ? Colors.lightGreen : Colors.grey.shade600),
                      child: const Center(
                        child: Text(
                          "shop",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: isVeggie
                        ? () =>
                            context.read(veggieMenuProvider.notifier).state =
                                !context.read(veggieMenuProvider.notifier).state
                        : () {},
                  ),
                ),
                Expanded(child: Container()),
                Expanded(
                  flex: 4,
                  child: InkWell(
                    child: Container(
                      decoration: shadowBorder(
                          8,
                          8,
                          isConnectedVeggieCrush!
                              ? !isVeggie
                                  ? Colors.blue
                                  : Colors.grey.shade600
                              : Colors.grey.shade600),
                      child: const Center(
                        child: Text(
                          "inventory",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: isConnectedVeggieCrush
                        ? !isVeggie
                            ? () => context
                                    .read(veggieMenuProvider.notifier)
                                    .state =
                                !context.read(veggieMenuProvider.notifier).state
                            : () {}
                        : () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class PotionsItem extends StatelessWidget {
  const PotionsItem({
    Key? key,
    required this.data,
    required this.isVeggie,
    this.watch,
  }) : super(key: key);

  final Item data;
  final bool isVeggie;
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
            flex: 5,
            child: Center(
              child: Text(
                data.label,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Image.asset(
                "assets/images/items/potion.png",
                height: 24,
                width: 24,
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              child: Container(
                decoration: shadowBorder(
                    8,
                    8,
                    !isVeggie
                        ? Colors.lightGreen
                        : (data.quantity! > 0)
                            ? Colors.blue
                            : Colors.grey.shade600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      !isVeggie
                          ? data.price.toString()
                          : data.quantity.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (!isVeggie) const SizedBox(width: 8.0),
                    if (!isVeggie)
                      Image.asset(
                        "assets/images/items/gold.png",
                        height: 12,
                        width: 12,
                      ),
                  ],
                ),
              ),
              onTap: () async => (!isVeggie || data.quantity! > 0)
                  ? _handlePotion(data.id, context, isVeggie)
                  : () {},
            ),
          ),
        ],
      ),
    );
  }

  _handlePotion(String potionId, BuildContext context, bool isVeggie) async {
    var result = !isVeggie
        ? await BuildingService.buyItem(potionId)
        : await IntegrationsService.usePotionsVeggieCrush(potionId);
    if (result != null && result != false) {
      Target target = TargetParsing.fromString(result['target'])!;
      var gameRef = context.read(gameRefProvider.notifier).state;
      switch (target) {
        case Target.health:
          var maxLife = gameRef!.player!.maxLife;
          gameRef.player!.addLife(maxLife * (result['ratio'] / 100));
          watch(hpProvider.notifier).state = gameRef.player!.life;
          break;
        case Target.damage:
          var knight = gameRef!.componentsByType<Knight>().first;
          knight.attackRatio = result['ratio'];
          break;
        case Target.speed:
          var knight = gameRef!.componentsByType<Knight>().first;
          knight.updateSpeed(result['ratio']);
          break;
        default:
          break;
      }
      context.read(refreshProvider.notifier).state++;
    } else {
      //TODO
      print("erreur");
    }
  }
}
