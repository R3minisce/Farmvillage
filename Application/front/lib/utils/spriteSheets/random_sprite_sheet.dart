import 'package:bonfire/bonfire.dart';

class RandomSpriteSheet {
  static Future<SpriteAnimation> smokeExplosion() => SpriteAnimation.load(
        'enemies/smoke_explosion.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );
}
