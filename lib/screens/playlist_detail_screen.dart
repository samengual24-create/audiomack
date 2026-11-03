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
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _agregarCancion(context),
          ),
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

          if (ids.isEmpty) {
            return const Center(
              child: Text('Esta playlist está vacía. Agrega canciones con +'),
            );
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: _cargarCanciones(ids),
            builder: (context, futuro) {
              if (!futuro.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final canciones = futuro.data!.where((d) => d.exists).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.spacing8),
                itemCount: canciones.length,
                itemBuilder: (context, index) {
                  final doc = canciones[index];
                  final c = doc.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text((c['titulo'] ?? '').toString()),
                    subtitle: Text((c['artista'] ?? '').toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: 'Quitar de la playlist',
                      onPressed: () => _quitarCancion(doc.id),
                    ),
                    onTap: () {
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
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}