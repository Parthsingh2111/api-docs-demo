import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalSearchWidget extends StatefulWidget {
  const GlobalSearchWidget({super.key});

  @override
  _GlobalSearchWidgetState createState() => _GlobalSearchWidgetState();
}

class _GlobalSearchWidgetState extends State<GlobalSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  List<SearchResult> _results = [];

  // Search index with all documentation content
  final List<Map<String, dynamic>> _searchIndex = [
    {
      'title': 'Getting Started',
      'description': 'Quick setup guide and integration steps',
      'route': '/getting-started',
      'keywords': ['setup', 'start', 'begin', 'integration', 'install', 'quick', 'guide'],
    },
    {
      'title': 'API Reference',
      'description': 'Complete API documentation with endpoints',
      'route': '/api-reference',
      'keywords': ['api', 'endpoint', 'reference', 'documentation', 'request', 'response'],
    },
    {
      'title': 'Testing Guide',
      'description': 'Test cards and sandbox environment',
      'route': '/testing-guide',
      'keywords': ['test', 'sandbox', 'cards', 'testing', 'development', 'debug'],
    },
    {
      'title': 'PayCollect',
      'description': 'Hosted payment page solution',
      'route': '/paycollect',
      'keywords': ['paycollect', 'hosted', 'payment', 'page', 'collect', 'pci'],
    },
    {
      'title': 'PayDirect',
      'description': 'Direct API integration for PCI certified merchants',
      'route': '/paydirect',
      'keywords': ['paydirect', 'direct', 'api', 'custom', 'integration', 'pci'],
    },
    {
      'title': 'Product Comparison',
      'description': 'Compare PayDirect and PayCollect features',
      'route': '/product-comparison',
      'keywords': ['compare', 'comparison', 'difference', 'features', 'vs'],
    },
    {
      'title': 'Troubleshooting',
      'description': 'Common issues and solutions',
      'route': '/troubleshooting',
      'keywords': ['error', 'issue', 'problem', 'fix', 'troubleshoot', 'debug', 'help'],
    },
    {
      'title': 'Webhooks',
      'description': 'Real-time payment notifications',
      'route': '/webhooks',
      'keywords': ['webhook', 'callback', 'notification', 'event', 'realtime'],
    },
    {
      'title': 'SDKs',
      'description': 'Download SDKs for your platform',
      'route': '/sdks',
      'keywords': ['sdk', 'library', 'package', 'nodejs', 'java', 'php', 'csharp', 'download'],
    },
    {
      'title': 'Services',
      'description': 'Additional payment services',
      'route': '/services',
      'keywords': ['services', 'additional', 'features', 'tools'],
    },
    {
      'title': 'Visualization',
      'description': 'Interactive payment flow diagrams',
      'route': '/visualization',
      'keywords': ['visualization', 'diagram', 'flow', 'interactive', 'visual'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    final results = <SearchResult>[];
    for (final item in _searchIndex) {
      final title = (item['title'] as String).toLowerCase();
      final description = (item['description'] as String).toLowerCase();
      final keywords = (item['keywords'] as List<String>);

      // Calculate relevance score
      int score = 0;
      if (title.contains(query)) score += 10;
      if (description.contains(query)) score += 5;
      for (final keyword in keywords) {
        if (keyword.contains(query)) score += 3;
      }

      if (score > 0) {
        results.add(SearchResult(
          title: item['title'] as String,
          description: item['description'] as String,
          route: item['route'] as String,
          score: score,
        ));
      }
    }

    // Sort by score
    results.sort((a, b) => b.score.compareTo(a.score));

    setState(() {
      _results = results.take(5).toList();
    });
  }

  void _navigateToResult(String route) {
    Navigator.pushNamed(context, route);
    setState(() {
      _searchController.clear();
      _results = [];
      _isExpanded = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
          _focusNode.requestFocus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isExpanded ? 400 : 50,
        child: Stack(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isExpanded
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    color: _isExpanded
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF64748B),
                    size: 20,
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search documentation...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                        color: const Color(0xFF64748B),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                          _searchController.clear();
                          _results = [];
                        });
                        _focusNode.unfocus();
                      },
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ],
              ),
            ),
            if (_isExpanded && _results.isNotEmpty)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return InkWell(
                        onTap: () => _navigateToResult(result.route),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.article,
                                      size: 16,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      result.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Text(
                                  result.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SearchResult {
  final String title;
  final String description;
  final String route;
  final int score;

  SearchResult({
    required this.title,
    required this.description,
    required this.route,
    required this.score,
  });
}

