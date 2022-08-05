import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class Sounds {
  static Future initialize() async {
    if (!kIsWeb) {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll([
        'sfx/attack_enemy.mp3',
      ]);
    }
  }

  static stopBackgroundSound() {
    if (kIsWeb) return;
    return FlameAudio.bgm.stop();
  }

  static void playBackgroundSound() async {
    if (kIsWeb) return;
    await FlameAudio.bgm.stop();
    FlameAudio.bgm.play('music/bm.mp3');
  }

  static void pauseBackgroundSound() {
    if (kIsWeb) return;
    FlameAudio.bgm.pause();
  }

  static void resumeBackgroundSound() {
    if (kIsWeb) return;
    FlameAudio.bgm.resume();
  }

  static void dispose() {
    if (kIsWeb) return;
    FlameAudio.bgm.dispose();
  }

  static void attackEnemyMelee() {
    if (kIsWeb) return;
    FlameAudio.play('sfx/attack_enemy.mp3', volume: 0.4);
  }

  static void attackPlayerMelee() {
    if (kIsWeb) return;
    FlameAudio.play('sfx/attack_player.mp3', volume: 0.4);
  }
}
