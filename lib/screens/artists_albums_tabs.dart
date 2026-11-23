import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme.dart';
import 'cover_tile.dart';
import 'song_list_screen.dart';

// Agrupa las canciones según un campo (artista o album)
Map<String, List<Map<String, dynamic>>> _agrupar(
  List<QueryDocumentSnapshot> docs,
  String campo,
) {
  final grupos = <String, List<Map<String, dynamic>>>{};

  for (final doc in docs) {
    final data = doc.data() as Map<String, dynamic>;
    final clave = (data[campo] ?? '').toString();
    if (clave.isEmpty) continue;
    grupos.putIfAbsent(clave, () => []).add(data);
  }

  return grupos;
}

// Pestaña Artists
class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('canciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final grupos = _agrupar(snapshot.data!.docs, 'artista');
        final nombres = grupos.keys.toList()..sort();

        if (nombres.isEmpty) {
          return const Center(child: Text('Sin artistas'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.spacing8),
          itemCount: nombres.length,
          itemBuilder: (context, index) {
            final nombre = nombres[index];
            final lista = grupos[nombre]!;
            final portada = (lista.first['portada'] ?? '').toString();
            final cantidad = '${lista.length} canciones';

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                child: Image.network(
                  portada,
                  width: AppSizes.avatarSm,
                  height: AppSizes.avatarSm,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: AppSizes.avatarSm,
                    height: AppSizes.avatarSm,
                    color: colors.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              title: Text(nombre),
              subtitle: Text(cantidad),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongListScreen(
                      titulo: nombre,
                      subtitulo: cantidad,
                      portada: portada,
                      circular: true,
                      canciones: lista,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Pestaña Albums
class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('canciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final grupos = _agrupar(snapshot.data!.docs, 'album');
        final nombres = grupos.keys.toList()..sort();

        if (nombres.isEmpty) {
          return const Center(
            child: Text('Agrega el campo album a tus canciones en Firestore'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.spacing16,
            mainAxisSpacing: AppSpacing.spacing16,
            childAspectRatio: 0.8,
          ),
          itemCount: nombres.length,
          itemBuilder: (context, index) {
            final nombre = nombres[index];
            final lista = grupos[nombre]!;
            final portada = (lista.first['portada'] ?? '').toString();
            final artista = (lista.first['artista'] ?? '').toString();

            return CoverTile(
              portada: portada,
              titulo: nombre,
              subtitulo: artista,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongListScreen(
                      titulo: nombre,
                      subtitulo: artista,
                      portada: portada,
                      canciones: lista,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}