import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/allies/ally.dart';
import 'package:front/buildings/building.dart';
import 'package:front/players/remote_player.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:front/utils/spriteSheets/imp_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/random_sprite_sheet.dart';

/// Represents a simple enemy.
class Imp extends SimpleEnemy with ObjectCollision, AutomaticRandomMovement {
  final Vector2 initPosition;
  final String uuid;
  final double radius = 64;

  @override
  double life;
  double attack = 10;
  bool isPlayerClose = false;
  bool isRemotePlayerClose = false;
  bool isAllyClose = false;
  bool isBuildingClose = false;

  Imp(this.initPosition, this.uuid, {this.life = 80.0})
      : super(
          animation: ImpSpriteSheet.impAnimations(),
          position: initPosition,
          width: 32 * 1,
          height: 32 * 1,
          speed: 64,
          life: life,
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

  static Imp fromJSON(data) {
    int x = data['position']['x'];
    int y = data['position']['y'];
    String id = data['id'];
    int life = data['hp'];
    return Imp(Vector2(x.toDouble(), y.toDouble()), id, life: life.toDouble());
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

  /// Updates the imp.
  ///
  /// If the player is within the radius vision, will move towards it.
  /// If the player is close enough, will try to attack it.
  @override
  void update(double dt) {
    super.update(dt);
    SocketManager().emitAIPosition(lastDirection.index, position.position.x,
        position.position.y, uuid, "enemy");

    seePlayer(
      observed: (player) {
        isPlayerClose = true;
      },
      notObserved: () {
        isPlayerClose = false;
      },
      radiusVision: radius * 4,
    );
    seeComponentType<Building>(
      observed: (building) {
        isBuildingClose = true;
      },
      notObserved: () {
        isBuildingClose = false;
      },
      radiusVision: radius * 40,
    );
    seeComponentType<RemotePlayer>(
      observed: (remote) {
        isRemotePlayerClose = true;
      },
      notObserved: () {
        isRemotePlayerClose = false;
      },
      radiusVision: radius * 4,
    );
    seeComponentType<Ally>(
      observed: (ally) {
        isAllyClose = true;
      },
      notObserved: () {
        isAllyClose = false;
      },
      radiusVision: radius * 20,
    );

    // Player
    if (isPlayerClose) {
      seeAndMoveToPlayer(
          radiusVision: radius * 4,
          closePlayer: (player) {
            execAttack();
          },
          runOnlyVisibleInScreen: false);
    }

    // Remote player
    else if (isRemotePlayerClose) {
      seeAndMoveToRemotePlayer(
          radiusVision: radius * 4,
          closePlayer: (player) {
            execAttack2(player);
          },
          runOnlyVisibleInScreen: false);
    }

    // Ally
    else if (isAllyClose) {
      seeAndMoveToAlly(
          radiusVision: radius * 4,
          closeAlly: (ally) {
            execAttack2(ally);
          },
          runOnlyVisibleInScreen: false);
    }

    // Buildings
    else if (isBuildingClose) {
      seeAndMoveToBuilding(
          radiusVision: radius * 40,
          closeBuilding: (building) {
            execAttack2(building);
          },
          runOnlyVisibleInScreen: false);
    }

    // Idle
    else {
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
  void execAttack2(GameComponent target) {
    SocketManager().emitAIAttack(uuid, lastDirection.index, "enemy");
    simpleAttackMelee2(
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

  void simpleAttackMelee2({
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

    simpleAttackMeleeByDirection2(
        damage: damage,
        direction: direct,
        height: height,
        width: width,
        id: 5,
        animationTop: animationTop,
        animationBottom: animationBottom,
        animationLeft: animationLeft,
        animationRight: animationRight);

    execute?.call();
  }

  /// Executes an attack.
  ///
  /// Lot of parameters are supported.
  void execAttack() {
    SocketManager().emitAIAttack(uuid, lastDirection.index, "enemy");
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

  void seeAndMoveToBuilding({
    required Function(Building) closeBuilding,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = false,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seeBuilding(
      radiusVision: radiusVision,
      observed: (buildings) {
        var buildingsAlive = buildings.where((e) => !e.isDead).toList();
        if (buildingsAlive.isNotEmpty) {
          double min = double.maxFinite;
          var targetBuilding;
          for (var b in buildingsAlive) {
            if (b.position.position.distanceTo(position.position) < min) {
              min = b.position.position.distanceTo(position.position);
              targetBuilding = b;
            }
          }

          followComponent(
            targetBuilding,
            dtUpdate,
            closeComponent: (comp) => closeBuilding(comp as Building),
            margin: margin,
          );
        }
      },
      notObserved: () {
        if (!isIdle) {
          idle();
        }
      },
    );
  }

  void seeAndMoveToAlly({
    required Function(Ally) closeAlly,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = false,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seeAlly(
      radiusVision: radiusVision,
      observed: (allies) {
        double min = double.maxFinite;
        var targetAlly;
        for (var b in allies) {
          if (b.position.position.distanceTo(position.position) < min) {
            min = b.position.position.distanceTo(position.position);
            targetAlly = b;
          }
        }
        followComponent(
          targetAlly,
          dtUpdate,
          closeComponent: (comp) => closeAlly(comp as Ally),
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

  void seeAndMoveToRemotePlayer({
    required Function(RemotePlayer) closePlayer,
    double radiusVision = 32,
    double margin = 10,
    bool runOnlyVisibleInScreen = false,
  }) {
    if (isDead) return;
    if (runOnlyVisibleInScreen && !isVisible) return;

    seeRemotePlayer(
      radiusVision: radiusVision,
      observed: (players) {
        var player = players[0];
        followComponent(
          player,
          dtUpdate,
          closeComponent: (comp) => closePlayer(comp as RemotePlayer),
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

  void seeAlly({
    required Function(List<Ally>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    seeComponentType<Ally>(
      observed: (c) => observed(c),
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
  }

  void seeBuilding({
    required Function(List<Building>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    seeComponentType<Building>(
      observed: (c) => observed(c),
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
  }

  void seeRemotePlayer({
    required Function(List<RemotePlayer>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    seeComponentType<RemotePlayer>(
      observed: (c) => observed(c),
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
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

  void simpleAttackMeleeByDirection2({
    Future<SpriteAnimation>? animationRight,
    Future<SpriteAnimation>? animationBottom,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationTop,
    dynamic id,
    required double damage,
    required Direction direction,
    required double height,
    required double width,
    bool withPush = false,
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
      return (a.receivesAttackFromEnemy()) &&
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
