
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../widgets/premium_app_bar.dart';
// import '../widgets/premium_card.dart';
// import '../widgets/premium_button.dart';
// import '../theme/app_theme.dart';
// import '../navigation/app_router.dart';

// class PayDirectSiDetailScreen extends StatefulWidget {
//   const PayDirectSiDetailScreen({super.key});

//   @override
//   _PayDirectSiDetailScreenState createState() => _PayDirectSiDetailScreenState();
// }

// class _PayDirectSiDetailScreenState extends State<PayDirectSiDetailScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     )..forward();
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _copyToClipboard(String text, String label) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$label copied to clipboard!'),
//         duration: const Duration(seconds: 2),
//         backgroundColor: AppTheme.success,
//       ),
//     );
//   }

//   String _getDynamicDate() {
//     final now = DateTime.now();
//     final oneMonthLater = DateTime(now.year, now.month + 1, now.day);
//     return DateFormat('yyyyMMdd').format(oneMonthLater);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth > 1024;
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
//       appBar: PremiumAppBar(
//         title: 'Standing Instruction - PayDirect',
//         actions: [
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pushNamed(context, AppRouter.paydirectApiReferenceSi);
//             },
//             icon: const Icon(Icons.code, size: 18),
//             label: Text(
//               'API Reference',
//               style: GoogleFonts.inter(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.accent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           padding: EdgeInsets.all(
//             isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16,
//           ),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1200),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Hero Section
//                   _buildHeroSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // What is Standing Instruction
//                   _buildWhatIsSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // Why Use Standing Instruction
//                   _buildWhyUseSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // When to Use
//                   _buildWhenToUseSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // Types of Standing Instructions
//                   _buildTypesSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // Key Features
//                   _buildKeyFeaturesSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // API Reference
//                   _buildApiReferenceSection(context, isLargeScreen, isDark),
//                   const SizedBox(height: AppTheme.spacing48),

//                   // Try Demo CTA
//                   _buildTryDemoCTA(context, isLargeScreen),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeroSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: EdgeInsets.all(
//         isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.warning.withOpacity(0.1),
//             AppTheme.accent.withOpacity(0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(AppTheme.radiusXL),
//         border: Border.all(
//           color: isDark ? AppTheme.darkBorder : AppTheme.borderLight,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(AppTheme.spacing20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppTheme.warning,
//                       AppTheme.warning.withOpacity(0.7),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusLG),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppTheme.warning.withOpacity(0.3),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   Icons.repeat,
//                   size: isLargeScreen ? 48 : 40,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(width: AppTheme.spacing16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Standing Instruction',
//                       style: theme.textTheme.displaySmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.warning,
//                       ),
//                     ),
//                     const SizedBox(height: AppTheme.spacing8),
//                     Text(
//                       'PayDirect',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppTheme.spacing24),
//           Text(
//             'Automate Recurring Payments with Ease',
//             style: theme.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: AppTheme.spacing16),
//           Text(
//             'Standing Instructions enable automated recurring payments with flexible Fixed or Variable schedules. Perfect for subscriptions, memberships, utility bills, and any business model requiring regular automated payments from customers.',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               height: 1.6,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWhatIsSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'What is Standing Instruction?',
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing16),
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Standing Instruction (SI) is a payment method that allows merchants to automatically charge customers on a recurring basis without requiring repeated authorization.',
//                 style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               Text(
//                 'How it works:',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   height: 1.6,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: AppTheme.spacing12),
//               _buildBulletPoint('Customer authorizes recurring payments during the first transaction', isDark),
//               _buildBulletPoint('A mandate is created with payment frequency and amount details', isDark),
//               _buildBulletPoint('Subsequent payments are automatically processed without customer intervention', isDark),
//               _buildBulletPoint('Supports both Fixed (same amount) and Variable (up to max amount) payments', isDark),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWhyUseSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);

//     final reasons = [
//       {
//         'icon': Icons.autorenew,
//         'title': 'Automation',
//         'description': 'Eliminate manual payment collection - payments happen automatically on schedule.',
//       },
//       {
//         'icon': Icons.trending_up,
//         'title': 'Improve Cash Flow',
//         'description': 'Predictable revenue stream with reduced payment failures and missed payments.',
//       },
//       {
//         'icon': Icons.people,
//         'title': 'Better Experience',
//         'description': 'Customers enjoy hassle-free payments without remembering due dates.',
//       },
//       {
//         'icon': Icons.savings,
//         'title': 'Cost Efficient',
//         'description': 'Reduce operational costs associated with manual payment processing and follow-ups.',
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Why Use Standing Instruction?',
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: isLargeScreen ? 2 : 1,
//             crossAxisSpacing: AppTheme.spacing16,
//             mainAxisSpacing: AppTheme.spacing16,
//             childAspectRatio: isLargeScreen ? 2.5 : 3,
//           ),
//           itemCount: reasons.length,
//           itemBuilder: (context, index) {
//             final reason = reasons[index];
//             return PremiumCard(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(AppTheme.spacing12),
//                     decoration: BoxDecoration(
//                       color: AppTheme.warning.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                     ),
//                     child: Icon(
//                       reason['icon'] as IconData,
//                       size: 28,
//                       color: AppTheme.warning,
//                     ),
//                   ),
//                   const SizedBox(width: AppTheme.spacing16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           reason['title'] as String,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: AppTheme.spacing8),
//                         Text(
//                           reason['description'] as String,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             height: 1.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildWhenToUseSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);

//     final useCases = [
//       {
//         'title': 'Subscription Services',
//         'description': 'Perfect for SaaS, streaming platforms, gym memberships - any service with recurring monthly or annual fees.',
//         'icon': Icons.subscriptions,
//         'example': 'Netflix, Spotify, gym memberships',
//       },
//       {
//         'title': 'Utility Bills',
//         'description': 'Automate electricity, water, internet, phone bills with variable amounts up to a maximum limit.',
//         'icon': Icons.bolt,
//         'example': 'Electricity, water, broadband bills',
//       },
//       {
//         'title': 'Insurance Premiums',
//         'description': 'Collect regular insurance premium payments with guaranteed payment dates.',
//         'icon': Icons.health_and_safety,
//         'example': 'Life, health, vehicle insurance',
//       },
//       {
//         'title': 'EMI Payments',
//         'description': 'Automate loan EMI collection with fixed monthly installments.',
//         'icon': Icons.payments,
//         'example': 'Personal loans, consumer financing',
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'When to Use Standing Instruction?',
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),
//         ...useCases.map((useCase) => Padding(
//           padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
//           child: PremiumCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(AppTheme.spacing12),
//                       decoration: BoxDecoration(
//                         color: AppTheme.warning.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                       ),
//                       child: Icon(
//                         useCase['icon'] as IconData,
//                         size: 24,
//                         color: AppTheme.warning,
//                       ),
//                     ),
//                     const SizedBox(width: AppTheme.spacing16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             useCase['title'] as String,
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: AppTheme.spacing8),
//                           Text(
//                             useCase['description'] as String,
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               height: 1.5,
//                             ),
//                           ),
//                           const SizedBox(height: AppTheme.spacing8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: AppTheme.spacing12,
//                               vertical: AppTheme.spacing8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppTheme.accent.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                             ),
//                             child: Text(
//                               'Examples: ${useCase['example']}',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 fontStyle: FontStyle.italic,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         )),
//       ],
//     );
//   }

//   Widget _buildTypesSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Types of Standing Instructions',
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),
        
//         // Fixed SI
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(AppTheme.spacing12),
//                     decoration: BoxDecoration(
//                       color: AppTheme.success.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                     ),
//                     child: Icon(
//                       Icons.calendar_today,
//                       size: 24,
//                       color: AppTheme.success,
//                     ),
//                   ),
//                   const SizedBox(width: AppTheme.spacing16),
//                   Expanded(
//                     child: Text(
//                       'Fixed Standing Instruction',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               Text(
//                 'Charges the same amount on each payment cycle. Ideal for subscriptions with consistent pricing.',
//                 style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
//               ),
//               const SizedBox(height: AppTheme.spacing12),
//               _buildBulletPoint('Fixed amount per payment cycle', isDark),
//               _buildBulletPoint('Set frequency: Weekly, Monthly, Quarterly, etc.', isDark),
//               _buildBulletPoint('Best for: Gym memberships, streaming services, magazine subscriptions', isDark),
//               const SizedBox(height: AppTheme.spacing12),
//               Container(
//                 padding: const EdgeInsets.all(AppTheme.spacing12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.success.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                   border: Border.all(color: AppTheme.success.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.lightbulb_outline, color: AppTheme.success, size: 20),
//                     const SizedBox(width: AppTheme.spacing8),
//                     Expanded(
//                       child: Text(
//                         'Example: ₹999 every month for Netflix subscription',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing16),
        
//         // Variable SI
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(AppTheme.spacing12),
//                     decoration: BoxDecoration(
//                       color: AppTheme.info.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                     ),
//                     child: Icon(
//                       Icons.trending_up,
//                       size: 24,
//                       color: AppTheme.info,
//                     ),
//                   ),
//                   const SizedBox(width: AppTheme.spacing16),
//                   Expanded(
//                     child: Text(
//                       'Variable Standing Instruction',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               Text(
//                 'Allows varying amounts up to a maximum limit. Perfect for utility bills with fluctuating charges.',
//                 style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
//               ),
//               const SizedBox(height: AppTheme.spacing12),
//               _buildBulletPoint('Variable amount up to maximum limit', isDark),
//               _buildBulletPoint('Frequency: On-demand or scheduled', isDark),
//               _buildBulletPoint('Best for: Utility bills, credit card payments, variable charges', isDark),
//               const SizedBox(height: AppTheme.spacing12),
//               Container(
//                 padding: const EdgeInsets.all(AppTheme.spacing12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.info.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                   border: Border.all(color: AppTheme.info.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.lightbulb_outline, color: AppTheme.info, size: 20),
//                     const SizedBox(width: AppTheme.spacing8),
//                     Expanded(
//                       child: Text(
//                         'Example: Up to ₹5,000 for monthly electricity bill',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildKeyFeaturesSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);

//     final features = [
//       'Supports both Fixed and Variable payment types',
//       'Configurable payment frequency (Weekly, Monthly, Quarterly, etc.)',
//       'Set number of payments or indefinite recurring',
//       'Secure JWE/JWS encryption for all transactions',
//       'Mandate management with customer consent',
//       'Automatic payment retry on failure',
//       'Customer notification before each deduction',
//       'Easy mandate cancellation and modification',
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Key Features',
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: features
//                 .map((feature) => Padding(
//                       padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(
//                             Icons.check_circle,
//                             size: 24,
//                             color: AppTheme.success,
//                           ),
//                           const SizedBox(width: AppTheme.spacing12),
//                           Expanded(
//                             child: Text(
//                               feature,
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 height: 1.5,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildApiReferenceSection(BuildContext context, bool isLargeScreen, bool isDark) {
//     final theme = Theme.of(context);
//     final dynamicDate = _getDynamicDate();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'API Reference',
//           style: theme.textTheme.headlineMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),

//         // Endpoint Section
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.link, color: AppTheme.warning, size: 24),
//                   const SizedBox(width: AppTheme.spacing12),
//                   Text(
//                     'Standing Instruction Endpoint',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               Container(
//                 padding: const EdgeInsets.all(AppTheme.spacing16),
//                 decoration: BoxDecoration(
//                   color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F4F6),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                   border: Border.all(
//                     color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: AppTheme.spacing12,
//                         vertical: AppTheme.spacing8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppTheme.success.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(AppTheme.radiusSM),
//                       ),
//                       child: Text(
//                         'POST',
//                         style: GoogleFonts.robotoMono(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: AppTheme.success,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: AppTheme.spacing12),
//                     Expanded(
//                       child: Text(
//                         '/gl/v1/payments/initiate',
//                         style: GoogleFonts.robotoMono(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.copy, size: 20),
//                       onPressed: () => _copyToClipboard(
//                         '/gl/v1/payments/initiate',
//                         'Endpoint',
//                       ),
//                       tooltip: 'Copy endpoint',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),

//         // Fixed SI Request
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: AppTheme.success.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.calendar_today, color: AppTheme.success, size: 20),
//                   ),
//                   const SizedBox(width: AppTheme.spacing12),
//                   Text(
//                     'Fixed SI Request Body',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               Container(
//                 padding: const EdgeInsets.all(AppTheme.spacing16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1F2937),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'JSON',
//                           style: GoogleFonts.robotoMono(
//                             fontSize: 12,
//                             color: const Color(0xFF9CA3AF),
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.copy, size: 18, color: Color(0xFF9CA3AF)),
//                           onPressed: () => _copyToClipboard(
//                             '{\n  "merchantTxnId": "23AEE8CB6B62EE2AF07",\n  "paymentData": {\n    "totalAmount": "89",\n    "txnCurrency": "INR"\n  },\n  "standingInstruction": {\n    "data": {\n      "amount": "1250.00",\n      "numberOfPayments": "4",\n      "frequency": "MONTHLY",\n      "type": "FIXED",\n      "startDate": "$dynamicDate"\n    }\n  },\n  "merchantCallbackURL": "https://yourdomain.com/callback"\n}',
//                             'Fixed SI payload',
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     SelectableText(
//                       '{\n  "merchantTxnId": "23AEE8CB6B62EE2AF07",\n  "paymentData": {\n    "totalAmount": "89",\n    "txnCurrency": "INR",\n    "cardData": {\n      "number": "5132552222223470",\n      "expiryMonth": "12",\n      "expiryYear": "2030",\n      "securityCode": "123"\n    }\n  },\n  "standingInstruction": {\n    "data": {\n      "amount": "1250.00",\n      "numberOfPayments": "4",\n      "frequency": "MONTHLY",\n      "type": "FIXED",\n      "startDate": "$dynamicDate"\n    }\n  },\n  "merchantCallbackURL": "https://yourdomain.com/callback"\n}',
//                       style: GoogleFonts.robotoMono(
//                         fontSize: 13,
//                         color: Colors.white,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),

//         // Variable SI Request
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: AppTheme.info.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.trending_up, color: AppTheme.info, size: 20),
//                   ),
//                   const SizedBox(width: AppTheme.spacing12),
//                   Text(
//                     'Variable SI Request Body',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               Container(
//                 padding: const EdgeInsets.all(AppTheme.spacing16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1F2937),
//                   borderRadius: BorderRadius.circular(AppTheme.radiusMD),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'JSON',
//                           style: GoogleFonts.robotoMono(
//                             fontSize: 12,
//                             color: const Color(0xFF9CA3AF),
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.copy, size: 18, color: Color(0xFF9CA3AF)),
//                           onPressed: () => _copyToClipboard(
//                             '{\n  "merchantTxnId": "23AEE8CB6B62EE2AF07",\n  "paymentData": {\n    "totalAmount": "89",\n    "txnCurrency": "INR"\n  },\n  "standingInstruction": {\n    "data": {\n      "maxAmount": "1250.00",\n      "numberOfPayments": "4",\n      "frequency": "ONDEMAND",\n      "type": "VARIABLE",\n      "startDate": "$dynamicDate"\n    }\n  },\n  "merchantCallbackURL": "https://yourdomain.com/callback"\n}',
//                             'Variable SI payload',
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     SelectableText(
//                       '{\n  "merchantTxnId": "23AEE8CB6B62EE2AF07",\n  "paymentData": {\n    "totalAmount": "89",\n    "txnCurrency": "INR",\n    "cardData": {\n      "number": "5132552222223470",\n      "expiryMonth": "12",\n      "expiryYear": "2030",\n      "securityCode": "123"\n    }\n  },\n  "standingInstruction": {\n    "data": {\n      "maxAmount": "1250.00",\n      "numberOfPayments": "4",\n      "frequency": "ONDEMAND",\n      "type": "VARIABLE",\n      "startDate": "$dynamicDate"\n    }\n  },\n  "merchantCallbackURL": "https://yourdomain.com/callback"\n}',
//                       style: GoogleFonts.robotoMono(
//                         fontSize: 13,
//                         color: Colors.white,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing24),

//         // Parameters
//         PremiumCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Key Parameters',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: AppTheme.spacing16),
//               _buildParameterItem('standingInstruction.data.type', 'string', 'SI type: FIXED or VARIABLE', true),
//               _buildParameterItem('standingInstruction.data.amount', 'string', 'Fixed amount per cycle (for FIXED type)', false),
//               _buildParameterItem('standingInstruction.data.maxAmount', 'string', 'Maximum amount per cycle (for VARIABLE type)', false),
//               _buildParameterItem('standingInstruction.data.frequency', 'string', 'Payment frequency: WEEKLY, MONTHLY, QUARTERLY, etc.', true),
//               _buildParameterItem('standingInstruction.data.numberOfPayments', 'string', 'Total number of payments', true),
//               _buildParameterItem('standingInstruction.data.startDate', 'string', 'Start date in YYYYMMDD format', true),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTryDemoCTA(BuildContext context, bool isLargeScreen) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: EdgeInsets.all(
//         isLargeScreen ? AppTheme.spacing48 : AppTheme.spacing32,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppTheme.warning.withOpacity(0.9),
//             AppTheme.warning,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(AppTheme.radiusXL),
//         boxShadow: AppTheme.shadowLG,
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.rocket_launch,
//             size: isLargeScreen ? 56 : 48,
//             color: Colors.white,
//           ),
//           const SizedBox(height: AppTheme.spacing24),
//           Text(
//             'Ready to Try Standing Instruction?',
//             style: theme.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: AppTheme.spacing16),
//           Text(
//             'Test both Fixed and Variable SI types in our interactive demo. See how easy it is to set up automated recurring payments.',
//             style: theme.textTheme.bodyLarge?.copyWith(
//               color: Colors.white.withOpacity(0.9),
//               height: 1.6,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (isLargeScreen) ...[
//                 PremiumButton(
//                   label: 'Try Demo Now',
//                   icon: Icons.play_arrow,
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/paydirect/si');
//                   },
//                   buttonStyle: PremiumButtonStyle.primary,
//                 ),
//                 const SizedBox(width: AppTheme.spacing16),
//                 PremiumButton(
//                   label: 'View API Reference',
//                   icon: Icons.api,
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/paydirect-api-reference-si');
//                   },
//                   buttonStyle: PremiumButtonStyle.secondary,
//                 ),
//               ] else ...[
//                 Expanded(
//                   child: Column(
//                     children: [
//                       PremiumButton(
//                         label: 'Try Demo Now',
//                         icon: Icons.play_arrow,
//                         onPressed: () {
//                           Navigator.pushNamed(context, '/paydirect/si');
//                         },
//                         buttonStyle: PremiumButtonStyle.primary,
//                         isFullWidth: true,
//                       ),
//                       const SizedBox(height: AppTheme.spacing12),
//                       PremiumButton(
//                         label: 'View API Reference',
//                         icon: Icons.api,
//                         onPressed: () {
//                           Navigator.pushNamed(context, '/paydirect-api-reference-si');
//                         },
//                         buttonStyle: PremiumButtonStyle.secondary,
//                         isFullWidth: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBulletPoint(String text, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.arrow_right,
//             size: 20,
//             color: AppTheme.warning,
//           ),
//           const SizedBox(width: AppTheme.spacing8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 15,
//                 height: 1.5,
//                 color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildParameterItem(String name, String type, String description, bool isRequired) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: GoogleFonts.robotoMono(
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.warning,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   type,
//                   style: GoogleFonts.robotoMono(
//                     fontSize: 11,
//                     color: AppTheme.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: AppTheme.spacing16),
//           if (isRequired)
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: AppTheme.error.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 'Required',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.error,
//                 ),
//               ),
//             ),
//           const SizedBox(width: AppTheme.spacing16),
//           Expanded(
//             flex: 3,
//             child: Text(
//               description,
//               style: const TextStyle(
//                 fontSize: 13,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

