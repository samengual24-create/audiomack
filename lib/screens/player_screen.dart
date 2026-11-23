import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
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
  final _servicio = PlayerService.instance;

  late String _titulo;
  late String _artista;
  late String _portada;
  late String _audioUrl;

  // Cola = todas las canciones de Firestore
  List<Map<String, dynamic>> _cola = [];
  bool _aleatorio = false;
  bool _repetir = false;
  StreamSubscription<ProcessingState>? _finSub;

  @override
  void initState() {
    super.initState();
    _titulo = widget.titulo;
    _artista = widget.artista;
    _portada = widget.portada;
    _audioUrl = widget.audioUrl;

    _servicio.player.setLoopMode(LoopMode.off);

    // Al terminar una canción pasa a la siguiente
    _finSub = _servicio.player.processingStateStream.listen((estado) {
      if (estado == ProcessingState.completed && !_repetir) {
        _siguiente();
      }
    });

    _cargarCola();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarAudio());
  }

  @override
  void dispose() {
    _finSub?.cancel();
    super.dispose();
  }

  Future<void> _cargarCola() async {
    final snap = await FirebaseFirestore.instance.collection('canciones').get();
    if (!mounted) return;
    setState(() {
      _cola = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    });
  }

  Future<void> _cargarAudio() async {
    final ok = await _servicio.reproducir(
      titulo: _titulo,
      artista: _artista,
      portada: _portada,
      audioUrl: _audioUrl,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta canción no tiene audio todavía')),
      );
    }
  }

  void _cambiar(Map<String, dynamic> c) {
    setState(() {
      _titulo = (c['titulo'] ?? '').toString();
      _artista = (c['artista'] ?? '').toString();
      _portada = (c['portada'] ?? '').toString();
      _audioUrl = (c['audioUrl'] ?? '').toString();
    });
    _cargarAudio();
  }

  int get _indice =>
      _cola.indexWhere((c) => c['titulo'] == _titulo && c['artista'] == _artista);

  void _siguiente() {
    if (_cola.isEmpty) return;

    int nuevo;
    if (_aleatorio && _cola.length > 1) {
      do {
        nuevo = Random().nextInt(_cola.length);
      } while (nuevo == _indice);
    } else {
      nuevo = (_indice + 1) % _cola.length;
    }
    _cambiar(_cola[nuevo]);
  }

  void _anterior() {
    if (_cola.isEmpty) return;

    // Si ya avanzó más de 3 segundos, reinicia la canción
    if (_servicio.player.position > const Duration(seconds: 3)) {
      _servicio.player.seek(Duration.zero);
      return;
    }

    final nuevo = (_indice - 1 + _cola.length) % _cola.length;
    _cambiar(_cola[nuevo]);
  }

  void _alternarRepetir() {
    setState(() => _repetir = !_repetir);
    _servicio.player.setLoopMode(_repetir ? LoopMode.one : LoopMode.off);
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Add: agrega la canción a una playlist
  void _agregarAPlaylist() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final actual = _indice;
    if (actual < 0) {
      _aviso('Cargando canciones, intenta de nuevo');
      return;
    }
    final idCancion = _cola[actual]['id'];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('playlists')
              .where('creadaPor', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: AppSizes.sectionHeight,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const SizedBox(
                height: AppSizes.sectionHeight,
                child: Center(child: Text('Crea una playlist en Library')),
              );
            }

            return ListView(
              shrinkWrap: true,
              children: [
                const ListTile(title: Text('Agregar a playlist')),
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text((data['nombre'] ?? '').toString()),
                    onTap: () async {
                      await doc.reference.update({
                        'canciones': FieldValue.arrayUnion([idCancion]),
                      });
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (mounted) _aviso('Agregada a la playlist');
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  // Queue: lista de canciones para saltar a otra
  void _verCola() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final colors = Theme.of(context).colorScheme;

        return ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Cola de reproducción')),
            ..._cola.map((c) {
              final sonando = c['titulo'] == _titulo && c['artista'] == _artista;
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius8),
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
                title: Text((c['titulo'] ?? '').toString()),
                subtitle: Text((c['artista'] ?? '').toString()),
                trailing: sonando
                    ? Icon(Icons.graphic_eq, color: colors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _cambiar(c);
                },
              );
            }),
          ],
        );
      },
    );
  }

  String _formato(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _accion(IconData icono, String texto, VoidCallback onTap) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.radius8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono),
            const SizedBox(height: AppSpacing.spacing4),
            Text(texto, style: text.labelMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final player = _servicio.player;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .doc('$_titulo|$_artista');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        children: [
          // Portada
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius16),
              child: Image.network(
                _portada,
                width: AppSizes.cardCoverWide,
                height: AppSizes.cardCoverWide,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: AppSizes.cardCoverWide,
                  height: AppSizes.cardCoverWide,
                  color: colors.primaryContainer,
                  child: Icon(
                    Icons.album,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.spacing24),

          // Título, artista y corazón
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titulo,
                      style: text.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(_artista, style: text.bodyMedium),
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
                    onPressed: () {
                      if (esFavorito) {
                        favRef.delete();
                      } else {
                        favRef.set({
                          'titulo': _titulo,
                          'artista': _artista,
                          'portada': _portada,
                          'audioUrl': _audioUrl,
                        });
                      }
                    },
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
              final total = player.duration ?? Duration.zero;
              final maximo = total.inMilliseconds.toDouble();
              final valor = posicion.inMilliseconds
                  .toDouble()
                  .clamp(0, maximo > 0 ? maximo : 1)
                  .toDouble();

              return Column(
                children: [
                  Slider(
                    value: valor,
                    max: maximo > 0 ? maximo : 1,
                    onChanged: (v) =>
                        player.seek(Duration(milliseconds: v.toInt())),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formato(posicion), style: text.bodySmall),
                      Text(_formato(total), style: text.bodySmall),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.spacing8),

          // Controles: shuffle, anterior, play/pause, siguiente, repetir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Aleatorio',
                icon: Icon(
                  Icons.shuffle,
                  color: _aleatorio ? colors.primary : null,
                ),
                onPressed: () => setState(() => _aleatorio = !_aleatorio),
              ),
              IconButton(
                iconSize: AppSizes.avatarSm,
                tooltip: 'Anterior',
                icon: const Icon(Icons.skip_previous),
                onPressed: _anterior,
              ),
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final reproduciendo = snapshot.data?.playing ?? false;
                  return IconButton.filled(
                    iconSize: AppSizes.avatarSm,
                    icon: Icon(
                      reproduciendo ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (reproduciendo) {
                        player.pause();
                      } else {
                        player.play();
                      }
                    },
                  );
                },
              ),
              IconButton(
                iconSize: AppSizes.avatarSm,
                tooltip: 'Siguiente',
                icon: const Icon(Icons.skip_next),
                onPressed: _siguiente,
              ),
              IconButton(
                tooltip: 'Repetir',
                icon: Icon(
                  Icons.repeat_one,
                  color: _repetir ? colors.primary : null,
                ),
                onPressed: _alternarRepetir,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Add / Download / Mod / Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _accion(Icons.playlist_add, 'Add', _agregarAPlaylist),
              _accion(Icons.download, 'Download',
                  () => _aviso('Descargas: próximamente')),
              _accion(Icons.tune, 'Mod',
                  () => _aviso('Modificadores de audio: próximamente')),
              _accion(Icons.queue_music, 'Queue', _verCola),
            ],
          ),
        ],
      ),
    );
  }
}