import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:flutter/material.dart';
import 'package:front/buildings/building.dart';

/// Represents the sign that holds all the quests of the player.
class Sign extends GameDecoration with ObjectCollision {
  Sign(Vector2 position)
      : super.withSprite(
          Sprite.load('objects/sign.png'),
          position: Vector2(position.x - 128 / 2, position.y - 100 / 2),
          width: 128,
          height: 100,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(width, height / 3),
            align: Vector2(0, height / 2),
          ),
        ],
      ),
    );
  }

  /// Adds a menu to the game.
  onInteract(Joystick joystick) async {
    // Joystick cpy = joystick;
    // joystick.shouldRemove = true;
    // gameRef.overlays.remove('hud');
    // gameRef.overlays.add('signMenu');
    // gameRef.overlays.add('hud');
    // var buildings = gameRef.componentsByType<Building>();
    // for (var building in buildings) {
    //   building.updateLighting();
    // }
    // gameRef.add(LightingComponent(color: Colors.black.withOpacity(0.8)));

    // gameRef.add(cpy);

    // gameRef.overlays.add('event');
    // gameRef.camera.moveToPositionAnimated(
    //   const Offset(1000, 1400),
    //   zoom: 0.8,
    //   duration: const Duration(seconds: 3),
    //   finish: () async {
    gameRef.camera.shake(duration: 60, intensity: 15);
    //     await Future.delayed(const Duration(seconds: 2));
    //     gameRef.camera.moveToPlayerAnimated(
    //       zoom: 0.8,
    //       finish: () {
    //         gameRef.overlays.remove('event');
    //         gameRef.add(cpy);
    //       },
    //     );
    //   },
    // );
  }
}
