import 'package:audioplayers/audioplayers.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// Lightweight sound player for UI feedback.
class SoundPlayer {
  static final _player = AudioPlayer();

  /// Plays a short confirmation "ching" sound.
  /// Falls back silently if audio file is missing.
  static Future<void> playConfirmation() async {
    try {
      // Use a short system sound if available, or asset
      await _player.play(AssetSource('sounds/confirmation_ching.mp3'));
    } catch (e) {
      AppLogger.warning('SoundPlayer.playConfirmation failed', error: e);
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
