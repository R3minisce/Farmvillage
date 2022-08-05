import 'package:bonfire/bonfire.dart';

class WizardSpriteSheet {
  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
        'npcs/wizard/wizard_idle_left.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(16, 22),
        ),
      );
}
