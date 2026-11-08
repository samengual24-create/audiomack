import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

// Reproductor único de la app: mantiene la canción actual
// mientras el usuario navega entre pantallas.
class PlayerService extends ChangeNotifier {
  PlayerService._();
  static final PlayerService instance = PlayerService._();

  final AudioPlayer player = AudioPlayer();

  String titulo = '';
  String artista = '';
  String portada = '';
  String audioUrl = '';

  bool get hayCancion => titulo.isNotEmpty;

  // Avisa a los widgets después de que termine la construcción actual
  void _avisar() {
    Future.microtask(notifyListeners);
  }

  // Devuelve false si la canción no tiene audio o no se pudo cargar
  Future<bool> reproducir({
    required String titulo,
    required String artista,
    required String portada,
    required String audioUrl,
  }) async {
    // Si es la misma canción que ya está cargada, no se vuelve a cargar
    if (hayCancion && this.titulo == titulo && this.artista == artista) {
      return true;
    }

    this.titulo = titulo;
    this.artista = artista;
    this.portada = portada;
    this.audioUrl = audioUrl;
    _avisar();

    if (audioUrl.isEmpty) {
      await player.stop();
      return false;
    }

    try {
      await player.setUrl(audioUrl);
      player.play();
      return true;
    } catch (_) {
      return false;
    }
  }
}