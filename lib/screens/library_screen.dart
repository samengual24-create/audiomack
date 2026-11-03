import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
import 'playlist_detail_screen.dart';

// Diálogo que maneja su propio campo de texto
class _NombreDialog extends StatefulWidget {
  final String titulo;
  final String inicial;

  const _NombreDialog({required this.titulo, required this.inicial});

  @override
  State<_NombreDialog> createState() => _NombreDialogState();
}

class _NombreDialogState extends State<_NombreDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.inicial);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nombre'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Future<String?> _pedirNombre(
    BuildContext context, {
    required String titulo,
    String inicial = '',
  }) async {
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => _NombreDialog(titulo: titulo, inicial: inicial),
    );

    if (resultado == null || resultado.isEmpty) return null;
    return resultado;
  }

  Future<void> _crearPlaylist(BuildContext context) async {
    final nombre = await _pedirNombre(context, titulo: 'Nueva playlist');
    if (nombre == null) return;

    await FirebaseFirestore.instance.collection('playlists').add({
      'nombre': nombre,
      'creadaPor': FirebaseAuth.instance.currentUser!.uid,
      'canciones': [],
    });
  }

  Future<void> _renombrar(
    BuildContext context,
    String id,
    String actual,
  ) async {
    final nombre = await _pedirNombre(
      context,
      titulo: 'Renombrar playlist',
      inicial: actual,
    );
    if (nombre == null) return;

    await FirebaseFirestore.instance
        .collection('playlists')
        .doc(id)
        .update({'nombre': nombre});
  }

  Future<void> _eliminar(BuildContext context, String id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar playlist'),
        content: Text('¿Seguro que quieres eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await FirebaseFirestore.instance.collection('playlists').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Artists'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _crearPlaylist(context),
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            const Center(child: Text('Próximamente')),
            const Center(child: Text('Próximamente')),

            // Playlists del usuario
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('playlists')
                  .where('creadaPor', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Aún no tienes playlists. Crea una con +'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.spacing16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.spacing16,
                    mainAxisSpacing: AppSpacing.spacing16,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = (data['nombre'] ?? '').toString();
                    final cantidad = (data['canciones'] as List? ?? []).length;

                    return Card(
                      key: ValueKey(doc.id),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistDetailScreen(
                                playlistId: doc.id,
                                nombre: nombre,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.queue_music),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    onSelected: (valor) {
                                      if (valor == 'renombrar') {
                                        _renombrar(context, doc.id, nombre);
                                      } else if (valor == 'eliminar') {
                                        _eliminar(context, doc.id, nombre);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'renombrar',
                                        child: Text('Renombrar'),
                                      ),
                                      PopupMenuItem(
                                        value: 'eliminar',
                                        child: Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                nombre,
                                style: text.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.spacing4),
                              Text('$cantidad canciones',
                                  style: text.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}