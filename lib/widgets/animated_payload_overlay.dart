import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedPayloadOverlay extends StatefulWidget {
  final int step;
  final Animation<double> animation;
  final bool isLargeScreen;
  final List<GlobalKey> stepKeys;
  final List<dynamic> steps; // Use dynamic for now, or import the correct model if available
  const AnimatedPayloadOverlay({required this.step, required this.animation, required this.isLargeScreen, required this.stepKeys, required this.steps, super.key});
  @override
  State<AnimatedPayloadOverlay> createState() => _AnimatedPayloadOverlayState();
}

class _AnimatedPayloadOverlayState extends State<AnimatedPayloadOverlay> {
  List<double> _cardCenters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCardCenters());
  }

  @override
  void didUpdateWidget(covariant AnimatedPayloadOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCardCenters());
  }

  void _updateCardCenters() {
    final centers = <double>[];
    for (final key in widget.stepKeys) {
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        final pos = box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
        centers.add(pos.dy + box.size.height / 2);
      } else {
        centers.add(0);
      }
    }
    setState(() {
      _cardCenters = centers;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cardCenters.length != widget.steps.length || _cardCenters.any((c) => c == 0)) {
      // Not ready yet
      return const SizedBox.shrink();
    }
    final step = widget.step;
    final t = widget.animation.value;
    double startY, endY;
    if (step == 0) {
      startY = _cardCenters[0];
      endY = startY;
    } else {
      startY = _cardCenters[step - 1];
      endY = _cardCenters[step];
    }
    final y = startY + (endY - startY) * t;
    final label = widget.steps[step].payloadLabel;
    final color = widget.steps[step].payloadColor;
    final description = widget.steps[step].description;
    return Positioned(
      left: widget.isLargeScreen ? 20 : 0,
      top: y - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: widget.isLargeScreen ? 80 : 60,
            height: widget.isLargeScreen ? 48 : 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: widget.isLargeScreen ? 16 : 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxWidth: widget.isLargeScreen ? 340 : 200),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: widget.isLargeScreen ? 18 : 10),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.13),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: color, size: widget.isLargeScreen ? 20 : 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: GoogleFonts.notoSans(
                      fontSize: widget.isLargeScreen ? 14 : 11,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 