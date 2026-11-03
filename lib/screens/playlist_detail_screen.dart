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

  Future<void> _agregarCancion(BuildContext context) async {
    final cancionesSnap =
        await FirebaseFirestore.instance.collection('canciones').get();

    if (!context.mounted) return;

    final seleccionada = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Agregar canción'),
        children: cancionesSnap.docs.map((doc) {
          final data = doc.data();
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, doc.id),
            child: Text('${data['titulo']} — ${data['artista']}'),
          );
        }).toList(),
      ),
    );

    if (seleccionada == null) return;

    await FirebaseFirestore.instance
        .collection('playlists')
        .doc(playlistId)
        .update({
      'canciones': FieldValue.arrayUnion([seleccionada]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

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
        stream: FirebaseFirestore.instance
            .collection('playlists')
            .doc(playlistId)
            .snapshots(),
        builder: (context, playlistSnap) {
          if (!playlistSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = playlistSnap.data!.data() as Map<String, dynamic>?;
          final List<dynamic> cancionesIds = data?['canciones'] ?? [];

          if (cancionesIds.isEmpty) {
            return const Center(
              child: Text('Esta playlist no tiene canciones todavía'),
            );
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(
              cancionesIds.map(
                (id) => FirebaseFirestore.instance
                    .collection('canciones')
                    .doc(id)
                    .get(),
              ),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final canciones = snapshot.data!;

              return ListView.builder(
                itemCount: canciones.length,
                itemBuilder: (context, index) {
                  final cancionData =
                      canciones[index].data() as Map<String, dynamic>?;

                  if (cancionData == null) return const SizedBox.shrink();

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radius8),
                      child: Image.network(
                        cancionData['portada'] ?? '',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 48,
                          height: 48,
                          color: AppColors.neutral900,
                          child: const Icon(Icons.music_note),
                        ),
                      ),
                    ),
                    title: Text(cancionData['titulo'] ?? ''),
                    subtitle: Text(cancionData['artista'] ?? ''),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            titulo: cancionData['titulo'] ?? '',
                            artista: cancionData['artista'] ?? '',
                            portada: cancionData['portada'] ?? '',
                            audioUrl: cancionData['audioUrl'] ?? '',
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