import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String nombre;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.nombre,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool _subiendo = false;

  DocumentReference get _ref => FirebaseFirestore.instance
      .collection('playlists')
      .doc(widget.playlistId);

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

  // Elige una imagen, la sube a Storage y guarda la URL en la playlist
  Future<void> _cambiarFoto() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final archivo = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'Imágenes',
            extensions: ['jpg', 'jpeg', 'png'],
            mimeTypes: ['image/jpeg', 'image/png'],
          ),
        ],
      );
      if (archivo == null) return;

      setState(() => _subiendo = true);

      final bytes = await archivo.readAsBytes();
      final esPng = archivo.name.toLowerCase().endsWith('.png');

      final ref = FirebaseStorage.instance.ref(
        'playlists/${widget.playlistId}.${esPng ? 'png' : 'jpg'}',
      );

      await ref.putData(
        bytes,
        SettableMetadata(contentType: esPng ? 'image/png' : 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();
      await _ref.update({'foto': url});
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo subir la foto: $e')),
      );
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
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
          final nombrePlaylist = (data?['nombre'] ?? widget.nombre).toString();
          final foto = (data?['foto'] ?? '').toString();

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
                  // Foto de la playlist (toca para cambiarla)
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GestureDetector(
                          onTap: _subiendo ? null : _cambiarFoto,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                foto.isEmpty
                                    ? Container(
                                        color: colors.secondaryContainer,
                                        child: Icon(
                                          Icons.queue_music,
                                          size: AppSizes.cardCover,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      )
                                    : Image.network(
                                        foto,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          color: colors.secondaryContainer,
                                          child: Icon(
                                            Icons.broken_image,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                Positioned(
                                  right: AppSpacing.spacing8,
                                  bottom: AppSpacing.spacing8,
                                  child: IconButton.filled(
                                    tooltip: 'Cambiar foto',
                                    icon: const Icon(Icons.photo_camera),
                                    onPressed: _subiendo ? null : _cambiarFoto,
                                  ),
                                ),
                                if (_subiendo)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
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