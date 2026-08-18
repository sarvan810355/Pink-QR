import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// Gentle haptic + chime feedback for scan success — deliberately soft,
/// never the harsh system "beep-boop".
class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> scanSuccess() async {
    _softHaptic();
    try {
      await _player.play(AssetSource('sounds/chime.mp3'), volume: 0.6);
    } catch (_) {
      // Sound asset optional — fail silently if not bundled.
    }
  }

  Future<void> _softHaptic() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(duration: 40, amplitude: 60);
      }
    } catch (_) {
      // Haptics unsupported on this platform — ignore.
    }
  }

  Future<void> tap() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(duration: 15, amplitude: 40);
      }
    } catch (_) {}
  }
}
