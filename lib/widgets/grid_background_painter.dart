import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium Grid Background Painter
/// Creates a subtle grid pattern for dark theme backgrounds
/// Grid size: 40x40 pixels with 1px lines
class GridBackgroundPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;
  final double strokeWidth;

  GridBackgroundPainter({
    this.gridSize = 40.0,
    this.gridColor = AppTheme.darkBackgroundGrid,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget wrapper for grid background
/// Use this to wrap any screen content with grid background
class GridBackground extends StatelessWidget {
  final Widget child;
  final double gridSize;
  final Color? gridColor;
  final Color? backgroundColor;

  const GridBackground({
    super.key,
    required this.child,
    this.gridSize = 40.0,
    this.gridColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: backgroundColor ?? (isDark ? AppTheme.darkBackground : AppTheme.backgroundPrimary),
      child: isDark
          ? CustomPaint(
              painter: GridBackgroundPainter(
                gridSize: gridSize,
                gridColor: gridColor ?? AppTheme.darkBackgroundGrid,
              ),
              child: child,
            )
          : child,
    );
  }
}
