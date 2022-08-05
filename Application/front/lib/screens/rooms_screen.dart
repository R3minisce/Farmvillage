import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:front/farmvillage_game.dart';
import 'package:front/main.dart';
import 'package:front/models/resource.dart';
import 'package:front/models/resource_type.dart';
import 'package:front/models/weather_type.dart';
import 'package:front/providers.dart';
import 'package:front/services/authentication_service.dart';
import 'package:front/services/inventory_service.dart';
import 'package:front/sockets/socket_manager.dart';

class RoomsScreen extends StatelessWidget {
  RoomsScreen({Key? key, required this.socketManager}) : super(key: key);

  final SocketManager socketManager;

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Consumer(
                      builder: (context, watch, child) {
                        var villageData = watch(villagesProvider).state;
                        return ListView.builder(
                          itemCount: villageData.length,
                          itemBuilder: (context, index) {
                            return VillageCard(
                              village: villageData[index],
                              index: index,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red.shade200,
                          child: IconButton(
                            color: Colors.black,
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.black,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              //padding: const EdgeInsets.all(8),
                              backgroundColor: Colors.lightGreen.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            onPressed: () => _openCodeDialog(context).then(
                              (value) async {
                                if (value != null) {
                                  // join the game
                                  var res =
                                      await AuthenticationService.joinFriend(
                                          value);
                                  if (res != null) {
                                    loadAndJoinVillage(res, context);
                                  } else {}
                                }
                              },
                            ),
                            child: const Text("Join your friend!"),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/other/map.png'),
                  alignment: Alignment.topLeft,
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  height: 100,
                  child: Center(
                    child: Text(
                      "FarmVillage",
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _openCodeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter your friend's username"),
          content: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Row(
              children: [
                SizedBox(
                  width: 350,
                  height: 50,
                  child: FormBuilderTextField(
                    name: "username",
                    validator: FormBuilderValidators.required(context),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.done, color: Colors.green),
                  onPressed: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      var username = _formKey.currentState!.value['username'];
                      Navigator.of(context).pop(username);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _logout(BuildContext context) async {
    var res = await AuthenticationService.logout();
    if (res) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }
}

class VillageCard extends StatelessWidget {
  final int index;
  final village;

  const VillageCard({
    Key? key,
    required this.village,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  village['status'] == 'destroyed'
                      ? "X"
                      : "${village['level']}",
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w900),
                ),
                backgroundColor: village['status'] == 'destroyed'
                    ? Colors.red
                    : village['principal']
                        ? Colors.blue
                        : Colors.grey,
              ),
              title: Text("${village['name']}"),
              subtitle: Text(
                village['principal']
                    ? "Your main village"
                    : village['status'] == 'destroyed'
                        ? "Destroyed"
                        : "External village",
              ),
            ),
          ),
          IconButton(
            onPressed: () => _joinGame(village['id'], context),
            icon: const Icon(
              Icons.done,
              color: Colors.lightGreen,
              size: 35,
            ),
          ),
          const SizedBox(width: 20)
        ],
      ),
    );
  }

  _joinGame(String villageId, BuildContext context) async {
    var res = await AuthenticationService.joinVillage(villageId);
    if (res != null) {
      loadAndJoinVillage(res, context);
    } else {
      // error
    }
  }
}

loadAndJoinVillage(dynamic data, BuildContext context) {
  var village = data['village'];
  var resources = data['resources'];
  var day = data['day'];
  var weather = data['weather'];
  var villageInventory = resources as List;
  var villageResources = villageInventory
      .map((e) => Resource(ResourceTypeParsing.fromString(e['label'])!,
          e['quantity'], e['max_quantity']))
      .toList();

  if (data['players'] != null) {
    var playersData = data['players'];
    Map<String, double> players = {};
    for (var p in playersData) {
      num hp = p['hp'];
      players[p['username']] = hp.toDouble();
    }
    context.read(initialPlayers.notifier).state = players;
  }

  context.read(villageResourcesProvider.notifier).state = villageResources;
  var dayString = day.toString();
  context.read(dayProvider.notifier).state = (dayString.toUpperCase() == "DAY");
  context.read(weatherProvider.notifier).state =
      WeatherTypeParsing.fromString(weather)!;
  context.read(selectedVillageProvider.notifier).state = village;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => FarmVillageGame(
        socketManager: SocketManager(),
        villageData: village,
      ),
    ),
  );
}
