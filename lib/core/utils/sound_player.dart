import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// Lightweight sound player for UI feedback.
class SoundPlayer {
  static final _player = AudioPlayer();

  static const _confirmationAsset = 'assets/sounds/confirmation_ching.mp3';

  /// Plays a short confirmation "ching" sound.
  ///
  /// Falls back silently when the asset is not bundled. The pre-check via
  /// [rootBundle.load] matters because audioplayers surfaces a missing asset
  /// as an unhandled platform error AFTER play() returns, which escapes this
  /// try/catch and crashes the flow that triggered the sound (seen on device
  /// E2E: PromptPay confirm + barcode scan success).
  static Future<void> playConfirmation() async {
    try {
      await rootBundle.load(_confirmationAsset);
    } catch (_) {
      // Asset not bundled (or not declared in pubspec) — stay silent.
      return;
    }
    try {
      await _player.play(AssetSource('sounds/confirmation_ching.mp3'));
    } catch (e) {
      AppLogger.warning('SoundPlayer.playConfirmation failed', error: e);
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
