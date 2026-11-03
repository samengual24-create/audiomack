import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../theme/theme.dart';

class PlayerScreen extends StatefulWidget {
  final String titulo;
  final String artista;
  final String portada;
  final String audioUrl;

  const PlayerScreen({
    super.key,
    required this.titulo,
    required this.artista,
    required this.portada,
    required this.audioUrl,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final player = AudioPlayer();
  bool favorito = false;

  @override
  void initState() {
    super.initState();
    _cargarAudio();
  }

  Future<void> _cargarAudio() async {
    try {
      await player.setUrl(widget.audioUrl);
      player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el audio: $e')),
      );
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius16),
              child: Image.network(
                widget.portada,
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 280,
                  height: 280,
                  color: AppColors.neutral900,
                  child: const Icon(Icons.music_note, size: 64),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.titulo, style: text.headlineLarge),
                      Text(widget.artista, style: text.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    favorito ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () {
                    setState(() => favorito = !favorito);
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacing24),

            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final posicion = snapshot.data ?? Duration.zero;
                final duracion = player.duration ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      value: posicion.inSeconds.toDouble().clamp(
                            0,
                            duracion.inSeconds.toDouble(),
                          ),
                      max: duracion.inSeconds.toDouble() == 0
                          ? 1
                          : duracion.inSeconds.toDouble(),
                      onChanged: (value) {
                        player.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatear(posicion)),
                        Text(_formatear(duracion)),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.spacing16),

            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final estaSonando = snapshot.data?.playing ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fast_rewind),
                      iconSize: 36,
                      onPressed: () {
                        player.seek(
                          player.position - const Duration(seconds: 10),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.spacing16),
                    IconButton.filled(
                      icon: Icon(estaSonando ? Icons.pause : Icons.play_arrow),
                      iconSize: 36,
                      onPressed: () {
                        estaSonando ? player.pause() : player.play();
                      },
                    ),
                    const SizedBox(width: AppSpacing.spacing16),
                    IconButton(
                      icon: const Icon(Icons.fast_forward),
                      iconSize: 36,
                      onPressed: () {
                        player.seek(
                          player.position + const Duration(seconds: 10),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatear(Duration d) {
    final minutos = d.inMinutes.toString().padLeft(1, '0');
    final segundos = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }
}