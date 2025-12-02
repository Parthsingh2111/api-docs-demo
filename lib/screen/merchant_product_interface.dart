


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centralproject/utils/pc_payment_utils.dart'; // Assumed for handlePcJwtPayment

class Product {
  final String id;
  final String name;
  final String description;
  final double price; // Base price in INR
  final String imagePlaceholder;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePlaceholder,
    required this.category,
    
  });
}

class clothingMerchantInterface extends StatefulWidget {
  final bool isPayDirect;

  const clothingMerchantInterface({super.key, required this.isPayDirect});

  @override
  _clothingMerchantInterfaceState createState() => _clothingMerchantInterfaceState();
}

class _clothingMerchantInterfaceState extends State<clothingMerchantInterface>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _selectedCategory = 'All';
  String _selectedCurrency = 'INR';
  final TextEditingController _searchController = TextEditingController();

  // Currency conversion rates (base: INR)
  final Map<String, double> _currencyRates = {
    'INR': 1.0,
    'USD': 0.012, // 1 INR = 0.012 USD
    'EUR': 0.011, // 1 INR = 0.011 EUR
  };

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Classic White Shirt',
      description: 'Premium cotton, tailored fit, perfect for any occasion',
      price: 999.0,
      imagePlaceholder: 'assets/images/white_shirt.png',
      category: 'Shirts',
    ),
    Product(
      id: '2',
      name: 'Denim Jacket',
      description: 'Stylish blue denim, casual wear, timeless design',
      price: 2499.0,
      imagePlaceholder: 'assets/images/denim_jacket.png',
      category: 'Jackets',
    ),
    Product(
      id: '3',
      name: 'Floral Dress',
      description: 'Elegant summer dress with vibrant floral print',
      price: 1999.0,
      imagePlaceholder: 'assets/images/floral_dress.png',
      category: 'Dresses',
    ),
    Product(
      id: '4',
      name: 'Black Sneakers',
      description: 'Comfortable, trendy, and versatile for daily wear',
      price: 1499.0,
      imagePlaceholder: 'assets/images/sneakers.png',
      category: 'Footwear',
    ),
  ];

  final Map<String, int> selectedProducts = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double getTotalAmount() {
    double total = 0.0;
    selectedProducts.forEach((productId, quantity) {
      final product = products.firstWhere((p) => p.id == productId);
      total += product.price * quantity * _currencyRates[_selectedCurrency]!;
    });
    return total;
  }

  int getCartItemCount() {
    return selectedProducts.values.fold(0, (sum, quantity) => sum + quantity);
  }

  List<Product> getFilteredProducts() {
    if (_selectedCategory == 'All') return products;
    return products.where((product) => product.category == _selectedCategory).toList();
  }

  String getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '₹';
    }
  }

  void _navigateToCheckout(BuildContext context) {
    if (selectedProducts.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/checkout',
        arguments: {
          'totalAmount': getTotalAmount(),
          'currency': _selectedCurrency,
          'currencyRate': _currencyRates[_selectedCurrency],
          'products': selectedProducts.entries
              .map((e) => {
                    'product': products.firstWhere((p) => p.id == e.key),
                    'quantity': e.value,
                  })
              .toList(),
          'isPayDirect': widget.isPayDirect,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your cart is empty. Please add items to proceed.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final titleFontSize = isLargeScreen ? 32.0 : 24.0;
    final subtitleFontSize = isLargeScreen ? 18.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Row(
          children: [
            Text(
              'UrbanThread',
              style: GoogleFonts.playfairDisplay(
                fontSize: isLargeScreen ? 28 : 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2B2B2B),
              ),
            ),
            const Spacer(),
            if (isLargeScreen)
              Row(
                children: [
                  _buildNavItem('Home', () => Navigator.pop(context)),
                  const SizedBox(width: 24),
                  _buildNavItem('Shop', () {}),
                  const SizedBox(width: 24),
                  _buildNavItem('About', () {}),
                  const SizedBox(width: 24),
                  _buildNavItem('Contact', () {}),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Color(0xFF2B2B2B)),
                if (getCartItemCount() > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE57373),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        getCartItemCount().toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _navigateToCheckout(context),
          ),
          if (!isLargeScreen)
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF2B2B2B)),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
      endDrawer: isLargeScreen
          ? null
          : Drawer(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    title: Text('Home', style: GoogleFonts.poppins(fontSize: 16)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Shop', style: GoogleFonts.poppins(fontSize: 16)),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    title: Text('About', style: GoogleFonts.poppins(fontSize: 16)),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    title: Text('Contact', style: GoogleFonts.poppins(fontSize: 16)),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE7F6),
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Discover Your Style',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shop the latest trends in premium clothing',
                      style: GoogleFonts.poppins(
                        fontSize: subtitleFontSize,
                        color: const Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: GoogleFonts.poppins(color: const Color(0xFF9E9E9E)),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: ['All', 'Shirts', 'Jackets', 'Dresses', 'Footwear']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category, style: GoogleFonts.poppins(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      underline: const SizedBox(),
                      style: GoogleFonts.poppins(color: const Color(0xFF2B2B2B)),
                      icon: const Icon(Icons.filter_list, color: Color(0xFF2B2B2B)),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      items: ['INR', 'USD', 'EUR']
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency, style: GoogleFonts.poppins(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                      underline: const SizedBox(),
                      style: GoogleFonts.poppins(color: const Color(0xFF2B2B2B)),
                      icon: const Icon(Icons.monetization_on, color: Color(0xFF2B2B2B)),
                    ),
                  ],
                ),
              ),
              if (selectedProducts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    onPressed: () => _navigateToCheckout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B2B2B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      'Proceed to Checkout (${getCartItemCount()} items)',
                      style: GoogleFonts.poppins(
                        fontSize: isLargeScreen ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final filteredProducts = getFilteredProducts()
                        .where((product) =>
                            product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            product.description.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .toList();
                    return GridView.count(
                      crossAxisCount: constraints.maxWidth > 800 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.7,
                      children: filteredProducts.map((product) {
                        final quantity = selectedProducts[product.id] ?? 0;
                        return _ProductCard(
                          product: product,
                          quantity: quantity,
                          selectedCurrency: _selectedCurrency,
                          currencyRate: _currencyRates[_selectedCurrency]!,
                          onQuantityChanged: (newQuantity) {
                            setState(() {
                              if (newQuantity == 0) {
                                selectedProducts.remove(product.id);
                              } else {
                                selectedProducts[product.id] = newQuantity;
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                color: const Color(0xFF2B2B2B),
                child: Column(
                  children: [
                    Text(
                      'UrbanThread',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: isLargeScreen ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFooterLink('About Us', () {}),
                        _buildFooterLink('Return Policy', () {}),
                        _buildFooterLink('Shipping Info', () {}),
                        _buildFooterLink('Contact Us', () {}),
                        _buildFooterLink('Privacy Policy', () {}),
                        _buildFooterLink('Terms of Service', () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© 2025 UrbanThread. All rights reserved.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2B2B2B),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final int quantity;
  final String selectedCurrency;
  final double currencyRate;
  final ValueChanged<int> onQuantityChanged;

  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.selectedCurrency,
    required this.currencyRate,
    required this.onQuantityChanged,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isHovered = false;

  String getCurrencySymbol() {
    switch (widget.selectedCurrency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '₹';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final convertedPrice = widget.product.price * widget.currencyRate;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
      child: Card(
        color: Colors.white,
        elevation: _isHovered ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.asset(
                      widget.product.imagePlaceholder,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            'Image not found',
                            style: GoogleFonts.poppins(
                              fontSize: isLargeScreen ? 14 : 12,
                              color: const Color(0xFF616161),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE57373),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.product.category,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.description,
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 14 : 13,
                      color: const Color(0xFF616161),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${getCurrencySymbol()}${convertedPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE57373),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.quantity > 0
                                ? () => widget.onQuantityChanged(widget.quantity - 1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF2B2B2B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.quantity.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2B2B2B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => widget.onQuantityChanged(widget.quantity + 1),
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2B2B2B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (widget.quantity > 0)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isHovered = false;
        });
      }
    });
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();

  // Controllers for Pay Collect
  final _addressController = TextEditingController(
    text: '123 Fashion Street, Mumbai, Maharashtra, India',
  );

  // Controllers for Pay Direct
  final _cardNumberController = TextEditingController(text: '4242424242424242');
  final _expiryMonthController = TextEditingController(text: '12');
  final _expiryYearController = TextEditingController(text: '2030');
  final _cvvController = TextEditingController(text: '123');
  final _firstNameController = TextEditingController(text: 'Mock');
  final _lastNameController = TextEditingController(text: 'Trader');
  final _addressStreet1Controller = TextEditingController(text: 'Rowley street 1');
  final _addressStreet2Controller = TextEditingController(text: 'Punctuality lane');
  final _cityController = TextEditingController(text: 'Bangalore');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _postalCodeController = TextEditingController(text: '560094');
  final _emailController = TextEditingController(text: 'mocktrader@myemail.com');
  final _phoneNumberController = TextEditingController(text: '9191919191');
  String _selectedCountry = 'IN';
  String _selectedCallingCode = '+91';

  // Sample country and calling code options
  final List<Map<String, String>> _countries = [
    {'code': 'IN', 'name': 'India'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
  ];
  final List<String> _callingCodes = ['+91', '+1', '+44'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressStreet1Controller.dispose();
    _addressStreet2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    if (!RegExp(r'^\d{16}$').hasMatch(value)) return 'Enter a valid 16-digit card number';
    return null;
  }

  String? _validateExpiryMonth(String? value) {
    if (value == null || value.isEmpty) return 'Expiry month is required';
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) return 'Enter a valid month (1-12)';
    return null;
  }

  String? _validateExpiryYear(String? value) {
    if (value == null || value.isEmpty) return 'Expiry year is required';
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < currentYear || year > currentYear + 10) {
      return 'Enter a valid year';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) return 'Enter a valid CVV';
    return null;
  }

  String? _validateRequired(String? value, String field) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Enter a valid 10-digit phone number';
    return null;
  }

  bool _validateForm(bool isPayDirect) {
    if (isPayDirect) {
      return _formKey.currentState!.validate();
    } else {
      return _addressController.text.isNotEmpty;
    }
  }

  void _submitForm(BuildContext context, double totalAmount, String currency, bool isPayDirect) async {
    if (!_validateForm(isPayDirect)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPayDirect
                ? 'Please fill all required fields'
                : 'Please enter a shipping address',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final now = DateTime.now();
    if (isPayDirect) {
      final payload = {
        'paymentData': {
          'totalAmount': totalAmount.toStringAsFixed(2),
          'txnCurrency': currency,
          'cardData': {
            'number': _cardNumberController.text,
            'expiryMonth': _expiryMonthController.text,
            'expiryYear': _expiryYearController.text,
            'securityCode': _cvvController.text,
          },
        },
         "riskData" :  {
          'shippingData': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'addressStreet1': _addressStreet1Controller.text,
          'addressStreet2': _addressStreet2Controller.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postalCode': _postalCodeController.text,
          'country': _selectedCountry,
          'email': _emailController.text,
          'phoneNumber': _selectedCallingCode + _phoneNumberController.text,
        },
         }
      };

      try {
        // Assuming handlePdJwtPayment exists, similar to handlePdAuthPayment
        print('Initiating Pay Direct payment with payload: $payload');
        await handlePdJwtPayment(context, payload);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'Payment Initiated! Redirecting...',
        //       style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        //     ),
        //     backgroundColor: const Color(0xFF5E35B1),
        //   ),
        // );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment failed: $e',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      try {
        await handlePcJwtPayment(totalAmount.toStringAsFixed(2), currency, context); 
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'Payment Initiated! Redirecting...',
        //       style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        //     ),
        //     backgroundColor: const Color(0xFF5E35B1),
        //   ),
        // );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment failed: $e',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _submitAltPayForm(BuildContext context, double totalAmount, String currency) async {
    if (!_validateForm(true)) { // Use PayDirect validation since it requires more fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Create alt pay payload using the same form data structure as PayDirect
    final altPayPayload = {
      'paymentData': {
        'totalAmount': totalAmount.toStringAsFixed(2),
        'txnCurrency': currency,
        'billingData': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'addressStreet1': _addressStreet1Controller.text,
          'addressStreet2': _addressStreet2Controller.text,
          'addressCity': _cityController.text,
          'addressState': _stateController.text,
          'addressPostalCode': _postalCodeController.text,
          'addressCountry': _selectedCountry,
          'emailId': _emailController.text,
          'callingCode': _selectedCallingCode,
          'phoneNumber': _phoneNumberController.text,
        },
      },
      'riskData': {
        'shippingData': {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'addressStreet1': _addressStreet1Controller.text,
          'addressStreet2': _addressStreet2Controller.text,
          'addressCity': _cityController.text,
          'addressState': _stateController.text,
          'addressPostalCode': _postalCodeController.text,
          'addressCountry': _selectedCountry,
          'emailId': _emailController.text,
          'callingCode': _selectedCallingCode,
          'phoneNumber': _phoneNumberController.text,
        },
      },
    };

    try {
      print('Initiating Alt Pay payment with payload: $altPayPayload');
      await handlePdAltPayment(context, altPayPayload);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alt Payment failed: $e',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final titleFontSize = isLargeScreen ? 32.0 : 24.0;
    final subtitleFontSize = isLargeScreen ? 18.0 : 16.0;
    final labelFontSize = isLargeScreen ? 16.0 : 14.0;
    final inputFontSize = isLargeScreen ? 14.0 : 13.0;

    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final double totalAmount = arguments?['totalAmount'] ?? 0.0;
    final String currency = arguments?['currency'] ?? 'INR';
    final double currencyRate = arguments?['currencyRate'] ?? 1.0;
    final List<Map<String, dynamic>> selectedProducts =
        (arguments?['products'] as List<Map<String, dynamic>>?) ?? [];
    final bool isPayDirect = arguments?['isPayDirect'] ?? false;

    String getCurrencySymbol() {
      switch (currency) {
        case 'USD':
          return '\$';
        case 'EUR':
          return '€';
        default:
          return '₹';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'UrbanThread - Checkout',
          style: GoogleFonts.playfairDisplay(
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2B2B2B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checkout',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Summary',
                              style: GoogleFonts.poppins(
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2B2B2B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...selectedProducts.map((item) {
                              final product = item['product'] as Product;
                              final quantity = item['quantity'] as int;
                              final convertedPrice = product.price * currencyRate;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        product.imagePlaceholder,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Text(
                                              'Image not found',
                                              style: GoogleFonts.poppins(
                                                fontSize: isLargeScreen ? 12 : 10,
                                                color: const Color(0xFF616161),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: isLargeScreen ? 16 : 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2B2B2B),
                                            ),
                                          ),
                                          Text(
                                            'Qty: $quantity',
                                            style: GoogleFonts.poppins(
                                              fontSize: isLargeScreen ? 14 : 12,
                                              color: const Color(0xFF616161),
                                            ),
                                          ),
                                          Text(
                                            '${getCurrencySymbol()}${(convertedPrice * quantity).toStringAsFixed(2)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isLargeScreen ? 14 : 12,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFE57373),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: GoogleFonts.poppins(
                                      fontSize: subtitleFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2B2B2B),
                                    ),
                                  ),
                                  Text(
                                    '${getCurrencySymbol()}${totalAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: isLargeScreen ? 20 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFE57373),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isPayDirect) ...[
                        Text(
                          'Card Details',
                          style: GoogleFonts.poppins(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2B2B2B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF2B2B2B)),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                          validator: _validateCardNumber,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _expiryMonthController,
                                decoration: InputDecoration(
                                  labelText: 'Expiry Month',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: _validateExpiryMonth,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _expiryYearController,
                                decoration: InputDecoration(
                                  labelText: 'Expiry Year',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: _validateExpiryYear,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF2B2B2B)),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                          validator: _validateCvv,
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        'Shipping Address',
                        style: GoogleFonts.poppins(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isPayDirect) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: (value) => _validateRequired(value, 'First Name'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: (value) => _validateRequired(value, 'Last Name'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressStreet1Controller,
                          decoration: InputDecoration(
                            labelText: 'Address Line 1',
                            labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                          validator: (value) => _validateRequired(value, 'Address Line 1'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressStreet2Controller,
                          decoration: InputDecoration(
                            labelText: 'Address Line 2 (Optional)',
                            labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: (value) => _validateRequired(value, 'City'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _stateController,
                                decoration: InputDecoration(
                                  labelText: 'State',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: (value) => _validateRequired(value, 'State'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _postalCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Postal Code',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: (value) => _validateRequired(value, 'Postal Code'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCountry,
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: _countries.map((country) {
                                  return DropdownMenuItem<String>(
                                    value: country['code'],
                                    child: Text(
                                      country['name']!,
                                      style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value!;
                                  });
                                },
                                validator: (value) => _validateRequired(value, 'Country'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF2B2B2B)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCallingCode,
                                decoration: InputDecoration(
                                  labelText: 'Code',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: _callingCodes.map((code) {
                                  return DropdownMenuItem<String>(
                                    value: code,
                                    child: Text(
                                      code,
                                      style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCallingCode = value!;
                                  });
                                },
                                validator: (value) => _validateRequired(value, 'Calling Code'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _phoneNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  labelStyle: GoogleFonts.poppins(fontSize: labelFontSize, color: const Color(0xFF616161)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF2B2B2B)),
                                ),
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.poppins(fontSize: inputFontSize, color: const Color(0xFF2B2B2B)),
                                validator: _validatePhoneNumber,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter your address',
                            hintStyle: GoogleFonts.poppins(
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: inputFontSize,
                            color: const Color(0xFF2B2B2B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _submitForm(context, totalAmount, currency, isPayDirect),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B2B2B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              'Pay Now with PayGlocal',
                              style: GoogleFonts.poppins(
                                fontSize: isLargeScreen ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isPayDirect) // Only show Alt Pay button for PayDirect flow
                            ElevatedButton(
                              onPressed: () => _submitAltPayForm(context, totalAmount, currency),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                elevation: 0,
                              ),
                              child: Text(
                                'Alt Pay',
                                style: GoogleFonts.poppins(
                                  fontSize: isLargeScreen ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
