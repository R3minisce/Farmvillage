import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:front/utils/spriteSheets/biquette_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/imp_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/random_sprite_sheet.dart';

/// Represents a simple ally (remote).
class AllyRemote extends SimpleEnemy with ObjectCollision {
  final Vector2 initPosition;
  final String uuid;
  double attack = 20;

  AllyRemote(this.initPosition, this.uuid)
      : super(
          animation: BiquetteSpriteSheet.biquetteAnimations(),
          position: initPosition,
          width: 32 * 2,
          height: 32 * 2,
          speed: 32,
          life: 160,
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
      "type": "ally",
      "direction": 0,
      "position": {"x": position.position.x, "y": position.position.y},
      "id": uuid,
      "max_hp": maxLife,
      "hp": maxLife
    };
  }

  /// Renders the ally with a life bar on top of its head.
  @override
  void render(Canvas canvas) {
    drawDefaultLifeBar(
      canvas,
      colorsLife: [Colors.blue],
      borderRadius: BorderRadius.circular(2),
    );
    super.render(canvas);
  }

  /// Updates the ally.
  @override
  void update(double dt) {
    super.update(dt);
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

  /// Called when the ally dies.
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

  /// Called when the ally takes damage.
  ///
  /// Shows the damage on top of its head.
  @override
  void receiveDamage(double damage, dynamic id) {
    SocketManager().emitAIReceivedDamage(uuid, damage, "ally");
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

  void takeDamage(double damage, dynamic id, bool mustBeSent) {
    if (mustBeSent) SocketManager().emitAIReceivedDamage(uuid, damage, "ally");
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
