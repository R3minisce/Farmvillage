import 'package:bonfire/bonfire.dart';

class NPCSpriteSheet {
  static Future<SpriteAnimation> npcIdle(int index) => SpriteAnimation.load(
        'npcs/pnjs_idle.png',
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 0.5,
          textureSize: Vector2(56 * 2, 64 * 2),
          texturePosition: Vector2(0, 64.0 * 2 * index),
        ),
      );
}
