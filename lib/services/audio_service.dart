import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  AudioService();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  // Flag temporária para desativar os sons (mantém apenas vibração)
  bool isSoundEnabled = false;

  Future<void> playBgm() async {
    if (!isSoundEnabled) return;
    try {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'), volume: 0.3);
    } catch (e) {
      // Ignora erro se o arquivo não existir
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      // Ignora erro
    }
  }

  Future<void> playClick() async {
    HapticFeedback.lightImpact();
    if (!isSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      // Ignora erro
    }
  }

  Future<void> playDrop() async {
    HapticFeedback.mediumImpact();
    if (!isSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/drop.mp3'));
    } catch (e) {
      // Ignora erro
    }
  }

  Future<void> playSuccess() async {
    HapticFeedback.heavyImpact();
    if (!isSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Ignora erro
    }
  }

  Future<void> playError() async {
    HapticFeedback.heavyImpact();
    if (!isSoundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      // Ignora erro
    }
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});
