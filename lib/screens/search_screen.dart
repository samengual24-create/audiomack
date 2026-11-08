import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String consulta = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool _coincide(dynamic valor) {
    final texto = (valor ?? '').toString().toLowerCase();
    return texto.contains(consulta.toLowerCase());
  }

  Widget _lista(List<Widget> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }
    return ListView(children: items);
  }

  Widget _cancionTile(BuildContext context, Map<String, dynamic> d) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final titulo = (d['titulo'] ?? '').toString();
    final artista = (d['artista'] ?? '').toString();
    final portada = (d['portada'] ?? '').toString();
    final audioUrl = (d['audioUrl'] ?? '').toString();

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        child: Image.network(
          portada,
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
      title: Text(titulo, style: text.titleMedium),
      subtitle: Text(artista),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              titulo: titulo,
              artista: artista,
              portada: portada,
              audioUrl: audioUrl,
            ),
          ),
        );
      },
    );
  }

  Widget _artistaTile(BuildContext context, String nombre) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(nombre.isEmpty ? '?' : nombre[0].toUpperCase()),
      ),
      title: Text(nombre),
      onTap: () {
        controller.text = nombre;
        setState(() => consulta = nombre);
        DefaultTabController.of(context).animateTo(1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Songs'),
              Tab(text: 'Artists'),
              Tab(text: 'Albums'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing16),
              child: SearchBar(
                controller: controller,
                hintText: 'Search songs & artists',
                leading: const Icon(Icons.search),
                trailing: [
                  if (consulta.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        setState(() => consulta = '');
                      },
                    ),
                ],
                onChanged: (valor) => setState(() => consulta = valor.trim()),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('canciones')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (consulta.isEmpty) {
                    return const Center(
                      child: Text('Escribe para buscar canciones y artistas'),
                    );
                  }

                  final canciones = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  final songs = canciones
                      .where(
                        (d) => _coincide(d['titulo']) || _coincide(d['artista']),
                      )
                      .toList();

                  final artistas = canciones
                      .where((d) => _coincide(d['artista']))
                      .map((d) => (d['artista'] ?? '').toString())
                      .where((a) => a.isNotEmpty)
                      .toSet()
                      .toList();

                  final albums = canciones
                      .where((d) => _coincide(d['album']))
                      .map((d) => (d['album'] ?? '').toString())
                      .where((a) => a.isNotEmpty)
                      .toSet()
                      .toList();

                  return TabBarView(
                    children: [
                      _lista([
                        ...artistas.map((a) => _artistaTile(context, a)),
                        ...songs.map((s) => _cancionTile(context, s)),
                      ]),
                      _lista(songs.map((s) => _cancionTile(context, s)).toList()),
                      _lista(
                        artistas.map((a) => _artistaTile(context, a)).toList(),
                      ),
                      _lista(
                        albums
                            .map(
                              (a) => ListTile(
                                leading: const Icon(Icons.album),
                                title: Text(a),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}