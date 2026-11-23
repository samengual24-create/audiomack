import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

// Tarjeta con portada, título y subtítulo (se usa en cuadrículas)
class CoverTile extends StatelessWidget {
  final String portada;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final Widget? accion;

  const CoverTile({
    super.key,
    required this.portada,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.radius8),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.radius8),
                    child: Image.network(
                      portada,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: colors.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                if (accion != null)
                  Positioned(
                    top: AppSpacing.spacing4,
                    right: AppSpacing.spacing4,
                    child: accion!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            titulo,
            style: text.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitulo,
            style: text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}