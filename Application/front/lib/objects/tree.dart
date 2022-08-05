import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:flutter/material.dart';
import 'package:front/utils/spriteSheets/tree_sprite_sheet.dart';

/// Represents a tree in the game.
class Tree extends GameDecoration with ObjectCollision {
  Tree(Vector2 position)
      : super.withSprite(
          TreeSpriteSheet.getRandomTreeSprite(),
          position: Vector2(position.x - 140 / 2, position.y - 180 / 2),
          width: 140,
          height: 180,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: const Size(56, 56),
            align: Vector2(44, 80),
          ),
        ],
      ),
    );
  }
}

/// Represents a cutted tree in the game.
class TreeCut extends GameDecoration with ObjectCollision {
  TreeCut(Vector2 position)
      : super.withSprite(
          Sprite.load('objects/tree_cut.png'),
          position: Vector2(position.x, position.y),
          width: 50,
          height: 50,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: const Size(50, 30),
            align: Vector2(0, 10),
          ),
        ],
      ),
    );
  }
}
