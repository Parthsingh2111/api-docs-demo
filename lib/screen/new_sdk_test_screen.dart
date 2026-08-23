import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../utils/logger.dart';
import '../widgets/premium_app_bar.dart';

/// A test bench for the simple PayGlocal SDK (backend/payglocal-sdk-simple).
///
/// Three things happen on this page, in the order you would do them by hand:
///
///   1. Check the backend can load the SDK and read its keys at all.
///   2. Start a payment and open PayGlocal's hosted page.
///   3. Ask PayGlocal what happened to it.
///
/// Every raw response is shown, because the point of this page is to see what
/// the SDK actually returned rather than a summary of it.
class NewSdkTestScreen extends StatefulWidget {
  const NewSdkTestScreen({super.key});

  @override
  State<NewSdkTestScreen> createState() => _NewSdkTestScreenState();
}

class _NewSdkTestScreenState extends State<NewSdkTestScreen> {
  final _amountController = TextEditingController(text: '10.00');
  final _emailController = TextEditingController(text: 'test.customer@example.com');
  final _transactionIdController = TextEditingController();

  String _currency = 'INR';
  static const _currencies = ['INR', 'USD', 'GBP', 'EUR', 'AED', 'SGD'];

  /// Whichever call is in flight, so only that button shows a spinner.
  String? _busy;

  _Health? _health;
  String? _paymentLink;
  final List<_LogEntry> _log = [];

  @override
  void initState() {
    super.initState();
    // Worth knowing before you press anything else: if the keys are missing,
    // every other button on this page fails the same way.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkHealth());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  void _record(String title, {required bool ok, required String body}) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, _LogEntry(title: title, ok: ok, body: body, at: DateTime.now()));
    });
  }

  String _pretty(String source) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(source));
    } catch (_) {
      return source;
    }
  }

  // --- 1. Is the SDK loadable? ----------------------------------------------

  Future<void> _checkHealth() async {
    setState(() => _busy = 'health');
    try {
      final response = await http
          .get(Uri.parse(AppConfig.sdkSimpleHealthUrl))
          .timeout(AppConfig.apiTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final ok = response.statusCode == 200;

      setState(() {
        _health = ok
            ? _Health(
                environment: body['environment'] as String? ?? '-',
                merchantId: body['merchantId'] as String? ?? '-',
                publicKeyId: body['publicKeyId'] as String? ?? '-',
                privateKeyId: body['privateKeyId'] as String? ?? '-',
                keysFrom: body['keysFrom'] as String? ?? '-',
                origin: body['origin'] as String? ?? '-',
              )
            : null;
      });

      _record(
        ok ? 'SDK loaded' : 'SDK failed to load',
        ok: ok,
        body: _pretty(response.body),
      );
    } catch (error) {
      setState(() => _health = null);
      _record('SDK failed to load', ok: false, body: '$error');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  // --- 2. Start a payment ---------------------------------------------------

  Future<void> _initiate() async {
    final amount = _amountController.text.trim();
    if (amount.isEmpty || double.tryParse(amount) == null) {
      _record('Not sent', ok: false, body: 'Amount must be a number, for example 10.00');
      return;
    }

    setState(() {
      _busy = 'initiate';
      _paymentLink = null;
    });

    try {
      Logger.payment('Initiating payment through the simple SDK', {
        'amount': amount,
        'currency': _currency,
      });

      final response = await http
          .post(
            Uri.parse(AppConfig.sdkSimpleInitiateUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount,
              'currency': _currency,
              'email': _emailController.text.trim(),
            }),
          )
          .timeout(AppConfig.apiTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['payment_link'] != null) {
        final link = body['payment_link'] as String;
        final transactionId = body['transactionId'] as String? ?? '';

        setState(() {
          _paymentLink = link;
          // Prefilled so the status check below needs no copy-paste.
          _transactionIdController.text = transactionId;
        });

        _record('Payment created', ok: true, body: _pretty(response.body));
        await _openPaymentPage(link);
      } else {
        _record('Payment rejected', ok: false, body: _pretty(response.body));
      }
    } catch (error) {
      // A timeout here means the outcome is unknown, not that it failed.
      _record(
        'Could not reach the backend',
        ok: false,
        body: '$error\n\nIf this was a timeout the payment may still exist. '
            'Check it with the status button rather than assuming it failed.',
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _openPaymentPage(String link) async {
    final uri = Uri.parse(link);
    if (!await launchUrl(uri, webOnlyWindowName: '_blank')) {
      _record(
        'Could not open the payment page',
        ok: false,
        body: 'The browser blocked it. Copy the link below and open it yourself.',
      );
    }
  }

  // --- 3. What happened to it? ---------------------------------------------

  Future<void> _checkStatus() async {
    final transactionId = _transactionIdController.text.trim();
    if (transactionId.isEmpty) {
      _record(
        'Not checked',
        ok: false,
        body: 'Enter a transaction id. Starting a payment above fills this in.',
      );
      return;
    }

    setState(() => _busy = 'status');
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.sdkSimpleStatusUrl}?gid=$transactionId'))
          .timeout(AppConfig.apiTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final result = body['result'] as String?;

      _record(
        result != null ? 'Status: $result' : 'Status check failed',
        ok: response.statusCode == 200,
        body: _pretty(response.body),
      );
    } catch (error) {
      _record('Status check failed', ok: false, body: '$error');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      appBar: const PremiumAppBar(title: 'New SDK Test'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isLargeScreen ? AppTheme.spacing32 : AppTheme.spacing16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppTheme.spacing32),
                _buildHealthCard(context),
                const SizedBox(height: AppTheme.spacing24),
                _buildPaymentCard(context),
                const SizedBox(height: AppTheme.spacing24),
                _buildStatusCard(context),
                const SizedBox(height: AppTheme.spacing24),
                _buildLog(context),
                const SizedBox(height: AppTheme.spacing48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('New SDK Test', style: theme.textTheme.headlineMedium),
            const SizedBox(width: AppTheme.spacing12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing10,
                vertical: AppTheme.spacing4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                'UAT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          'Drives the simple SDK end to end: load it, take a payment, then ask '
          'PayGlocal what happened. Real UAT calls, so every response below is '
          'the one the SDK actually got.',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHealthCard(BuildContext context) {
    final health = _health;

    return _Card(
      step: '1',
      title: 'Configuration',
      subtitle: 'Can the backend load the SDK and read its keys?',
      trailing: _Action(
        label: 'Recheck',
        icon: Icons.refresh,
        busy: _busy == 'health',
        onPressed: _busy == null ? _checkHealth : null,
        filled: false,
      ),
      child: health == null
          ? _Notice(
              ok: false,
              text: _busy == 'health'
                  ? 'Checking...'
                  : 'The SDK did not load. The log below says why. Nothing else '
                      'on this page will work until it does.',
            )
          : Wrap(
              spacing: AppTheme.spacing32,
              runSpacing: AppTheme.spacing16,
              children: [
                _Field(label: 'Environment', value: health.environment),
                _Field(label: 'Merchant id', value: health.merchantId),
                _Field(label: "PayGlocal's key id", value: health.publicKeyId),
                _Field(label: 'Your key id', value: health.privateKeyId),
                _Field(label: 'Keys read from', value: health.keysFrom),
                _Field(label: 'Origin', value: health.origin),
              ],
            ),
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    final theme = Theme.of(context);
    final link = _paymentLink;

    return _Card(
      step: '2',
      title: 'Take a payment',
      subtitle: 'Creates a real UAT transaction and opens the hosted page.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppTheme.spacing16,
            runSpacing: AppTheme.spacing16,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    helperText: 'Sent as text',
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => _currency = value ?? 'INR'),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Customer email'),
                ),
              ),
              _Action(
                label: 'Start payment',
                icon: Icons.open_in_new,
                busy: _busy == 'initiate',
                onPressed: _busy == null ? _initiate : null,
              ),
            ],
          ),
          if (link != null) ...[
            const SizedBox(height: AppTheme.spacing20),
            Text(
              'Payment page',
              style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacing6),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    link,
                    maxLines: 2,
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy link',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment link copied')),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Open again',
                  icon: const Icon(Icons.launch, size: 18),
                  onPressed: () => _openPaymentPage(link),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return _Card(
      step: '3',
      title: 'Check a payment',
      subtitle: 'Asks PayGlocal directly, so the answer cannot be faked.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppTheme.spacing16,
            runSpacing: AppTheme.spacing16,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: 380,
                child: TextField(
                  controller: _transactionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction id',
                    hintText: 'gl_o-...',
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              _Action(
                label: 'Check status',
                icon: Icons.search,
                busy: _busy == 'status',
                onPressed: _busy == null ? _checkStatus : null,
                filled: false,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          const _Notice(
            ok: true,
            text: 'A fresh payment reads IN_PROGRESS until the customer '
                'finishes on the hosted page. That is not a failure. Only '
                'SENT_FOR_CAPTURE means the money is yours.',
          ),
        ],
      ),
    );
  }

  Widget _buildLog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Responses', style: theme.textTheme.titleMedium),
            if (_log.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(_log.clear),
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),
        if (_log.isEmpty)
          Text(
            'Nothing yet.',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary),
          )
        else
          ..._log.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.surfacePrimary,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: entry.ok
                      ? AppTheme.success.withValues(alpha: 0.35)
                      : AppTheme.error.withValues(alpha: 0.35),
                ),
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _log.first == entry,
                  tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                  leading: Icon(
                    entry.ok ? Icons.check_circle_outline : Icons.error_outline,
                    color: entry.ok ? AppTheme.success : AppTheme.error,
                    size: 20,
                  ),
                  title: Text(entry.title, style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    '${entry.at.hour.toString().padLeft(2, '0')}:'
                    '${entry.at.minute.toString().padLeft(2, '0')}:'
                    '${entry.at.second.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      margin: const EdgeInsets.fromLTRB(
                        AppTheme.spacing16,
                        0,
                        AppTheme.spacing16,
                        AppTheme.spacing16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBackground : AppTheme.gray100,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: SelectableText(
                        entry.body,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- Small pieces, kept local to this page -----------------------------------

class _Health {
  const _Health({
    required this.environment,
    required this.merchantId,
    required this.publicKeyId,
    required this.privateKeyId,
    required this.keysFrom,
    required this.origin,
  });

  final String environment;
  final String merchantId;
  final String publicKeyId;
  final String privateKeyId;
  final String keysFrom;
  final String origin;
}

class _LogEntry {
  const _LogEntry({
    required this.title,
    required this.ok,
    required this.body,
    required this.at,
  });

  final String title;
  final bool ok;
  final String body;
  final DateTime at;
}

class _Card extends StatelessWidget {
  const _Card({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String step;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfacePrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Text(
                  step,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          child,
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon, size: 18);

    if (!filled) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: child,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing20,
            vertical: AppTheme.spacing16,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: child,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing24,
          vertical: AppTheme.spacing16,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textTertiary),
        ),
        const SizedBox(height: AppTheme.spacing4),
        SelectableText(
          value,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ok ? AppTheme.info : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.info_outline : Icons.warning_amber_outlined, size: 18, color: color),
          const SizedBox(width: AppTheme.spacing10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
