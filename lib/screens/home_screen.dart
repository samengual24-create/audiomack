import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
import 'cover_tile.dart';
import 'logo_audiomack.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        children: [
          // Cabecera: logo, campana y perfil
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing16),
            child: Row(
              children: [
                const LogoAudioMack(),
                const Spacer(),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
            child: Text('Home', style: text.headlineLarge),
          ),

          const SizedBox(height: AppSpacing.spacing16),

          // Secciones desde Firestore
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
                  .toList();

              List<Map<String, dynamic>> de(String categoria) =>
                  todas.where((c) => c['categoria'] == categoria).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Seccion(
                    titulo: 'Top Picks',
                    canciones: de('topPicks'),
                    grande: true,
                    onTap: (c) => _abrir(context, c),
                  ),
                  _Seccion(
                    titulo: 'Recently Played',
                    subtitulo: 'Based on what you hear',
                    canciones: de('recientes'),
                    onTap: (c) => _abrir(context, c),
                  ),
                  _Seccion(
                    titulo: 'For You',
                    canciones: de('paraTi'),
                    onTap: (c) => _abrir(context, c),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final List<Map<String, dynamic>> canciones;
  final bool grande;
  final void Function(Map<String, dynamic>) onTap;

  const _Seccion({
    required this.titulo,
    required this.canciones,
    required this.onTap,
    this.subtitulo,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    if (canciones.isEmpty) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final ancho = grande ? AppSizes.cardCoverWide : AppSizes.cardCover;
    final altoPortada =
        grande ? AppSizes.cardCoverWideHeight : AppSizes.cardCover;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: text.titleLarge),
                    if (subtitulo != null)
                      Text(subtitulo!, style: text.bodySmall),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente')),
                  );
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        SizedBox(
          height: altoPortada + AppSizes.cardTextHeight,
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
                width: ancho,
                child: CoverTile(
                  portada: (c['portada'] ?? '').toString(),
                  titulo: (c['titulo'] ?? '').toString(),
                  subtitulo: (c['artista'] ?? '').toString(),
                  onTap: () => onTap(c),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.spacing24),
      ],
    );
  }
}