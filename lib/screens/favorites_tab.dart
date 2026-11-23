import 'package:material_ui/material_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
import 'cover_tile.dart';
import 'player_screen.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('favoritos')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text('Aún no tienes favoritos. Toca el corazón en el reproductor'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.spacing16,
            mainAxisSpacing: AppSpacing.spacing16,
            childAspectRatio: 0.8,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final c = doc.data() as Map<String, dynamic>;

            return CoverTile(
              portada: (c['portada'] ?? '').toString(),
              titulo: (c['titulo'] ?? '').toString(),
              subtitulo: (c['artista'] ?? '').toString(),
              accion: IconButton.filledTonal(
                iconSize: AppSpacing.spacing16,
                tooltip: 'Quitar de favoritos',
                icon: const Icon(Icons.favorite),
                onPressed: () => doc.reference.delete(),
              ),
              onTap: () {
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
              },
            );
          },
        );
      },
    );
  }
}