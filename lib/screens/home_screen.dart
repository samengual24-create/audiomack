import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<QuerySnapshot> _cancionesPorCategoria(String categoria) {
    return FirebaseFirestore.instance
        .collection('canciones')
        .where('categoria', isEqualTo: categoria)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        children: [
          Text('Top picks for you', style: text.headlineLarge),
          const SizedBox(height: AppSpacing.spacing16),
          _ListaHorizontal(stream: _cancionesPorCategoria('topPicks')),

          const SizedBox(height: AppSpacing.spacing32),

          Text('Recently played', style: text.headlineLarge),
          const SizedBox(height: AppSpacing.spacing16),
          _ListaHorizontal(stream: _cancionesPorCategoria('recientes')),

          const SizedBox(height: AppSpacing.spacing32),

          Text('Made for you', style: text.headlineLarge),
          const SizedBox(height: AppSpacing.spacing16),
          _ListaHorizontal(stream: _cancionesPorCategoria('paraTi')),
        ],
      ),
    );
  }
}

class _ListaHorizontal extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  const _ListaHorizontal({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const SizedBox(
            height: 60,
            child: Center(child: Text('Todavía no hay canciones aquí')),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.spacing16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radius8),
                      child: Image.network(
                        data['portada'] ?? '',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 120,
                          height: 120,
                          color: AppColors.neutral900,
                          child: const Icon(Icons.music_note),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Text(
                      data['titulo'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      data['artista'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}