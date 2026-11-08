import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';

import '../services/player_service.dart';
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
  final servicio = PlayerService.instance;
  late final DocumentReference favRef;

  AudioPlayer get player => servicio.player;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = '${widget.titulo}|${widget.artista}'.replaceAll('/', '-');

    favRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .doc(id);

    _cargarAudio();
  }

  Future<void> _cargarAudio() async {
    final ok = await servicio.reproducir(
      titulo: widget.titulo,
      artista: widget.artista,
      portada: widget.portada,
      audioUrl: widget.audioUrl,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el audio')),
      );
    }
  }

  Future<void> _alternarFavorito(bool esFavorito) async {
    if (esFavorito) {
      await favRef.delete();
    } else {
      await favRef.set({
        'titulo': widget.titulo,
        'artista': widget.artista,
        'portada': widget.portada,
        'audioUrl': widget.audioUrl,
      });
    }
  }

  void _mover(Duration posicion, int segundos) {
    final duracion = player.duration ?? Duration.zero;
    final nueva = posicion + Duration(seconds: segundos);

    if (nueva < Duration.zero) {
      player.seek(Duration.zero);
    } else if (nueva > duracion) {
      player.seek(duracion);
    } else {
      player.seek(nueva);
    }
  }

  String _formato(Duration d) {
    final min = d.inMinutes;
    final seg = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reproduciendo')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          children: [
            // Portada
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius16),
                child: Image.network(
                  widget.portada,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: colors.primaryContainer,
                    child: Icon(
                      Icons.music_note,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.spacing24),

            // Título, artista y favorito
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.titulo,
                        style: text.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(widget.artista, style: text.bodyLarge),
                    ],
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: favRef.snapshots(),
                  builder: (context, snapshot) {
                    final esFavorito = snapshot.data?.exists ?? false;

                    return IconButton(
                      icon: Icon(
                        esFavorito ? Icons.favorite : Icons.favorite_border,
                        color: esFavorito ? colors.primary : null,
                      ),
                      onPressed: () => _alternarFavorito(esFavorito),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.spacing16),

            // Barra de progreso
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final posicion = snapshot.data ?? Duration.zero;
                final duracion = player.duration ?? Duration.zero;
                final maximo = max(duracion.inSeconds.toDouble(), 1.0);
                final valor = min(posicion.inSeconds.toDouble(), maximo);

                return Column(
                  children: [
                    Slider(
                      value: valor,
                      max: maximo,
                      onChanged: duracion == Duration.zero
                          ? null
                          : (v) => player.seek(Duration(seconds: v.toInt())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formato(posicion), style: text.bodySmall),
                        Text(_formato(duracion), style: text.bodySmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          onPressed: () => _mover(posicion, -10),
                        ),
                        const SizedBox(width: AppSpacing.spacing16),

                        // Play / pausa
                        StreamBuilder<PlayerState>(
                          stream: player.playerStateStream,
                          builder: (context, estado) {
                            final reproduciendo = estado.data?.playing ?? false;

                            return IconButton.filled(
                              iconSize: AppSpacing.spacing32,
                              icon: Icon(
                                reproduciendo ? Icons.pause : Icons.play_arrow,
                              ),
                              onPressed: () {
                                if (reproduciendo) {
                                  player.pause();
                                } else if (estado.data?.processingState ==
                                    ProcessingState.completed) {
                                  player.seek(Duration.zero);
                                  player.play();
                                } else {
                                  player.play();
                                }
                              },
                            );
                          },
                        ),

                        const SizedBox(width: AppSpacing.spacing16),
                        IconButton(
                          icon: const Icon(Icons.forward_10),
                          onPressed: () => _mover(posicion, 10),
                        ),
                      ],
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
}