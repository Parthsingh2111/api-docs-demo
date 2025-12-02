import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:api_docs_demo/utils/pc_payment_utils.dart';
// import 'package:centralproject/utils/pd_payment_utils.dart'; // Add this if using Pay Direct handler

class BillPaymentScreen extends StatefulWidget {
  final bool isPayDirect;
  const BillPaymentScreen({super.key, required this.isPayDirect});

  @override
  _BillPaymentScreenState createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> with SingleTickerProviderStateMixin {
  final int totalChannels = 150;
  final double totalBill = 2250.0;
  final List<String> selectedPackages = ['Daily Soaps', 'Sports', 'Movies'];
  final String fromDate = "2025-06-01";
  final String toDate = "2025-06-30";
  final int daysUsed = 30;

  final Map<String, Map<String, dynamic>> packageDetails = {
    'Daily Soaps': {'channels': 30, 'rate': 500.0},
    'Sports': {'channels': 25, 'rate': 800.0},
    'News': {'channels': 20, 'rate': 300.0},
    'Movies': {'channels': 35, 'rate': 950.0},
    'Religious': {'channels': 40, 'rate': 400.0},
  };

  final TextEditingController _cardNumberController = TextEditingController(text: '**** **** **** 4242');
  final TextEditingController _expiryController = TextEditingController(text: '12/30');
  final TextEditingController _cvvController = TextEditingController(text: '123');

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool _validateCardDetails() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '').replaceAll('*', '');
    final expiry = _expiryController.text;
    final cvv = _cvvController.text;

    if (cardNumber.isEmpty || expiry.isEmpty || cvv.isEmpty) return false;
    if (cardNumber.length != 16 || !RegExp(r'^\d{16}$').hasMatch(cardNumber)) return false;
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry)) return false;
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) return false;

    return true;
  }

  void _showPackageDetails(BuildContext context, List<String> packages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text('Package Details', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: packages.map((pkg) {
            final details = packageDetails[pkg]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                '$pkg: ${details['channels']} channels (₹${details['rate']})',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPayCollectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text('Bill Payment Details', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillDetailRow('Total Channels', '$totalChannels', icon: Icons.tv),
            Row(
              children: [
                Expanded(
                  child: _buildBillDetailRow('Packages Selected', selectedPackages.join(', '), icon: Icons.list),
                ),
                TextButton(
                  onPressed: () => _showPackageDetails(context, selectedPackages),
                  child: Text('View Packages', style: GoogleFonts.poppins(color: const Color(0xFFE57373))),
                ),
              ],
            ),
            _buildBillDetailRow('Total Amount', '₹$totalBill', icon: Icons.account_balance_wallet, isBold: true, textColor: const Color(0xFFE57373)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              handlePcVariableSIPayment(totalBill.toString(), context);
              _showSnackBar(context, 'Bill Paid via PayGlocal', color: const Color(0xFF4CAF50));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)),
            child: Text('Pay Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text('StarStream Entertainment', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: const Color(0xFF2B2B2B))),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)]),
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text('StarStream Entertainment', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Your Ultimate Destination for Premium TV Entertainment', style: GoogleFonts.poppins(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('Explore 1000+ channels with flexible packages tailored to your taste.', style: GoogleFonts.poppins(fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        color: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildBillDetailRow('Total Channels', '$totalChannels', icon: Icons.tv),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildBillDetailRow('Packages Selected', selectedPackages.join(', '), icon: Icons.list),
                                  ),
                                  TextButton(
                                    onPressed: () => _showPackageDetails(context, selectedPackages),
                                    child: Text('View Packages', style: GoogleFonts.poppins(color: const Color(0xFFE57373))),
                                  ),
                                ],
                              ),
                              _buildBillDetailRow('Total Amount', '₹$totalBill', icon: Icons.account_balance_wallet, isBold: true, textColor: const Color(0xFFE57373)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        color: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('Pay Your Bill', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              if (widget.isPayDirect) ...[
                                TextField(
                                  controller: _cardNumberController,
                                  decoration: InputDecoration(labelText: 'Card Number', border: OutlineInputBorder(), filled: true, fillColor: Colors.grey[100]),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _expiryController,
                                        decoration: InputDecoration(labelText: 'MM/YY', border: OutlineInputBorder(), filled: true, fillColor: Colors.grey[100]),
                                        keyboardType: TextInputType.datetime,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _cvvController,
                                        decoration: InputDecoration(labelText: 'CVV', border: OutlineInputBorder(), filled: true, fillColor: Colors.grey[100]),
                                        obscureText: true,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              ElevatedButton(
                                onPressed: () {
                                  if (widget.isPayDirect) {
                                    if (_validateCardDetails()) {
                                      handlePdVariableSIPaymentOld(
                              
                                        _cardNumberController.text,
                                        _expiryController.text,
                                        _cvvController.text,
                                        totalBill.toString(),
                                        context,
                                      );
                                      _showSnackBar(context, 'Bill Paid via PayGlocal', color: const Color(0xFF4CAF50));
                                    } else {
                                      _showSnackBar(context, 'Please enter valid card details');
                                    }
                                  } else {
                                    _showPayCollectDialog(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3F51B5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                                child: Text(
                                  widget.isPayDirect ? 'Pay Now with PayGlocal' : 'Pay with Pay Collect',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Column(
                  children: [
                    Text('StarStream Entertainment', style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('Delivering Unmatched Entertainment to Your Home', style: GoogleFonts.poppins(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Text('© 2025 StarStream Entertainment. All rights reserved.', style: GoogleFonts.poppins(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillDetailRow(String label, String value, {IconData? icon, bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: const Color(0xFFE57373), size: 20),
          if (icon != null) const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500))),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: isBold ? FontWeight.w600 : FontWeight.w500, color: textColor ?? const Color(0xFF2B2B2B))),
        ],
      ),
    );
  }
}
