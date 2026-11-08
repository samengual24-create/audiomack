import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          children: [
            // Cabecera: logo, notificaciones y perfil
            Row(
              children: [
                Icon(Icons.graphic_eq, color: colors.primary),
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

            const SizedBox(height: AppSpacing.spacing16),
            Text('Home', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.spacing32),

            const _Seccion(
              titulo: 'Top picks for you',
              categoria: 'topPicks',
              grande: true,
            ),
            const SizedBox(height: AppSpacing.spacing32),
            const _Seccion(
              titulo: 'Recently played',
              subtitulo: 'Based on what you hear',
              categoria: 'recientes',
            ),
            const SizedBox(height: AppSpacing.spacing32),
            const _Seccion(
              titulo: 'Made for you',
              categoria: 'paraTi',
            ),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String categoria;
  final bool grande;

  const _Seccion({
    required this.titulo,
    required this.categoria,
    this.subtitulo = '',
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final ancho = grande ? AppSizes.cardCoverWide : AppSizes.cardCover;
    final alto = grande ? AppSizes.cardCoverWideHeight : AppSizes.cardCover;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección y "See all"
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: text.titleLarge),
                  if (subtitulo.isNotEmpty)
                    Text(subtitulo, style: text.bodySmall),
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

        const SizedBox(height: AppSpacing.spacing16),

        SizedBox(
          height: alto + AppSizes.cardTextHeight,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('canciones')
                .where('categoria', isEqualTo: categoria)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text('Sin canciones'));
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.spacing16),
                itemBuilder: (context, index) {
                  final d = docs[index].data() as Map<String, dynamic>;
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
                      width: ancho,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius8),
                            child: Image.network(
                              portada,
                              width: ancho,
                              height: alto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: ancho,
                                height: alto,
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
              );
            },
          ),
        ),
      ],
    );
  }
}