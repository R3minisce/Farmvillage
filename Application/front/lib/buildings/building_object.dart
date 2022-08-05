import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Helps to manage the interactivity with the buildings.
class BuildingObject extends GameDecoration with ObjectCollision {
  final String id;
  BuildingObject(Vector2 position, Size size, this.id)
      : super.withSprite(Sprite.load("objects/building_sign.png"),
            position: position, height: size.height, width: size.width) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Size(size.width, size.height * 0.6),
            align: Vector2(0, size.height * 0.4),
          ),
        ],
      ),
    );
  }

  /// Adds a menu to the game.
  onInteract() {
    gameRef.overlays.remove('hud');
    gameRef.overlays.add('buildingMenu');
  }
}
