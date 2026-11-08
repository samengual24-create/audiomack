import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  final String nombre;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.nombre,
  });

  DocumentReference get _ref =>
      FirebaseFirestore.instance.collection('playlists').doc(playlistId);

  void _abrir(BuildContext context, Map<String, dynamic> c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          titulo: (c['titulo'] ?? '').toString(),
          artista: (c['artista'] ?? '').toString(),
          portada: (c['portada'] ?? '').toString(),
          audioUrl: (c['audioUrl'] ?? '').toString(),
        ),
      ),
    );
  }

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente')),
    );
  }

  // Agregar canciones a la playlist
  Future<void> _agregarCancion(BuildContext context) async {
    final snap = await FirebaseFirestore.instance.collection('canciones').get();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar canción'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: snap.docs.map((d) {
              final data = d.data();
              return ListTile(
                title: Text((data['titulo'] ?? '').toString()),
                subtitle: Text((data['artista'] ?? '').toString()),
                onTap: () {
                  _ref.update({
                    'canciones': FieldValue.arrayUnion([d.id]),
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Quitar una canción de la playlist
  Future<void> _quitarCancion(String cancionId) {
    return _ref.update({
      'canciones': FieldValue.arrayRemove([cancionId]),
    });
  }

  Future<List<DocumentSnapshot>> _cargarCanciones(List ids) {
    return Future.wait(
      ids.map(
        (id) => FirebaseFirestore.instance
            .collection('canciones')
            .doc(id.toString())
            .get(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Agregar canciones',
            onPressed: () => _agregarCancion(context),
          ),
          const SizedBox(width: AppSpacing.spacing8),
          IconButton.filledTonal(
            icon: const Icon(Icons.share),
            onPressed: () => _proximamente(context),
          ),
          const SizedBox(width: AppSpacing.spacing16),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _ref.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final ids = (data?['canciones'] as List?) ?? [];
          final nombrePlaylist = (data?['nombre'] ?? nombre).toString();

          return FutureBuilder<List<DocumentSnapshot>>(
            future: _cargarCanciones(ids),
            builder: (context, futuro) {
              if (!futuro.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final canciones = futuro.data!.where((d) => d.exists).toList();
              final hayCanciones = canciones.isNotEmpty;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.spacing16),
                children: [
                  // Portada de la playlist
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius16),
                          ),
                          child: Icon(
                            Icons.queue_music,
                            size: AppSizes.cardCover,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.spacing16),

                  Text(
                    nombrePlaylist,
                    textAlign: TextAlign.center,
                    style: text.titleLarge,
                  ),
                  Text(
                    'Created by me',
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),

                  const SizedBox(height: AppSpacing.spacing16),

                  // Shuffle, Play y descarga
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.shuffle),
                        onPressed: hayCanciones
                            ? () {
                                final doc = canciones[
                                    Random().nextInt(canciones.length)];
                                _abrir(
                                  context,
                                  doc.data() as Map<String, dynamic>,
                                );
                              }
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.spacing16),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
                          onPressed: hayCanciones
                              ? () => _abrir(
                                    context,
                                    canciones.first.data()
                                        as Map<String, dynamic>,
                                  )
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacing16),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.download),
                        onPressed: () => _proximamente(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.spacing16),

                  if (!hayCanciones)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.spacing24),
                      child: Center(
                        child: Text(
                          'Esta playlist está vacía. Agrega canciones con el botón de arriba',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Lista de canciones
                  ...canciones.map((doc) {
                    final c = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius8),
                        child: Image.network(
                          (c['portada'] ?? '').toString(),
                          width: AppSizes.thumbnail,
                          height: AppSizes.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: AppSizes.thumbnail,
                            height: AppSizes.thumbnail,
                            color: colors.primaryContainer,
                            child: Icon(
                              Icons.music_note,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        (c['titulo'] ?? '').toString(),
                        style: text.titleMedium,
                      ),
                      subtitle: Text((c['artista'] ?? '').toString()),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: colors.primary),
                        onSelected: (valor) {
                          if (valor == 'quitar') _quitarCancion(doc.id);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'quitar',
                            child: Text('Quitar de la playlist'),
                          ),
                        ],
                      ),
                      onTap: () => _abrir(context, c),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}