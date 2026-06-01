import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  
  AudioManager._internal() {
    AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));
  }

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isSoundEffectsEnabled = true;
  bool _isBgmEnabled = true;

  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;
  bool get isBgmEnabled => _isBgmEnabled;

  void toggleSoundEffects() {
    _isSoundEffectsEnabled = !_isSoundEffectsEnabled;
  }

  void toggleBgm() {
    _isBgmEnabled = !_isBgmEnabled;
    if (!_isBgmEnabled) {
      stopBgm();
    } else {
      playGameplayBgm();
    }
  }

  /// Click/Tap sound effect (one-shot)
  Future<void> playClick() async {
    if (_isBgmEnabled && !_isBgmPlaying) {
      playGameplayBgm();
    }
    if (!_isSoundEffectsEnabled) return;
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('audio/click.mp3'));
    } catch (e) {
      print("Error playing click sound: $e");
    }
  }

  /// Correct answer sound effect
  Future<void> playCorrect() async {
    if (!_isSoundEffectsEnabled) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      print("Error playing correct sound: $e");
    }
  }

  /// Wrong answer sound effect
  Future<void> playWrong() async {
    if (!_isSoundEffectsEnabled) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/wrong.mp3'));
    } catch (e) {
      print("Error playing wrong sound: $e");
    }
  }

  bool _isBgmPlaying = false;

  /// Gameplay Background Music (Loops indefinitely)
  Future<void> playGameplayBgm() async {
    if (!_isBgmEnabled) return;
    if (_isBgmPlaying) return;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setSource(AssetSource('audio/play_music.mp3'));
      await _bgmPlayer.resume();
      _isBgmPlaying = true;
    } catch (e) {
      print("Error playing gameplay music: $e");
    }
  }

  /// Game Over sound (one-shot effect, played on top of background music)
  Future<void> playGameOverMusic() async {
    if (!_isSoundEffectsEnabled) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/gameover.mp3'));
    } catch (e) {
      print("Error playing game over sound: $e");
    }
  }

  /// Clapping sound effect
  Future<void> playClapping() async {
    if (!_isSoundEffectsEnabled) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/claps.mp3'));
    } catch (e) {
      print("Error playing clapping sound: $e");
    }
  }

  /// Stops any playing music
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _isBgmPlaying = false;
    } catch (e) {
      print("Error stopping music: $e");
    }
  }
}
