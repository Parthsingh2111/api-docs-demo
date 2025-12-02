import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocNavigation extends StatelessWidget {
  final String currentRoute;

  const DocNavigation({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final docSections = [
      {
        'title': 'Getting Started',
        'icon': Icons.rocket_launch,
        'items': [
          {'label': 'Overview', 'route': '/overview'},
          {'label': 'Product Comparison', 'route': '/product-comparison'},
          {'label': 'Quick Start', 'route': '/getting-started'},
        ],
      },
      {
        'title': 'Products',
        'icon': Icons.payment,
        'items': [
          {'label': 'PayCollect', 'route': '/paycollect'},
          {'label': 'PayDirect', 'route': '/paydirect'},
        ],
      },
      {
        'title': 'Integration',
        'icon': Icons.code,
        'items': [
          {'label': 'API Reference', 'route': '/api-reference'},
          {'label': 'SDKs', 'route': '/sdks'},
          {'label': 'Webhooks', 'route': '/webhooks'},
        ],
      },
      {
        'title': 'Testing & Support',
        'icon': Icons.science,
        'items': [
          {'label': 'Testing Guide', 'route': '/testing-guide'},
          {'label': 'Troubleshooting', 'route': '/troubleshooting'},
        ],
      },
      {
        'title': 'Services',
        'icon': Icons.settings,
        'items': [
          {'label': 'All Services', 'route': '/services'},
          {'label': 'Visualization', 'route': '/visualization'},
        ],
      },
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Documentation',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docSections.length,
              itemBuilder: (context, index) {
                final section = docSections[index];
                return _buildSection(
                  context,
                  section['title'] as String,
                  section['icon'] as IconData,
                  section['items'] as List<Map<String, String>>,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Column(
              children: [
                _buildFooterButton(
                  context,
                  'View All Docs',
                  Icons.home,
                  '/',
                ),
                const SizedBox(height: 8),
                _buildFooterButton(
                  context,
                  'API Playground',
                  Icons.play_arrow,
                  '/paycollect',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Map<String, String>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildNavItem(
              context,
              item['label']!,
              item['route']!,
            )),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String label, String route) {
    final isActive = currentRoute == route;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B82F6).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: const Color(0xFF3B82F6))
              : null,
        ),
        child: Row(
          children: [
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
            if (isActive) const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF475569),
                ),
              ),
            ),
            if (isActive)
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFF3B82F6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton(
      BuildContext context, String label, IconData icon, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const DocBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/overview');
            },
            child: Row(
              children: [
                const Icon(Icons.home, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < items.length; i++) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right,
                  size: 16, color: Color(0xFF94A3B8)),
            ),
            if (i == items.length - 1)
              Text(
                items[i].label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              )
            else
              InkWell(
                onTap: items[i].route != null
                    ? () => Navigator.pushNamed(context, items[i].route!)
                    : null,
                child: Text(
                  items[i].label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final String? route;

  BreadcrumbItem({required this.label, this.route});
}

class NextStepButton extends StatelessWidget {
  final String label;
  final String description;
  final String route;
  final IconData icon;

  const NextStepButton({
    super.key,
    required this.label,
    required this.description,
    required this.route,
    this.icon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Step',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class DocLayout extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  final List<BreadcrumbItem>? breadcrumbs;

  const DocLayout({
    super.key,
    required this.currentRoute,
    required this.child,
    this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth > 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          if (showSidebar) DocNavigation(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
                  DocBreadcrumbs(items: breadcrumbs!),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: !showSidebar
          ? Drawer(
              child: DocNavigation(currentRoute: currentRoute),
            )
          : null,
    );
  }
}

