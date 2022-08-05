import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:front/utils/spriteSheets/imp_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/random_sprite_sheet.dart';

/// Represents a simple enemy.
class ImpRemote extends SimpleEnemy with ObjectCollision {
  final Vector2 initPosition;
  final String uuid;
  double attack = 0;

  ImpRemote(this.initPosition, this.uuid)
      : super(
          animation: ImpSpriteSheet.impAnimations(),
          position: initPosition,
          width: 32 * 1,
          height: 32 * 1,
          speed: 64,
          life: 80,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(width * 0.6, height * 0.6),
            align: Vector2(width * 0.2, height * 0.4),
          ),
        ],
      ),
    );
  }

  toJSON() {
    return {
      "action": "spawn",
      "type": "enemy",
      "direction": 0,
      "position": {"x": position.position.x, "y": position.position.y},
      "id": uuid,
      "max_hp": maxLife,
      "hp": maxLife
    };
  }

  static ImpRemote fromJSON(data) {
    int x = data['position']['x'];
    int y = data['position']['y'];
    String id = data['id'];
    return ImpRemote(
      Vector2(x.toDouble(), y.toDouble()),
      id,
    );
  }

  /// Renders the imp with a life bar on top of its head.
  @override
  void render(Canvas canvas) {
    drawDefaultLifeBar(
      canvas,
      borderRadius: BorderRadius.circular(2),
    );
    super.render(canvas);
  }

  /// Executes an attack.
  ///
  /// Lot of parameters are supported.
  void execAttack(int directionIndex) {
    simpleAttackMelee(
      height: 32 * 0.62,
      width: 32 * 0.62,
      damage: attack,
      interval: 300,
      direction: Direction.values[directionIndex],
      animationBottom: ImpSpriteSheet.enemyAttackEffectBottom(),
      animationLeft: ImpSpriteSheet.enemyAttackEffectLeft(),
      animationRight: ImpSpriteSheet.enemyAttackEffectRight(),
      animationTop: ImpSpriteSheet.enemyAttackEffectTop(),
      execute: () {
        Sounds.attackEnemyMelee();
      },
    );
  }

  /// Called when the imp dies.
  ///
  /// Will generate a smoke explosion and then remove component of the game.
  @override
  void die() {
    gameRef.add(
      AnimatedObjectOnce(
        animation: RandomSpriteSheet.smokeExplosion(),
        position: position,
      ),
    );
    removeFromParent();
    super.die();
  }

  /// Called when the imp takes damage.
  ///
  /// Shows the damage on top of its head.
  @override
  void receiveDamage(double damage, dynamic id) {
    SocketManager().emitAIReceivedDamage(uuid, damage, "enemy");
    showDamage(
      damage,
      config: const TextPaintConfig(
        fontSize: 5,
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(damage, id);
  }

  void takeDamage(double damage, dynamic id, bool mustBeSend) {
    if (mustBeSend) SocketManager().emitAIReceivedDamage(uuid, damage, "enemy");
    showDamage(
      damage,
      config: const TextPaintConfig(
        fontSize: 5,
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(damage, id);
  }
}
