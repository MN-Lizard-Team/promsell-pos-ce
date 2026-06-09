import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound player for UI feedback.
class SoundPlayer {
  static final _player = AudioPlayer();

  /// Plays a short confirmation "ching" sound.
  /// Falls back silently if audio file is missing.
  static Future<void> playConfirmation() async {
    try {
      // Use a short system sound if available, or asset
      await _player.play(AssetSource('sounds/confirmation_ching.mp3'));
    } catch (_) {
      // Silently fail if sound asset not available
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
