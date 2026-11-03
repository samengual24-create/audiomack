import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme.dart';
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

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.spacing8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final c = doc.data() as Map<String, dynamic>;

            return ListTile(
              leading: const Icon(Icons.favorite),
              title: Text((c['titulo'] ?? '').toString()),
              subtitle: Text((c['artista'] ?? '').toString()),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Quitar de favoritos',
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