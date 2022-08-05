import 'package:front/models/event_type.dart';
import 'package:front/models/resource.dart';

abstract class IGameRef {
  void updateOtherPlayerPos(
      String username, int directionIndex, double x, double y);
  void createAI(String type, int nb);
  void createAIRemote(String type, num x, num y, String id);
  void updateAIPosition(
      String id, int directionIndex, num x, num y, String type);
  void animateAttack(String username);
  void animateAIAttack(String id, int directionIndex, String type);
  void damageAI(String id, num damage, String type);
  void spawnResource(String baseId, String productionType, num storage);
  void updateResources(
      List<Resource> newResources, List<Resource> newInventory);
  void stopBuff(String target);
  void updateWeather(String weather);
  void updateDay(bool day);
  void handleBuildingSpawn(String buildingId);
  void damageBuilding(String buildingId, double damage);
  void repairBuilding(String buildingId);
  void healAI(String id, double hp);
  void heal(String username, double hp);
  void handleEventNotification(EventType type, int level, double duration);
  void handleEventStart(EventType type, int level);
  void removePlayer(String username);
  void endGame();
  void addPlayer(String username, double hp);
  void takeDamage(String username, double damage);
}
