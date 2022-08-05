import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/enemies/imp.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:front/utils/spriteSheets/biquette_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/imp_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/random_sprite_sheet.dart';

/// Represents a simple ally.
class Ally extends SimpleEnemy with ObjectCollision, AutomaticRandomMovement {
  final Vector2 initPosition;
  final String uuid;
  final double radius = 64;
  double attack = 20;
  bool isImpClose = true;

  Ally(this.initPosition, this.uuid)
      : super(
          animation: BiquetteSpriteSheet.biquetteAnimations(),
          position: initPosition,
          width: 32 * 2,
          height: 32 * 2,
          speed: 32,
          life: 160,
        ) {
    receivesAttackFrom = ReceivesAttackFromEnum.ENEMY;
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
  ///
  /// If an imp is within the radius vision, will move towards it.
  /// If an imp is close enough, will try to attack it.
  @override
  void update(double dt) {
    super.update(dt);
    SocketManager().emitAIPosition(lastDirection.index, position.position.x,
        position.position.y, uuid, "ally");

    seeComponentType<Imp>(
      observed: (imp) {
        isImpClose = true;
      },
      notObserved: () {
        isImpClose = false;
      },
      radiusVision: radius * 25,
    );

    if (isImpClose) {
      seeAndMoveToImp(
          radiusVision: radius * 25,
          closeImp: (imp) {
            execAttack(imp);
          },
          runOnlyVisibleInScreen: false);
    }

    if (!isImpClose) {
      runRandomMovement(
        dt,
        speed: speed,
        maxDistance: 250,
      );
    }
  }

  /// Executes an attack.
  ///
  /// Lot of parameters are supported.
  void execAttack(GameComponent target) {
    simpleAttackMelee(
      height: 32 * 0.62,
      width: 32 * 0.62,
      damage: attack,
      interval: 300,
      animationBottom: ImpSpriteSheet.enemyAttackEffectBottom(),
      animationLeft: ImpSpriteSheet.enemyAttackEffectLeft(),
      animationRight: ImpSpriteSheet.enemyAttackEffectRight(),
      animationTop: ImpSpriteSheet.enemyAttackEffectTop(),
      execute: () {
        Sounds.attackEnemyMelee();
      },
      target: target,
    );
  }

  void simpleAttackMelee({
    required double damage,
    required double height,
    required double width,
    int interval = 1000,
    Future<SpriteAnimation>? animationRight,
    Future<SpriteAnimation>? animationBottom,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationTop,
    VoidCallback? execute,
    required GameComponent target,
  }) {
    if (!checkInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead) return;

    Direction direct = getComponentDirectionFromMe(target);

    simpleAttackMeleeByDirection(
      damage: damage,
      direction: direct,
      height: height,
      width: width,
      animationTop: animationTop,
      animationBottom: animationBottom,
      animationLeft: animationLeft,
      animationRight: animationRight,
    );

    execute?.call();
  }

  void seeAndMoveToImp({
    required Function(Imp) closeImp,
    double radiusVision = 64,
    double margin = 10,
    bool runOnlyVisibleInScreen = false,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seeImp(
      radiusVision: radiusVision,
      observed: (enemies) {
        var enemy = enemies[0];
        followComponent(
          enemy,
          dtUpdate,
          closeComponent: (comp) => closeImp(comp as Imp),
          margin: margin,
        );
      },
      notObserved: () {
        if (!isIdle) {
          idle();
        }
      },
    );
  }

  void seeImp({
    required Function(List<Imp>) observed,
    VoidCallback? notObserved,
    double radiusVision = 64,
  }) {
    seeComponentType<Imp>(
      observed: (c) => observed(c),
      notObserved: notObserved,
      radiusVision: radiusVision,
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

  void takeDamage(double damage, dynamic id, bool mustBeSend) {
    if (mustBeSend) SocketManager().emitAIReceivedDamage(uuid, damage, "ally");
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

  void simpleAttackMeleeByDirection({
    Future<SpriteAnimation>? animationRight,
    Future<SpriteAnimation>? animationBottom,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationTop,
    dynamic id,
    required double damage,
    required Direction direction,
    required double height,
    required double width,
    bool withPush = true,
    double? sizePush,
  }) {
    Rect positionAttack;
    Future<SpriteAnimation>? anim;
    double pushLeft = 0;
    double pushTop = 0;
    Direction attackDirection = direction;

    Vector2Rect rectBase =
        (isObjectCollision()) ? (this).rectCollision : position;

    switch (attackDirection) {
      case Direction.up:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.center.dx - width / 2,
          rectBase.rect.top - height,
          width,
          height,
        );
        if (animationTop != null) anim = animationTop;
        pushTop = (sizePush ?? height) * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.right,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
      case Direction.down:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.center.dx - width / 2,
          rectBase.rect.bottom,
          width,
          height,
        );
        if (animationBottom != null) anim = animationBottom;
        pushTop = (sizePush ?? height);
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.left - width,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.upLeft:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.left - width,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.upRight:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.right,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
      case Direction.downLeft:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.left - width,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationLeft != null) anim = animationLeft;
        pushLeft = (sizePush ?? width) * -1;
        break;
      case Direction.downRight:
        positionAttack = Rect.fromLTWH(
          rectBase.rect.right,
          rectBase.rect.center.dy - height / 2,
          width,
          height,
        );
        if (animationRight != null) anim = animationRight;
        pushLeft = (sizePush ?? width);
        break;
    }

    if (anim != null) {
      gameRef.add(AnimatedObjectOnce(
        animation: anim,
        position: positionAttack.toVector2Rect(),
      ));
    }

    gameRef.visibleAttackables().where((a) {
      return (this is Ally
              ? a.receivesAttackFromPlayer()
              : a.receivesAttackFromEnemy()) &&
          a.rectAttackable().rect.overlaps(positionAttack);
    }).forEach(
      (enemy) {
        enemy.receiveDamage(damage, id);
        final rectAfterPush =
            enemy.position.position.translate(pushLeft, pushTop);
        if (withPush &&
            (enemy is ObjectCollision &&
                !(enemy as ObjectCollision)
                    .isCollision(displacement: rectAfterPush))) {
          enemy.translate(pushLeft, pushTop);
        }
      },
    );
  }
}
