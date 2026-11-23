import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'player_screen.dart';

class SongListScreen extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String portada;
  final bool circular;
  final List<Map<String, dynamic>> canciones;

  const SongListScreen({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.portada,
    required this.canciones,
    this.circular = false,
  });

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
    final lado = circular ? AppSizes.avatarLg : AppSizes.cardCoverWide;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                circular ? AppRadius.radiusFull : AppRadius.radius16,
              ),
              child: Image.network(
                portada,
                width: lado,
                height: lado,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: lado,
                  height: lado,
                  color: colors.primaryContainer,
                  child: Icon(
                    circular ? Icons.person : Icons.album,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.spacing16),

          Text(titulo, textAlign: TextAlign.center, style: text.titleLarge),
          Text(subtitulo, textAlign: TextAlign.center, style: text.bodySmall),

          const SizedBox(height: AppSpacing.spacing16),

          FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
            onPressed:
                canciones.isEmpty ? null : () => _abrir(context, canciones.first),
          ),

          const SizedBox(height: AppSpacing.spacing16),

          ...canciones.map((c) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius8),
                child: Image.network(
                  (c['portada'] ?? '').toString(),
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
              title: Text(
                (c['titulo'] ?? '').toString(),
                style: text.titleMedium,
              ),
              subtitle: Text((c['artista'] ?? '').toString()),
              onTap: () => _abrir(context, c),
            );
          }),
        ],
      ),
    );
  }
}