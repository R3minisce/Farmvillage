import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:front/providers.dart';
import 'package:front/services/ai_service.dart';
import 'package:front/utils/custom_sprite_animation_widget.dart';
import 'package:front/utils/spriteSheets/npcs_sprite_sheet.dart';
import 'package:front/utils/spriteSheets/player_sprite_sheet.dart';

/// Represents a simple NPC.
class NPC extends GameDecoration with ObjectCollision, Lighting {
  final int id;
  final Size originalSize;
  bool mustBeVisible;
  final watch;

  NPC(
    Vector2 position,
    this.id,
    this.mustBeVisible,
    this.originalSize,
    this.watch,
  ) : super.withAnimation(
          NPCSpriteSheet.npcIdle(id - 1),
          position: position,
          width: mustBeVisible ? originalSize.width * 2 : 0,
          height: mustBeVisible ? originalSize.height * 2 : 0,
        ) {
    if (mustBeVisible) {
      setupCollision(
        CollisionConfig(
          collisions: [
            CollisionArea.rectangle(
              size: Size(originalSize.width / 2, originalSize.height / 2),
              align: Vector2(originalSize.width - originalSize.width / 4,
                  originalSize.height / 2),
            ),
          ],
        ),
      );
      setupLighting(
        LightingConfig(radius: 0, blurBorder: 0, color: Colors.transparent),
      );
    }
    var map = watch(npcsProvider.notifier).state as Map<int, NPC>;
    map[id] = this;
  }

  spawn() {
    height = originalSize.height * 2;
    width = originalSize.width * 2;
    setupCollision(CollisionConfig(
      collisions: [
        CollisionArea.rectangle(
          size: Size(originalSize.width / 2, originalSize.height / 2),
          align: Vector2(originalSize.width - originalSize.width / 4,
              originalSize.height / 2),
        ),
      ],
    ));
    updateLighting();
    mustBeVisible = true;
  }

  updateLighting() {
    var isDay = watch(dayProvider).state;
    LightingConfig newConfig = (!isDay)
        ? LightingConfig(
            radius: width * 0.75,
            color: Colors.transparent,
            blurBorder: width * 0.75)
        : LightingConfig(radius: 0, color: Colors.transparent, blurBorder: 0);
    setupLighting(newConfig);
  }

  /// Launches a dialog with the player.
  void discussWith() async {
    String? joke = await AIService.getDadJoke();
    if (joke != null) {
      TalkDialog.show(
        gameRef.context,
        [
          Say(
            text: [
              TextSpan(text: joke),
            ],
            person: CustomSpriteAnimationWidget(
              animation: NPCSpriteSheet.npcIdle(id - 1),
            ),
            personSayDirection: PersonSayDirection.RIGHT,
          ),
          Say(
            text: [const TextSpan(text: "*clap clap clap*")],
            person: CustomSpriteAnimationWidget(
              animation: PlayerSpriteSheet.idleRight(),
            ),
            personSayDirection: PersonSayDirection.LEFT,
          ),
        ],
        onChangeTalk: (index) {
          // possibiliy to add sound effects here
        },
      );
    }
  }
}
