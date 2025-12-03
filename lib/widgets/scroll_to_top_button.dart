import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showAfterScroll;
  final Color? backgroundColor;
  final Color? iconColor;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    this.showAfterScroll = 400.0,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton>
    with SingleTickerProviderStateMixin {
  bool _showButton = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController.hasClients) {
      final shouldShow = widget.scrollController.offset > widget.showAfterScroll;
      if (shouldShow != _showButton) {
        setState(() {
          _showButton = shouldShow;
          if (_showButton) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _showButton
          ? Positioned(
              right: 24,
              bottom: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: _scrollToTop,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ??
                          (isDark ? AppTheme.darkSurfaceElevated : Colors.white),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: widget.iconColor ??
                          (isDark ? Colors.white70 : AppTheme.accent),
                      size: 28,
                    ),
                    ),
                  ),
                ),
              ),
            )
        : const SizedBox.shrink();
  }
}

