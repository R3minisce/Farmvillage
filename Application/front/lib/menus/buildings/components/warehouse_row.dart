import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/components/action_button.dart';
import 'package:front/components/shadow_border.dart';
import 'package:front/models/auth_type.dart';
import 'package:front/models/building_file.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/models/resource.dart';
import 'package:front/providers.dart';
import 'package:front/services/building_service.dart';
import 'package:front/services/integrations_service.dart';
import 'package:front/services/inventory_service.dart';
import 'package:front/sockets/socket_manager.dart';

class WareHouseRow extends StatelessWidget {
  const WareHouseRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      var isBoomCraft = watch(boomCraftMenuProvider).state;
      var logins = watch(loginsProvider).state;
      var isConnectedBoomCraft = logins[AuthType.BoomCraft];
      return Flex(
        direction: Axis.vertical,
        children: [
          (data.level > 0)
              ? Expanded(
                  flex: 8,
                  child: (!isBoomCraft)
                      ? Row(
                          children: [
                            WareHouseItem(
                                resourceType: ResourceType.food, data: data),
                            WareHouseItem(
                                resourceType: ResourceType.wood, data: data),
                            WareHouseItem(
                                resourceType: ResourceType.stone, data: data),
                            WareHouseItem(
                                resourceType: ResourceType.iron, data: data),
                          ],
                        )
                      : Row(
                          children: [
                            WareHouseSenderItem(
                                resourceType: ResourceType.food, data: data),
                            WareHouseSenderItem(
                                resourceType: ResourceType.wood, data: data),
                            WareHouseSenderItem(
                                resourceType: ResourceType.stone, data: data),
                            WareHouseSenderItem(
                                resourceType: ResourceType.iron, data: data),
                          ],
                        ))
              : Expanded(flex: 8, child: Container()),
          if (data.level > 0) Expanded(flex: 1, child: Container()),
          if (data.level > 0)
            Expanded(
              flex: 2,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      child: Container(
                        decoration: shadowBorder(
                            8,
                            8,
                            isBoomCraft
                                ? Colors.lightGreen
                                : Colors.grey.shade600),
                        child: const Center(
                          child: Text(
                            "storage",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: isBoomCraft
                          ? () => context
                                  .read(boomCraftMenuProvider.notifier)
                                  .state =
                              !context
                                  .read(boomCraftMenuProvider.notifier)
                                  .state
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
                            isConnectedBoomCraft!
                                ? !isBoomCraft
                                    ? Colors.blue
                                    : Colors.grey.shade600
                                : Colors.grey.shade600),
                        child: const Center(
                          child: Text(
                            "trade",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: isConnectedBoomCraft
                          ? !isBoomCraft
                              ? () => context
                                      .read(boomCraftMenuProvider.notifier)
                                      .state =
                                  !context
                                      .read(boomCraftMenuProvider.notifier)
                                      .state
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

class WareHouseItem extends StatelessWidget {
  const WareHouseItem({
    Key? key,
    required this.resourceType,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;
  final ResourceType resourceType;

  @override
  Widget build(BuildContext context) {
    int index = data.storageResources
        .indexWhere((element) => element.label == resourceType);
    return Consumer(
      builder: (context, watch, _) {
        var resources = watch(inventoryProvider).state;
        var index2 =
            resources.indexWhere((element) => element.label == resourceType);
        return Container(
          margin: const EdgeInsets.only(right: 8.0),
          width: 75,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    index != -1
                        ? data.storageResources[index].quantity.toString()
                        : "0",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Image.asset(
                    "assets/images/items/${resourceType.toShortString()}.png",
                    height: 20,
                    width: 20,
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
                  label: "add",
                  textColor: Colors.white,
                  borderFunc: shadowBorder(
                      8,
                      8,
                      index2 != -1 && resources[index2].quantity != 0
                          ? Colors.lightGreen
                          : Colors.grey.shade600),
                  onPressed: index2 != -1 && resources[index2].quantity != 0
                      ? () async => _manageResources(resourceType, 100, watch)
                      : () {},
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 2,
                child: ActionButton(
                  color: Colors.black,
                  label: "remove",
                  textColor: Colors.white,
                  borderFunc: shadowBorder(
                      8,
                      8,
                      index != -1 && data.storageResources[index].quantity != 0
                          ? Colors.redAccent
                          : Colors.grey.shade600),
                  onPressed: index != -1 &&
                          data.storageResources[index].quantity != 0
                      ? () async => _manageResources(resourceType, -100, watch)
                      : () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _manageResources(ResourceType resourceType, int quantity, watch) async {
    if (await BuildingService.handleBuildingResources(
      watch(selectedBuildingId.notifier).state,
      resourceType.toShortString(),
      quantity,
    )) {
      SocketManager().emitUpdateVillageResources();
      watch(refreshProvider).state++;
    } else {
      print("error");
    }
  }
}

class WareHouseSenderItem extends StatelessWidget {
  const WareHouseSenderItem({
    Key? key,
    required this.resourceType,
    required this.data,
  }) : super(key: key);

  final BuildingFile data;
  final ResourceType resourceType;

  @override
  Widget build(BuildContext context) {
    int index = data.storageResources
        .indexWhere((element) => element.label == resourceType);
    return Consumer(
      builder: (context, watch, _) {
        return Container(
          margin: const EdgeInsets.only(right: 8.0),
          width: 75,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    index != -1
                        ? data.storageResources[index].quantity.toString()
                        : "0",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Image.asset(
                    "assets/images/items/${resourceType.toShortString()}.png",
                    height: 20,
                    width: 20,
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
                  label: "send",
                  textColor: Colors.white,
                  borderFunc: shadowBorder(
                      8,
                      8,
                      index != -1 && data.storageResources[index].quantity != 0
                          ? Colors.blue.shade800
                          : Colors.grey.shade600),
                  onPressed: index != -1 &&
                          data.storageResources[index].quantity != 0
                      ? () async => _manageResources(resourceType, 100, watch)
                      : () {},
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(),
              ),
            ],
          ),
        );
      },
    );
  }

  _manageResources(ResourceType resourceType, int quantity, watch) async {
    if (await IntegrationsService.sendResourcesBoomCraft(
        resourceType.toShortString(), quantity)) {
      watch(refreshProvider).state++;
    } else {
      print("error");
    }
  }
}
