import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CodeHighlightWidget extends StatefulWidget {
  final String code;
  final String language;
  final String? title;
  final bool showCopyButton;
  final bool initiallyExpanded;

  const CodeHighlightWidget({
    super.key,
    required this.code,
    this.language = 'json',
    this.title,
    this.showCopyButton = true,
    this.initiallyExpanded = false,
  });

  @override
  State<CodeHighlightWidget> createState() => _CodeHighlightWidgetState();
}

class _CodeHighlightWidgetState extends State<CodeHighlightWidget> {
  bool _isExpanded = false;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _copyToClipboard() {
    // In a real implementation, you would use Clipboard.setData
    setState(() {
      _isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.surfacePrimary,
        borderRadius: BorderRadius.circular(AppTheme.spacing12),
        border: Border.all(
          color: isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? AppTheme.darkSurfaceElevated 
                  : AppTheme.surfacePrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.spacing12),
                topRight: Radius.circular(AppTheme.spacing12),
              ),
            ),
            child: Row(
              children: [
                if (widget.title != null) ...[
                  Icon(
                    Icons.code,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    widget.title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode 
                          ? AppTheme.darkTextPrimary 
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                ],
                if (widget.showCopyButton)
                  Semantics(
                    label: 'Copy code to clipboard',
                    button: true,
                    child: InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(AppTheme.spacing8),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacing8),
                        child: Icon(
                          _isCopied ? Icons.check : Icons.copy,
                          size: 18,
                          color: _isCopied 
                              ? Colors.green 
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: AppTheme.spacing8),
                Semantics(
                  label: _isExpanded ? 'Collapse code' : 'Expand code',
                  button: true,
                  child: InkWell(
                    onTap: _toggleExpanded,
                    borderRadius: BorderRadius.circular(AppTheme.spacing8),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacing8),
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Code content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            firstChild: Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Text(
                widget.code.length > 200 
                    ? '${widget.code.substring(0, 200)}...'
                    : widget.code,
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  color: isDarkMode 
                      ? AppTheme.darkTextSecondary 
                      : AppTheme.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  widget.code,
                  style: GoogleFonts.firaCode(
                    fontSize: 13,
                    color: isDarkMode 
                        ? AppTheme.darkTextPrimary 
                        : AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
