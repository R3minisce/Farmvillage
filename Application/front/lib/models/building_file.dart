import 'package:front/models/resource_type.dart';
import 'package:front/models/resource.dart';

class BuildingFile {
  final String baseId;
  final String label;
  final int level;
  final int storage;
  final int maxStorage;
  final int production;
  final List<Resource> upgradeResources;
  final List<dynamic> villagers;
  final int? productionRate;
  final bool isUpgradable;
  final int maxVillager;
  final ResourceType productionType;
  final List<Resource> storageResources;
  final List<Resource> repairResources;
  final bool isRepairable;
  final double hp;
  final double maxHp;

  BuildingFile(
      this.baseId,
      this.label,
      this.level,
      this.storage,
      this.maxStorage,
      this.production,
      this.upgradeResources,
      this.villagers,
      this.productionRate,
      this.isUpgradable,
      this.maxVillager,
      this.productionType,
      this.storageResources,
      this.repairResources,
      this.isRepairable,
      this.hp,
      this.maxHp);

  static BuildingFile fromJSON(data) {
    var upgradeResources = parseUpgradeResources(data['upgrade_resources']);
    var storageResources = parseUpgradeResources(data['storage_resources']);
    var repairResources = parseUpgradeResources(data['repair_cost']);
    num storage = data['storage'];
    num hp = data['hp'];
    num maxHp = data['max_hp'];
    num prodRate = data['production_rate'];
    return BuildingFile(
        data['base_id'],
        data['label'],
        data['level'],
        storage.floor(),
        data['max_storage'],
        data['production'],
        upgradeResources,
        data['villagers'],
        prodRate.toInt(),
        data['is_upgradable'],
        data['max_villager'],
        ResourceTypeParsing.fromString(data['production_type'])!,
        storageResources,
        repairResources,
        data['is_repairable'],
        hp.toDouble(),
        maxHp.toDouble());
  }

  static List<Resource> parseUpgradeResources(data) {
    List<Resource> res = [];
    for (var elem in data) {
      var label = elem['label'];
      res.add(Resource(ResourceTypeParsing.fromString(label)!, elem['quantity'],
          elem['max_quantity']));
    }
    return res;
  }
}
