import 'package:flutter/material.dart';

import '../connector/meshcore_protocol.dart';
import '../theme/sigurdos_theme.dart';

/// Shape used to encode node type on the map.
enum NodeMarkerShape {
  circle,
  square,
  diamond,
  rectangle,
  triangle,
  hollowSquare,
  crosshair,
}

/// Returns the pixel-geometry shape for a given node [type].
NodeMarkerShape nodeShapeForType(int type) {
  switch (type) {
    case advTypeChat:
      return NodeMarkerShape.square;
    case advTypeRepeater:
      return NodeMarkerShape.diamond;
    case advTypeRoom:
      return NodeMarkerShape.rectangle;
    case advTypeSensor:
      return NodeMarkerShape.triangle;
    default:
      return NodeMarkerShape.hollowSquare;
  }
}

/// Returns the fill colour for a given node [type].
Color nodeColorForType(int type) {
  switch (type) {
    case advTypeChat:
      return const Color(0xFF00C8FF); // cyan
    case advTypeRepeater:
      return const Color(0xFF39FF14); // green
    case advTypeRoom:
      return const Color(0xFFB967FF); // purple
    case advTypeSensor:
      return const Color(0xFFFFB000); // amber
    default:
      return const Color(0xFF777777); // grey
  }
}

/// Self-marker colour (teal).
const Color _selfColor = Color(0xFF00FFD1);

/// Pixel-mode border colour.
const Color _shapeBorder = Color(0xFF050505);

/// Visual size of pixel shapes in logical pixels.
const double _shapeSize = 14.0;

/// A compact map marker for mesh network nodes.
///
/// In pixel mode the marker draws a distinctive geometric shape (square,
/// diamond, rectangle, triangle, …) so node types are recognisable by both
/// colour AND silhouette.  In non-pixel mode it falls back to a simple filled
/// circle.
class NodeMarkerWidget extends StatelessWidget {
  const NodeMarkerWidget({
    super.key,
    this.type = 0,
    this.opacity = 1.0,
    this.isSelf = false,
    this.usePixelShapes = false,
    this.visualSize = _shapeSize,
    this.highlighted = false,
  });

  /// Node advert type (advTypeChat, advTypeRepeater, …).  Ignored when
  /// [isSelf] is true.
  final int type;

  /// Opacity multiplier for the whole marker (guessed locations, etc.).
  final double opacity;

  /// When true, renders the special self / "you are here" marker.
  final bool isSelf;

  /// When true, draws geometric pixel shapes.  When false, simple circles.
  final bool usePixelShapes;

  /// Diameter of the visual element in logical pixels.
  final double visualSize;

  /// When true, draws a red highlight square behind the marker.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = isSelf ? _selfColor : nodeColorForType(type);
    final shape = isSelf ? NodeMarkerShape.crosshair : nodeShapeForType(type);

    return SizedBox.square(
      dimension: isSelf ? visualSize + 8 : visualSize + 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Highlight ring
          if (highlighted)
            Container(
              width: visualSize + 10,
              height: visualSize + 10,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                border: Border.all(color: SigurdOSPalette.alert, width: 2),
              ),
            ),
          // Main shape
          Opacity(
            opacity: opacity,
            child: usePixelShapes
                ? CustomPaint(
                    size: Size(visualSize, visualSize),
                    painter: NodeShapePainter(
                      shape: isSelf ? NodeMarkerShape.crosshair : shape,
                      fillColor: color,
                      borderColor: _shapeBorder,
                      borderWidth: 2.0,
                    ),
                  )
                : Container(
                    width: visualSize,
                    height: visualSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
          ),
          // Self double-ring
          if (isSelf && usePixelShapes)
            CustomPaint(
              size: Size(visualSize + 6, visualSize + 6),
              painter: NodeShapePainter(
                shape: NodeMarkerShape.hollowSquare,
                fillColor: Colors.transparent,
                borderColor: _selfColor.withValues(alpha: 0.5),
                borderWidth: 1.5,
              ),
            ),
          if (isSelf && !usePixelShapes)
            Container(
              width: visualSize + 6,
              height: visualSize + 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selfColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// CustomPainter that draws a small geometric shape for map markers.
class NodeShapePainter extends CustomPainter {
  const NodeShapePainter({
    required this.shape,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final NodeMarkerShape shape;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.square;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final inset = borderWidth / 2;

    switch (shape) {
      case NodeMarkerShape.circle:
        final center = Offset(w / 2, h / 2);
        final radius = (w / 2) - inset;
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(center, radius, borderPaint);

      case NodeMarkerShape.square:
        final r = RRect.fromLTRBR(
          inset,
          inset,
          w - inset,
          h - inset,
          const Radius.circular(0),
        );
        canvas.drawRRect(r, paint);
        canvas.drawRRect(r, borderPaint);

      case NodeMarkerShape.diamond:
        path.moveTo(w / 2, inset);
        path.lineTo(w - inset, h / 2);
        path.lineTo(w / 2, h - inset);
        path.lineTo(inset, h / 2);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);

      case NodeMarkerShape.rectangle:
        final rw = w * 0.85;
        final rh = h * 0.65;
        final dx = (w - rw) / 2;
        final dy = (h - rh) / 2;
        final r = RRect.fromLTRBR(
          dx + inset,
          dy + inset,
          dx + rw - inset,
          dy + rh - inset,
          const Radius.circular(0),
        );
        canvas.drawRRect(r, paint);
        canvas.drawRRect(r, borderPaint);

      case NodeMarkerShape.triangle:
        path.moveTo(w / 2, inset);
        path.lineTo(w - inset, h - inset);
        path.lineTo(inset, h - inset);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);

      case NodeMarkerShape.hollowSquare:
        final r = RRect.fromLTRBR(
          inset,
          inset,
          w - inset,
          h - inset,
          const Radius.circular(0),
        );
        canvas.drawRRect(r, borderPaint);

      case NodeMarkerShape.crosshair:
        // Vertical bar
        final barW = w * 0.25;
        final barH = h;
        final vBar = RRect.fromLTRBR(
          (w - barW) / 2,
          0,
          (w + barW) / 2,
          barH,
          const Radius.circular(0),
        );
        // Horizontal bar
        final hBar = RRect.fromLTRBR(
          0,
          (h - barW) / 2,
          w,
          (h + barW) / 2,
          const Radius.circular(0),
        );
        canvas.drawRRect(vBar, paint);
        canvas.drawRRect(hBar, paint);
        canvas.drawRRect(vBar, borderPaint);
        canvas.drawRRect(hBar, borderPaint);
    }
  }

  @override
  bool shouldRepaint(NodeShapePainter oldDelegate) =>
      shape != oldDelegate.shape ||
      fillColor != oldDelegate.fillColor ||
      borderColor != oldDelegate.borderColor ||
      borderWidth != oldDelegate.borderWidth;
}
