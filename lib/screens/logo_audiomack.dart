import 'package:material_ui/material_ui.dart';

// Logo de AudioMack: usa la imagen y, si no está, dibuja una onda
class LogoAudioMack extends StatelessWidget {
  final double ancho;
  final Color? color;

  const LogoAudioMack({super.key, this.ancho = 48, this.color});

  @override
  Widget build(BuildContext context) {
    final colorFinal = color ?? Theme.of(context).colorScheme.primary;

    return Image.asset(
      'lib/assets/logo.png',
      width: ancho,
      color: colorFinal,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, _, _) => CustomPaint(
        size: Size(ancho, ancho / 2),
        painter: _LogoPainter(colorFinal),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final ruta = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w * 0.40, h * 0.55)
      ..lineTo(w * 0.47, h * 0.40)
      ..lineTo(w * 0.53, h * 0.80)
      ..lineTo(w * 0.62, h * 0.10)
      ..lineTo(w * 0.70, h * 0.90)
      ..lineTo(w * 0.78, h * 0.35)
      ..lineTo(w * 0.84, h * 0.60)
      ..lineTo(w * 0.90, h * 0.50)
      ..lineTo(w, h * 0.55);

    canvas.drawPath(ruta, pincel);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter viejo) => viejo.color != color;
}