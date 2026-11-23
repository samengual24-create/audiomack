import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
import 'cover_tile.dart';
import 'player_screen.dart';

enum _Modo { echo, pulse, bloom }

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  _Modo _modo = _Modo.echo;
  String _genero = 'All';

  // Colores del degradado según el modo
  Color get _colorArriba {
    switch (_modo) {
      case _Modo.echo:
        return AppColors.echo500;
      case _Modo.pulse:
        return AppColors.pulse500;
      case _Modo.bloom:
        return AppColors.bloom500;
    }
  }

  Color get _colorAbajo {
    switch (_modo) {
      case _Modo.echo:
        return AppColors.echo800;
      case _Modo.pulse:
        return AppColors.pulse800;
      case _Modo.bloom:
        return AppColors.bloom800;
    }
  }

  // Secciones de cada modo: categoría de Firestore + título
  List<(String, String)> get _secciones {
    switch (_modo) {
      case _Modo.echo:
        return [
          ('topPicks', 'Top: USA'),
          ('paraTi', 'Favorites of all times'),
        ];
      case _Modo.pulse:
        return [
          ('recientes', "What's playing now"),
          ('topPicks', 'Trending today'),
        ];
      case _Modo.bloom:
        return [
          ('paraTi', 'The next boom'),
          ('recientes', 'Beyond the day'),
        ];
    }
  }

  void _abrir(Map<String, dynamic> c) {
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

  Widget _seccion(String titulo, List<Map<String, dynamic>> canciones) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
          child: Text(titulo, style: text.titleLarge),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        SizedBox(
          height: AppSizes.cardCover + AppSizes.cardTextHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
            itemCount: canciones.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.spacing16),
            itemBuilder: (context, index) {
              final c = canciones[index];
              return SizedBox(
                width: AppSizes.cardCover,
                child: CoverTile(
                  portada: (c['portada'] ?? '').toString(),
                  titulo: (c['titulo'] ?? '').toString(),
                  subtitulo: (c['artista'] ?? '').toString(),
                  onTap: () => _abrir(c),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.spacing24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_colorArriba, _colorAbajo],
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Cabecera
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Discover', style: text.headlineLarge),
                  ),
                  IconButton.filledTonal(
                    icon: Badge(
                      smallSize: AppSpacing.spacing8,
                      backgroundColor: colors.primary,
                      child: const Icon(Icons.notifications),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSpacing.spacing8),
                  PopupMenuButton<String>(
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
                    child: CircleAvatar(
                      backgroundColor: colors.secondaryContainer,
                      child: const Icon(Icons.person),
                    ),
                  ),
                ],
              ),
            ),

            // Selector Echo / Pulse / Bloom
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
              child: SegmentedButton<_Modo>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _Modo.echo, label: Text('Echo')),
                  ButtonSegment(value: _Modo.pulse, label: Text('Pulse')),
                  ButtonSegment(value: _Modo.bloom, label: Text('Bloom')),
                ],
                selected: {_modo},
                onSelectionChanged: (valor) =>
                    setState(() => _modo = valor.first),
              ),
            ),

            const SizedBox(height: AppSpacing.spacing16),

            // Filtros de género
            SizedBox(
              height: AppSizes.thumbnail,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing16,
                ),
                children: ['All', 'Pop', 'Rock'].map((g) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.spacing8),
                    child: ChoiceChip(
                      label: Text(g),
                      selected: _genero == g,
                      onSelected: (_) => setState(() => _genero = g),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Secciones con canciones de Firestore
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('canciones').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.spacing32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final todas = snapshot.data!.docs
                    .map((d) => d.data() as Map<String, dynamic>)
                    .where(
                      (c) => _genero == 'All' || c['genero'] == _genero,
                    )
                    .toList();

                final widgets = <Widget>[];

                for (final (categoria, titulo) in _secciones) {
                  final lista =
                      todas.where((c) => c['categoria'] == categoria).toList();
                  if (lista.isNotEmpty) {
                    widgets.add(_seccion(titulo, lista));
                  }
                }

                if (widgets.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.spacing32),
                    child: Center(child: Text('No hay canciones para este filtro')),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.spacing16),
                    ...widgets,
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