import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        children: const [
          _Seccion(titulo: 'Top picks for you', categoria: 'topPicks'),
          SizedBox(height: AppSpacing.spacing32),
          _Seccion(titulo: 'Recently played', categoria: 'recientes'),
          SizedBox(height: AppSpacing.spacing32),
          _Seccion(titulo: 'Made for you', categoria: 'paraTi'),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String categoria;

  const _Seccion({required this.titulo, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: text.titleLarge),
        const SizedBox(height: AppSpacing.spacing16),
        SizedBox(
          height: 180,
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
                  final titulo = (d['titulo'] ?? '').toString();
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
                            titulo: titulo,
                            artista: artista,
                            portada: portada,
                            audioUrl: audioUrl,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius8),
                            child: Image.network(
                              portada,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 120,
                                height: 120,
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
                            titulo,
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