import 'package:flutter/material.dart';
import '../screen/welcome_screen.dart';
import '../screen/paycollect_screen.dart';
import '../screen/paydirect_screen.dart';
import '../screen/paycollect_docs_screen.dart';
import '../screen/paydirect_docs_screen.dart';
import '../screen/services_screen.dart';
import '../screen/sdks_screen.dart';
import '../screen/visualization_screen.dart';
import '../screen/merchant_product_interface.dart';
import '../screen/ott_subscription_checkout.dart';
import '../screen/airline_interface.dart';
import '../screen/standing_instruction.dart';
import '../screen/bill_Payment.dart';
import '../screen/pd_standing_instruction.dart';
import '../screen/payglocal_codedrop_screen.dart';
import '../screen/payment_success_screen.dart';
import '../screen/payment_failure_screen.dart';
import '../screen/jwt_services_screen.dart';
import '../screen/si_services_screen.dart';
import '../screen/auth_services_screen.dart';
import '../screen/payload_screen.dart';
import '../screen/getting_started_screen.dart';
import '../screen/api_reference_screen.dart';
import '../screen/testing_guide_screen.dart';
import '../screen/product_comparison_screen.dart';
import '../screen/troubleshooting_screen.dart';
import '../screen/webhooks_screen.dart';
import '../screen/webhooks_documentation_screen.dart';
import '../screen/payment_response_handling_screen.dart';
import '../screen/overview_screen.dart';
import '../screen/paycollect_jwt_detail_screen.dart';
// import '../screen/paycollect_si_detail_screen.dart'; // File doesn't exist, using unified docs instead
import '../screen/paycollect_si_unified_docs_screen.dart';
import '../screen/paycollect_api_reference_screen.dart';
import '../screen/paycollect_api_reference_jwt_screen.dart';
import '../screen/paycollect_auth_detail_screen.dart';
import '../screen/paycollect_si_api_reference.dart';
import '../screen/paycollect_auth_api_reference.dart';
import '../screen/paydirect_jwt_detail_screen.dart';
import '../screen/paydirect_si_detail_screen.dart';
import '../screen/paydirect_auth_detail_screen.dart';
import '../screen/api_credentials_screen.dart';
import '../widgets/universal_scaffold.dart';

class AppRouter {
  static const String home = '/';
  static const String welcome = '/welcome';
  static const String paycollect = '/paycollect';
  static const String paydirect = '/paydirect';
  static const String paycollectDocs = '/paycollect-docs';
  static const String paydirectDocs = '/paydirect-docs';
  static const String services = '/services';
  static const String sdks = '/sdks';
  static const String visualization = '/visualization';
  static const String payload = '/payload';
  static const String checkout = '/checkout';
  static const String codedrop = '/payglocal-codedrop';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailure = '/payment-failure';
  static const String jwtServices = '/services/jwt';
  static const String siServices = '/services/si';
  static const String authServices = '/services/auth';
  
  // Documentation routes
  static const String overview = '/overview';
  static const String gettingStarted = '/getting-started';
  static const String apiReference = '/api-reference';
  static const String apiCredentials = '/api-credentials';
  static const String testingGuide = '/testing-guide';
  static const String productComparison = '/product-comparison';
  static const String troubleshooting = '/troubleshooting';
  static const String webhooks = '/webhooks';
  static const String webhooksDocumentation = '/webhooks-documentation';
  static const String paymentResponseHandling = '/payment-response-handling';
  
  // PayCollect routes
  static const String paycollectJwt = '/paycollect/jwt';
  static const String paycollectAuth = '/paycollect/auth';
  static const String paycollectOtt = '/paycollect/ott_subscription_checkout';
  static const String paycollectAirline = '/paycollect/airline';
  static const String paycollectBill = '/paycollect/bill_payment';
  
  // PayCollect Detail routes
  static const String paycollectJwtDetail = '/paycollect-jwt-detail';
  static const String paycollectSiDetail = '/paycollect-si-detail';
  static const String paycollectApiReference = '/paycollect-api-reference';
  static const String paycollectApiReferenceJwt = '/paycollect-api-reference-jwt';
  static const String paycollectApiReferenceSi = '/paycollect-api-reference-si';
  static const String paycollectApiReferenceAuth = '/paycollect-api-reference-auth';
  static const String paycollectAuthDetail = '/paycollect-auth-detail';
  
  // PayCollect Demo routes
  static const String paycollectSubscriptionExample = '/paycollect-subscription-example';
  static const String paycollectBillPaymentExample = '/paycollect-bill-payment-example';
  
  // PayDirect routes
  static const String paydirectJwt = '/paydirect/jwt';
  static const String paydirectOtt = '/paydirect/ott_subscription_checkout';
  static const String paydirectAirline = '/paydirect/airline';
  static const String paydirectBill = '/paydirect/bill_payment';
  static const String paydirectSi = '/paydirect/si';
  
  // PayDirect Detail routes
  static const String paydirectJwtDetail = '/paydirect-jwt-detail';
  static const String paydirectSiDetail = '/paydirect-si-detail';
  static const String paydirectAuthDetail = '/paydirect-auth-detail';
  
  // Standing Instruction routes
  static const String standingInstruction = '/standing_instruction';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String name = settings.name ?? home;
    final Uri uri = Uri.parse(name);
    switch (uri.path) {
      case home:
        return _buildRoute(const WelcomeScreen(), settings);
      
      case welcome:
        return _buildRoute(const WelcomeScreen(), settings);
      
      case paycollect:
        return _wrapWithUniversal(const PayCollectScreen(), settings, name);
      
      case paydirect:
        return _wrapWithUniversal(const PayDirectScreen(), settings, name);
      
      case paycollectDocs:
        return _wrapWithUniversal(const PayCollectDocsScreen(), settings, name);
      
      case paydirectDocs:
        return _wrapWithUniversal(const PayDirectDocsScreen(), settings, name);
      
      case services:
        return _wrapWithUniversal(const ServicesScreen(), settings, name);
      
      case sdks:
        return _wrapWithUniversal(const SDKsScreen(), settings, name);
      
      case visualization: {
        final String? stepStr = uri.queryParameters['step'];
        final int? initialStep = int.tryParse(stepStr ?? '');
        return _wrapWithUniversal(VisualizationScreen(initialStep: initialStep), settings, name);
      }
      
      case payload:
        return _wrapWithUniversal(const PayloadScreen(), settings, name);
      
      case checkout:
        return _buildRoute(const CheckoutScreen(), settings);
      
      case codedrop:
        return _wrapWithUniversal(
          PayGlocalCodedropScreen(
            paymentData: settings.arguments as Map<String, dynamic>? ?? {
              'amount': 1000,
              'currency': 'INR',
              'merchantTxnId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
              'customerId': 'CUST_123',
            },
          ),
          settings,
          name,
        );
      case paymentSuccess: {
        final queryParams = uri.queryParameters;
        return _buildRoute(
          PaymentSuccessScreen(
            txnId: queryParams['txnId'],
            amount: queryParams['amount'],
            status: queryParams['status'],
            gid: queryParams['gid'],
            paymentMethod: queryParams['paymentMethod'],
          ),
          settings,
        );
      }
      case paymentFailure: {
        final queryParams = uri.queryParameters;
        return _buildRoute(
          PaymentFailureScreen(
            reason: queryParams['reason'] ?? (settings.arguments as String?),
            txnId: queryParams['txnId'],
            status: queryParams['status'],
          ),
          settings,
        );
      }
      
      case jwtServices:
        return _wrapWithUniversal(const JwtServicesScreen(), settings, name);
      case siServices:
        return _wrapWithUniversal(const SiServicesScreen(), settings, name);
      case authServices:
        return _wrapWithUniversal(const AuthServicesScreen(), settings, name);
      
      // Documentation routes
      case overview:
        return _wrapWithUniversal(const OverviewScreen(), settings, name);
      
      case gettingStarted:
        return _wrapWithUniversal(const GettingStartedScreen(), settings, name);
      
      case apiReference:
        return _wrapWithUniversal(const ApiReferenceScreen(), settings, name);
      
      case apiCredentials:
        return _wrapWithUniversal(const ApiCredentialsScreen(), settings, name);
      
      case testingGuide:
        return _wrapWithUniversal(const TestingGuideScreen(), settings, name);
      
      case productComparison:
        return _wrapWithUniversal(const ProductComparisonScreen(), settings, name);
      
      case troubleshooting:
        return _wrapWithUniversal(const TroubleshootingScreen(), settings, name);
      
      case webhooks:
        return _wrapWithUniversal(const WebhooksScreen(), settings, name);

      case webhooksDocumentation:
        return _wrapWithUniversal(const WebhooksDocumentationScreen(), settings, name);

      case paymentResponseHandling:
        return _wrapWithUniversal(const PaymentResponseHandlingScreen(), settings, name);

      // PayCollect Detail routes
      case paycollectJwtDetail:
        return _wrapWithUniversal(const PayCollectJwtDetailScreen(), settings, name);
      
      case paycollectSiDetail:
        return _wrapWithUniversal(const PayCollectSiUnifiedDocsScreen(), settings, name);
      
      case paycollectApiReference:
        return _wrapWithUniversal(const PayCollectAPIReferenceScreen(), settings, name);
      
      case paycollectApiReferenceJwt:
        return _wrapWithUniversal(const PayCollectJWTAPIReferenceScreen(), settings, name);
      
      case paycollectApiReferenceSi:
        return _wrapWithUniversal(const PayCollectSiApiReferenceScreen(), settings, name);
      
      case paycollectApiReferenceAuth:
        return _wrapWithUniversal(const PayCollectAuthApiReferenceScreen(), settings, name);
      
      case paycollectAuthDetail:
        return _wrapWithUniversal(const PayCollectAuthDetailScreen(), settings, name);
      
      // PayCollect Demo routes
      case paycollectSubscriptionExample:
        return _buildRoute(
          const OttSubscriptionCheckoutScreen(isPayDirect: false),
          settings,
        );
      case paycollectBillPaymentExample:
        return _buildRoute(
          const BillPaymentScreen(isPayDirect: false),
          settings,
        );
      
      // PayDirect Detail routes
      case paydirectJwtDetail:
        return _wrapWithUniversal(const PayDirectJwtDetailScreen(), settings, name);
      
      case paydirectSiDetail:
        return _wrapWithUniversal(const PayDirectSiDetailScreen(), settings, name);
      
      case paydirectAuthDetail:
        return _wrapWithUniversal(const PayDirectAuthDetailScreen(), settings, name);
      
      // PayCollect routes
      case paycollectJwt:
        return _buildRoute(
          const clothingMerchantInterface(isPayDirect: false),
          settings,
        );
      
      case paycollectAuth:
        return _buildRoute(
          const clothingMerchantInterface(isPayDirect: false),
          settings,
        );
      
      case paycollectOtt:
        return _buildRoute(
          const OttSubscriptionCheckoutScreen(isPayDirect: false),
          settings,
        );
      
      case paycollectAirline:
        return _buildRoute(
          const AirlineBookingPage(isPayDirect: false),
          settings,
        );
      
      case paycollectBill:
        return _buildRoute(
          const BillPaymentScreen(isPayDirect: false),
          settings,
        );
      
      // PayDirect routes
      case paydirectJwt:
        return _buildRoute(
          const clothingMerchantInterface(isPayDirect: true),
          settings,
        );
      
      case paydirectOtt:
        return _buildRoute(
          const OttSubscriptionCheckoutScreen(isPayDirect: true),
          settings,
        );
      
      case paydirectAirline:
        return _buildRoute(
          const AirlineBookingPage(isPayDirect: true),
          settings,
        );
      
      case paydirectBill:
        return _buildRoute(
          const BillPaymentScreen(isPayDirect: true),
          settings,
        );
      
      case paydirectSi:
        return _wrapWithUniversal(
          const PdStandingInstructionScreen(),
          settings,
          name,
        );
      
      case standingInstruction:
        return _wrapWithUniversal(
          const StandingInstructionScreen(),
          settings,
          name,
        );
      
      default:
        return _wrapWithUniversal(
          const NotFoundScreen(),
          settings,
          name,
        );
    }
  }

  // Wraps with UniversalScaffold on non-merchant website interfaces
  static PageRouteBuilder _wrapWithUniversal(Widget child, RouteSettings settings, String routeName) {
    const merchantInterfaceRoutes = <String>{
      AppRouter.paycollectJwt,
      AppRouter.paycollectOtt,
      AppRouter.paycollectAirline,
      AppRouter.paycollectBill,
      AppRouter.paydirectJwt,
      AppRouter.paydirectOtt,
      AppRouter.paydirectAirline,
      AppRouter.paydirectBill,
    };

    final bool exclude = merchantInterfaceRoutes.contains(routeName);

    if (exclude) {
      return _buildRoute(child, settings);
    }

    return _buildRoute(
      _UniversalWrapper(currentRoute: routeName, child: child),
      settings,
    );
  }

  static PageRouteBuilder _buildRoute(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition for better performance and smoother feel
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }
}

class _UniversalWrapper extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const _UniversalWrapper({required this.child, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UniversalScaffold(
        currentRoute: currentRoute,
        child: child,
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: const Color(0xFF1A3C34),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.home,
                (route) => false,
              ),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
