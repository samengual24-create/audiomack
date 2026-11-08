import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/player_service.dart';
import '../theme/theme.dart';
import 'player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = PlayerService.instance;
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: servicio,
      builder: (context, _) {
        if (!servicio.hayCancion) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing8,
            vertical: AppSpacing.spacing8,
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(
                    titulo: servicio.titulo,
                    artista: servicio.artista,
                    portada: servicio.portada,
                    audioUrl: servicio.audioUrl,
                  ),
                ),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius8),
              child: Image.network(
                servicio.portada,
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
              servicio.titulo,
              style: text.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              servicio.artista,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: StreamBuilder<PlayerState>(
              stream: servicio.player.playerStateStream,
              builder: (context, estado) {
                final reproduciendo = estado.data?.playing ?? false;

                return IconButton(
                  icon: Icon(
                    reproduciendo ? Icons.pause : Icons.play_arrow,
                    color: colors.primary,
                  ),
                  onPressed: () {
                    if (reproduciendo) {
                      servicio.player.pause();
                    } else if (estado.data?.processingState ==
                        ProcessingState.completed) {
                      servicio.player.seek(Duration.zero);
                      servicio.player.play();
                    } else {
                      servicio.player.play();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}