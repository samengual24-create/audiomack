import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const filtros = ['Gender', 'Pop', 'Rock'];
  static const subtitulos = {
    'Rock': 'Turn it up and feel the power',
    'Pop': 'The new of the moment',
  };

  String filtro = 'Gender';
  String modo = 'Echo';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.discover500, AppColors.discover800],
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('canciones').snapshots(),
          builder: (context, snapshot) {
            final canciones = (snapshot.data?.docs ?? [])
                .map((d) => d.data() as Map<String, dynamic>)
                .toList();

            final generos = canciones
                .map((d) => (d['genero'] ?? '').toString())
                .where((g) => g.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            final visibles = filtro == 'Gender' ? generos : [filtro];

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.spacing16),
              children: [
                Row(
                  children: [
                    Text('Discover', style: text.headlineLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.person_outline),
                      onSelected: (valor) {
                        if (valor == 'salir') {
                          FirebaseAuth.instance.signOut();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'salir',
                          child: Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.spacing16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filtros.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.spacing8,
                        ),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: filtro == f,
                          onSelected: (_) => setState(() => filtro = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppSpacing.spacing16),

                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Echo', label: Text('Echo')),
                    ButtonSegment(value: 'Pulse', label: Text('Pulse')),
                    ButtonSegment(value: 'Bloom', label: Text('Bloom')),
                  ],
                  selected: {modo},
                  onSelectionChanged: (seleccion) {
                    setState(() => modo = seleccion.first);
                  },
                ),

                const SizedBox(height: AppSpacing.spacing24),

                if (generos.isEmpty)
                  const Center(
                    child: Text(
                      'Agrega el campo genero a tus canciones en Firestore',
                    ),
                  ),

                ...visibles.map<Widget>((g) {
                  final lista =
                      canciones.where((d) => d['genero'] == g).toList();

                  if (lista.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.spacing32,
                    ),
                    child: _Seccion(
                      titulo: g,
                      subtitulo: subtitulos[g] ?? '',
                      canciones: lista,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Map<String, dynamic>> canciones;

  const _Seccion({
    required this.titulo,
    required this.subtitulo,
    required this.canciones,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: text.titleLarge),
        if (subtitulo.isNotEmpty) Text(subtitulo, style: text.bodySmall),
        const SizedBox(height: AppSpacing.spacing16),
        SizedBox(
          height: AppSizes.sectionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: canciones.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.spacing16),
            itemBuilder: (context, index) {
              final d = canciones[index];
              final tituloCancion = (d['titulo'] ?? '').toString();
              final artista = (d['artista'] ?? '').toString();
              final portada = (d['portada'] ?? '').toString();
              final audioUrl = (d['audioUrl'] ?? '').toString();

              return InkWell(
                borderRadius: BorderRadius.circular(AppRadius.radius8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        titulo: tituloCancion,
                        artista: artista,
                        portada: portada,
                        audioUrl: audioUrl,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: AppSizes.cardCover,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radius8),
                        child: Image.network(
                          portada,
                          width: AppSizes.cardCover,
                          height: AppSizes.cardCover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: AppSizes.cardCover,
                            height: AppSizes.cardCover,
                            color: colors.primaryContainer,
                            child: Icon(
                              Icons.music_note,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        tituloCancion,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        artista,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}