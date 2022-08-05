import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/providers.dart';
import 'package:front/sockets/socket_manager.dart';
import 'package:front/utils/sounds.dart';
import 'package:front/utils/spriteSheets/random_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/remote_player_sprite_sheet.dart';

/// Represents the other players.
class RemotePlayer extends SimplePlayer with Lighting {
  final String username;
  late TextPaint _textConfig;
  final watch;
  final double initialHp;
  RemotePlayer(
    Vector2 position,
    this.username,
    this.watch,
    this.initialHp,
  ) : super(
            animation: RemotePlayerSpriteSheet.playerAnimations(),
            position: position,
            width: 64 * 1.5,
            height: 64 * 1.5,
            life: 1000) {
    _textConfig = TextPaint(
      config: TextPaintConfig(
          color: Colors.blueAccent.shade400, fontSize: width / 6),
    );
    life = initialHp;
    setupLighting(
      LightingConfig(radius: 0, blurBorder: 0, color: Colors.transparent),
    );
  }

  @override
  void render(Canvas canvas) {
    _textConfig.render(
      canvas,
      username,
      Vector2(position.left + width / 4, position.top - 15),
    );
    drawDefaultLifeBar(
      canvas,
      width: width / 2,
      align: Offset(width / 4, -15),
      borderRadius: BorderRadius.circular(2),
    );
    super.render(canvas);
  }

  void attack() {
    Sounds.attackPlayerMelee();
    simpleAttackMelee(
      damage: 0,
      animationBottom: RemotePlayerSpriteSheet.attackEffectBottom(),
      animationLeft: RemotePlayerSpriteSheet.attackEffectLeft(),
      animationRight: RemotePlayerSpriteSheet.attackEffectRight(),
      animationTop: RemotePlayerSpriteSheet.attackEffectTop(),
      height: 32,
      width: 32,
      withPush: true,
    );
  }

  void updateLighting() {
    var isDay = watch(dayProvider.notifier).state;
    LightingConfig newConfig = (!isDay)
        ? LightingConfig(
            radius: width * 0.5,
            color: Colors.transparent,
            blurBorder: width * 0.5)
        : LightingConfig(
            radius: 0, color: Colors.orange.shade400, blurBorder: 0);
    setupLighting(newConfig);
  }

  @override
  void receiveDamage(double damage, dynamic id) {
    if (isDead) return;
    showDamage(
      damage,
      config: const TextPaintConfig(
        fontSize: 15,
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    SocketManager().emitPlayerReceivedDamage(username, damage);
    super.receiveDamage(damage, id);
  }

  @override
  void receiveDamage2(double damage, dynamic id) {
    if (isDead) return;
    showDamage(
      damage,
      config: const TextPaintConfig(
        fontSize: 15,
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(damage, id);
  }

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
}
