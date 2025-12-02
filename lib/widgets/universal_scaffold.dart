import 'package:flutter/material.dart';
import '../widgets/comprehensive_navigation.dart';

class UniversalScaffold extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const UniversalScaffold({super.key, required this.child, required this.currentRoute});

  @override
  State<UniversalScaffold> createState() => _UniversalScaffoldState();
}

class _UniversalScaffoldState extends State<UniversalScaffold> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLarge = screenWidth >= 1200;

    if (!isLarge) {
      // For tablet/mobile, leave the page as-is to avoid nesting/drawer conflicts
      return widget.child;
    }

    return Row(
      children: [
        ComprehensiveNavigation(
          currentRoute: widget.currentRoute,
          onNavigate: (route) => Navigator.pushNamed(context, route),
          isCollapsed: _isCollapsed,
          showToggleButton: true,
          onToggle: () {
            setState(() => _isCollapsed = !_isCollapsed);
          },
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}


