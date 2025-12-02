
// airline_booking_interface.dart
// Consolidated Flutter implementation of an airline booking interface supporting
// both Pay Collect and Pay Direct flows for one-way, round-trip, and multi-city bookings.

// Import necessary packages
import 'package:api_docs_demo/utils/pc_payment_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Model for flight data
class Flight {
  final String time;
  final String duration;
  final String stop;
  final String date;
  final String aircraft;
  final double economyPrice;
  final double businessPrice;

  Flight({
    required this.time,
    required this.duration,
    required this.stop,
    required this.date,
    required this.aircraft,
    required this.economyPrice,
    required this.businessPrice,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'duration': duration,
        'stop': stop,
        'date': date,
        'aircraft': aircraft,
        'economyPrice': economyPrice,
        'businessPrice': businessPrice,
      };
}

// Model for city data
class City {
  final String city;
  final String country;
  final String airport;
  final String code;

  City({
    required this.city,
    required this.country,
    required this.airport,
    required this.code,
  });

  String get formatted => '$code — $city';
}

// Provider for managing booking state
class AirlineBookingProvider extends ChangeNotifier {
  String _tripType = 'One-way';
  String _currency = 'INR';
  String _from = '';
  String _to = '';
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengers = 1;
  String _travelClass = 'Economy';
  final List<Map<String, dynamic>> _multiCitySegments = [
    {'from': null, 'to': null, 'date': null},
  ];
  final List<Flight> _selectedMultiCityFlights = [];
  final List<String> _selectedMultiCityClasses = [];
  bool _isPayDirect = false; // Flag to determine Pay Direct or Pay Collect

  // Currency conversion rates
  static const Map<String, double> _currencyRates = {
    'INR': 1.0,
    'USD': 0.012,
    'EUR': 0.011,
  };

  // Getters
  String get tripType => _tripType;
  String get currency => _currency;
  String get from => _from;
  String get to => _to;
  DateTime? get departureDate => _departureDate;
  DateTime? get returnDate => _returnDate;
  int get passengers => _passengers;
  String get travelClass => _travelClass;
  List<Map<String, dynamic>> get multiCitySegments => _multiCitySegments;
  List<Flight> get selectedMultiCityFlights => _selectedMultiCityFlights;
  List<String> get selectedMultiCityClasses => _selectedMultiCityClasses;
  Map<String, double> get currencyRates => _currencyRates;
  bool get isPayDirect => _isPayDirect;

  // Utility to get currency symbol
  String getCurrencySymbol() {
    switch (_currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '₹';
    }
  }

  // Update methods
  void updateTripType(String type) {
    _tripType = type;
    notifyListeners();
  }

  void updateCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }

  void updateFrom(String from) {
    _from = from;
    notifyListeners();
  }

  void updateTo(String to) {
    _to = to;
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _departureDate = date;
    notifyListeners();
  }

  void updateReturnDate(DateTime? date) {
    _returnDate = date;
    notifyListeners();
  }

  void updatePassengers(int passengers) {
    _passengers = passengers;
    notifyListeners();
  }

  void updateTravelClass(String travelClass) {
    _travelClass = travelClass;
    notifyListeners();
  }

  void addMultiCitySegment() {
    if (_multiCitySegments.length < 5) {
      _multiCitySegments.add({'from': null, 'to': null, 'date': null});
      notifyListeners();
    }
  }

  void updateMultiCitySegment(int index, String key, dynamic value) {
    if (index >= 0 && index < _multiCitySegments.length) {
      _multiCitySegments[index][key] = value;
      notifyListeners();
    }
  }

  void removeMultiCitySegment(int index) {
    if (index > 0 && index < _multiCitySegments.length) {
      _multiCitySegments.removeAt(index);
      if (_selectedMultiCityFlights.length > index) {
        _selectedMultiCityFlights.removeAt(index);
        _selectedMultiCityClasses.removeAt(index);
      }
      notifyListeners();
    }
  }

  void selectMultiCityFlight(int segmentIndex, Flight flight, String travelClass) {
    if (segmentIndex >= 0 && segmentIndex < _multiCitySegments.length) {
      if (_selectedMultiCityFlights.length <= segmentIndex) {
        _selectedMultiCityFlights.add(flight);
        _selectedMultiCityClasses.add(travelClass);
      } else {
        _selectedMultiCityFlights[segmentIndex] = flight;
        _selectedMultiCityClasses[segmentIndex] = travelClass;
      }
      notifyListeners();
    }
  }

  void setPaymentFlow(bool isPayDirect) {
    _isPayDirect = isPayDirect;
    notifyListeners();
  }
}

// Main booking page
class AirlineBookingPage extends StatefulWidget {
  final bool isPayDirect;

  const AirlineBookingPage({super.key, this.isPayDirect = false});

  @override
  _AirlineBookingPageState createState() => _AirlineBookingPageState();
}

class _AirlineBookingPageState extends State<AirlineBookingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // List of available trip types and currencies
  static const List<String> _tripTypes = [
    'One-way',
    'Round-trip',
    'Multi-city',
  ];
  static const List<String> _currencies = ['INR', 'USD', 'EUR'];

  // Sample city data
  static final List<City> _departureCities = [
    City(
      city: 'Mumbai',
      country: 'India',
      airport: 'Chhatrapati Shivaji Airport',
      code: 'BOM',
    ),
    City(
      city: 'Delhi',
      country: 'India',
      airport: 'Indira Gandhi Airport',
      code: 'DEL',
    ),
    City(
      city: 'Kolkata',
      country: 'India',
      airport: 'Netaji Subhas Chandra Airport',
      code: 'CCU',
    ),
    City(
      city: 'Chennai',
      country: 'India',
      airport: 'Chennai Airport',
      code: 'MAA',
    ),
    City(
      city: 'Bengaluru',
      country: 'India',
      airport: 'Kempegowda Airport',
      code: 'BLR',
    ),
    City(
      city: 'Hyderabad',
      country: 'India',
      airport: 'Rajiv Gandhi Airport',
      code: 'HYD',
    ),
    City(
      city: 'Ahmedabad',
      country: 'India',
      airport: 'Sardar Vallabhbhai Patel Airport',
      code: 'AMD',
    ),
    City(city: 'Pune', country: 'India', airport: 'Pune Airport', code: 'PNQ'),
  ];

  static final List<City> _destinationCities = [
    City(
      city: 'New York',
      country: 'USA',
      airport: 'John F. Kennedy Airport',
      code: 'JFK',
    ),
    City(
      city: 'London',
      country: 'UK',
      airport: 'Heathrow Airport',
      code: 'LHR',
    ),
    City(
      city: 'Paris',
      country: 'France',
      airport: 'Charles de Gaulle Airport',
      code: 'CDG',
    ),
    City(
      city: 'Amsterdam',
      country: 'Netherlands',
      airport: 'Schiphol Airport',
      code: 'AMS',
    ),
    City(
      city: 'Frankfurt',
      country: 'Germany',
      airport: 'Frankfurt Airport',
      code: 'FRA',
    ),
    City(
      city: 'Chicago',
      country: 'USA',
      airport: "O'Hare Airport",
      code: 'ORD',
    ),
    City(
      city: 'Los Angeles',
      country: 'USA',
      airport: 'Los Angeles Airport',
      code: 'LAX',
    ),
    City(
      city: 'Rome',
      country: 'Italy',
      airport: 'Leonardo da Vinci Airport',
      code: 'FCO',
    ),
  ];

  @override
void initState() {
  super.initState();
  // Initialize fade animation
  _fadeController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();
  _fadeAnimation = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeInOut,
  );

  // Defer setPaymentFlow until after the build phase
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<AirlineBookingProvider>(context, listen: false)
        .setPaymentFlow(widget.isPayDirect);
  });
}

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<AirlineBookingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, isLargeScreen),
      endDrawer: isLargeScreen ? null : _buildDrawer(context),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, isLargeScreen),
                  _buildCurrencySelector(context),
                  _buildTripTypeSelector(context, isLargeScreen),
                  if (provider.tripType != 'Multi-city')
                    _buildFlightForm(context, isLargeScreen),
                  _buildFooter(context, isLargeScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the app bar
  AppBar _buildAppBar(BuildContext context, bool isLargeScreen) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      flexibleSpace: _buildGradientContainer(),
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'SkyWings Airlines',
          style: GoogleFonts.playfairDisplay(
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
      actions: isLargeScreen
          ? [
              _buildNavItem('Home', () => Navigator.pop(context)),
              const SizedBox(width: 24),
              _buildNavItem('Book', () {}),
              const SizedBox(width: 24),
              _buildNavItem('About', () {}),
              const SizedBox(width: 24),
              _buildNavItem('Contact', () {}),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
    );
  }

  // Builds the drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.7),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDrawerItem('Home', () {
            Navigator.pop(context);
            Navigator.pop(context);
          }),
          _buildDrawerItem('Book', () => Navigator.pop(context)),
          _buildDrawerItem('About', () => Navigator.pop(context)),
          _buildDrawerItem('Contact', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  // Builds the background
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(
            'assets/images/landscape-shot-brooklyn-bridge-new-usa-with-gray-gloomy-sky.jpg',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  // Builds the header
  Widget _buildHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Book Your Journey',
              style: GoogleFonts.playfairDisplay(
                fontSize: isLargeScreen ? 32 : 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fly with elegance and comfort',
            style: GoogleFonts.poppins(
              fontSize: isLargeScreen ? 18 : 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the currency selector
  Widget _buildCurrencySelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Consumer<AirlineBookingProvider>(
            builder: (context, provider, child) => Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                initialValue: provider.currency,
                onSelected: (value) => provider.updateCurrency(value),
                itemBuilder: (context) => _currencies
                    .map(
                      (currency) => PopupMenuItem(
                        value: currency,
                        child: Text(
                          currency,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.currency,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the trip type selector
  Widget _buildTripTypeSelector(BuildContext context, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _tripTypes.map((type) {
              return ChoiceChip(
                label: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                selected: Provider.of<AirlineBookingProvider>(context).tripType ==
                    type,
                onSelected: (selected) {
                  if (selected) {
                    Provider.of<AirlineBookingProvider>(context, listen: false)
                        .updateTripType(type);
                    if (type == 'Multi-city') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiCityBookingPage(
                            isPayDirect: widget.isPayDirect,
                          ),
                        ),
                      );
                    }
                  }
                },
                selectedColor: Colors.black,
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 2,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Builds the flight form
  Widget _buildFlightForm(BuildContext context, bool isLargeScreen) {
    final provider = Provider.of<AirlineBookingProvider>(context);
    return Column(
      children: [
        _buildAirportCard(
          context,
          provider,
          'From',
          provider.from.isEmpty ? 'Select your departure' : provider.from,
          true,
          _departureCities,
        ),
        _buildAirportCard(
          context,
          provider,
          'To',
          provider.to.isEmpty ? 'Select your destination' : provider.to,
          false,
          _destinationCities,
        ),
        _buildDateCard(context, provider, isLargeScreen),
        _buildSearchButton(context, provider, isLargeScreen),
      ],
    );
  }

  // Builds an airport selector card
  Widget _buildAirportCard(
    BuildContext context,
    AirlineBookingProvider provider,
    String label,
    String value,
    bool isFrom,
    List<City> cities,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: AirportSelector(
          label: label,
          value: value,
          onTap: () => _showCityDialog(context, provider, isFrom, cities),
        ),
      ),
    );
  }

  // Builds the date card
  Widget _buildDateCard(
    BuildContext context,
    AirlineBookingProvider provider,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: const Icon(
            Icons.calendar_today,
            color: Colors.black,
            size: 28,
          ),
          title: Text(
            provider.departureDate == null
                ? 'Select Date'
                : provider.tripType == 'One-way'
                    ? DateFormat('dd MMM yyyy').format(provider.departureDate!)
                    : '${DateFormat('dd MMM yyyy').format(provider.departureDate!)} - ${provider.returnDate != null ? DateFormat('dd MMM yyyy').format(provider.returnDate!) : 'Select Return'}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${provider.passengers} Passenger${provider.passengers > 1 ? 's' : ''}, ${provider.travelClass}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
          onTap: () => _showDatePicker(context, provider),
        ),
      ),
    );
  }

  // Builds the search button
  Widget _buildSearchButton(
    BuildContext context,
    AirlineBookingProvider provider,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ElevatedButton(
            onPressed: () {
              if (provider.from.isNotEmpty &&
                  provider.to.isNotEmpty &&
                  provider.departureDate != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlightResultsPage(
                      from: provider.from,
                      to: provider.to,
                      departureDate: provider.departureDate!,
                      returnDate: provider.returnDate,
                      isPayDirect: provider.isPayDirect,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please select departure, destination, and date',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                );
              }
            },
            style: _buttonStyle(isLargeScreen),
            child: Text(
              'Search Flights',
              style: GoogleFonts.poppins(
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the footer
  Widget _buildFooter(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      color: Colors.black.withOpacity(0.7),
      child: Column(
        children: [
          Text(
            'SkyWings Airlines',
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
              _buildFooterLink('Privacy Policy', () {}),
              _buildFooterLink('Terms of Service', () {}),
              _buildFooterLink('Contact Us', () {}),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2025 SkyWings Airlines. All rights reserved.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Utility to build navigation items
  Widget _buildNavItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  // Utility to build drawer items
  Widget _buildDrawerItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  // Utility to build footer links
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

  // Shows city selection dialog
  void _showCityDialog(
    BuildContext context,
    AirlineBookingProvider provider,
    bool isFrom,
    List<City> cities,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 68, 64, 64),
        title: Text(
          isFrom ? 'Select Departure' : 'Select Destination',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities.map((city) {
              return ListTile(
                leading: const Icon(Icons.flight, color: Colors.white),
                title: Text(
                  '${city.city}, ${city.country}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  city.airport,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                onTap: () {
                  if (isFrom) {
                    provider.updateFrom(city.formatted);
                  } else {
                    provider.updateTo(city.formatted);
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Shows date picker dialog
  void _showDatePicker(BuildContext context, AirlineBookingProvider provider) {
    final economyPrices = {
      for (int i = 0; i < 90; i++)
        DateTime.now().add(Duration(days: i)): 45000 + (i % 3) * 3000.0,
    };

    if (provider.tripType == 'One-way') {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
        builder: _datePickerTheme,
      ).then((date) {
        if (date != null) {
          provider.updateDate(date);
          provider.updateReturnDate(null);
          final price =
              economyPrices[DateTime(date.year, date.month, date.day)] ?? 45000;
          final convertedPrice =
              price * provider.currencyRates[provider.currency]!;
          _showPriceDialog(context, provider, date, convertedPrice);
        }
      });
    } else {
      showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
        builder: _datePickerTheme,
      ).then((range) {
        if (range != null) {
          provider.updateDate(range.start);
          provider.updateReturnDate(range.end);
          final startPrice =
              economyPrices[DateTime(range.start.year, range.start.month, range.start.day)] ?? 45000;
          final endPrice =
              economyPrices[DateTime(range.end.year, range.end.month, range.end.day)] ?? 48000;
          final convertedStartPrice =
              startPrice * provider.currencyRates[provider.currency]!;
          final convertedEndPrice =
              endPrice * provider.currencyRates[provider.currency]!;
          _showPriceRangeDialog(
            context,
            provider,
            range.start,
            range.end,
            convertedStartPrice,
            convertedEndPrice,
          );
        }
      });
    }
  }

  // Date picker theme
  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: TextTheme(
          headlineSmall: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: GoogleFonts.poppins(fontSize: 16),
          bodySmall: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
      ),
      child: child!,
    );
  }

  // Shows price dialog for one-way
  // void _showPriceDialog(
  //   BuildContext context,
  //   AirlineBookingProvider provider,
  //   DateTime date,
  //   double price,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       backgroundColor: Colors.white.withOpacity(0.8),
  //       content: Card(
  //         color: Colors.white.withOpacity(0.8),
  //         elevation: 4,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Selected Date',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 DateFormat('dd MMM yyyy').format(date),
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 16,
  //                   color: Colors.black54,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Economy Price: ${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'OK',
  //             style: GoogleFonts.poppins(color: Colors.black),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }



void _showPriceDialog(
  BuildContext context,
  AirlineBookingProvider provider,
  DateTime date,
  double price,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white.withOpacity(0.8),
      content: Card(
        color: Colors.white.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Date',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Economy Price: ${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (provider.from.isNotEmpty &&
                provider.to.isNotEmpty &&
                provider.departureDate != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlightResultsPage(
                    from: provider.from,
                    to: provider.to,
                    departureDate: provider.departureDate!,
                    returnDate: provider.returnDate,
                    isPayDirect: provider.isPayDirect,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please select departure, destination, and date',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            elevation: 2,
          ),
          child: Text(
            'Search Flights',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}



  // Shows price dialog for round-trip
  void _showPriceRangeDialog(
  BuildContext context,
  AirlineBookingProvider provider,
  DateTime start,
  DateTime end,
  double startPrice,
  double endPrice,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white.withOpacity(0.8),
      content: Card(
        color: Colors.white.withOpacity(0.8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Dates',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Departure: ${DateFormat('dd MMM yyyy').format(start)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Return: ${DateFormat('dd MMM yyyy').format(end)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Economy Price: ${provider.getCurrencySymbol()}${(startPrice + endPrice).toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (provider.from.isNotEmpty &&
                provider.to.isNotEmpty &&
                provider.departureDate != null &&
                provider.returnDate != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlightResultsPage(
                    from: provider.from,
                    to: provider.to,
                    departureDate: provider.departureDate!,
                    returnDate: provider.returnDate,
                    isPayDirect: provider.isPayDirect,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please select departure, destination, and dates',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            elevation: 2,
          ),
          child: Text(
            'Search Flights',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
  // void _showPriceRangeDialog(
  //   BuildContext context,
  //   AirlineBookingProvider provider,
  //   DateTime start,
  //   DateTime end,
  //   double startPrice,
  //   double endPrice,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       backgroundColor: Colors.white.withOpacity(0.8),
  //       content: Card(
  //         color: Colors.white.withOpacity(0.8),
  //         elevation: 4,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 'Selected Dates',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Departure: ${DateFormat('dd MMM yyyy').format(start)}',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 16,
  //                   color: Colors.black54,
  //                 ),
  //               ),
  //               Text(
  //                 'Return: ${DateFormat('dd MMM yyyy').format(end)}',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 16,
  //                   color: Colors.black54,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Economy Price: ${provider.getCurrencySymbol()}${startPrice.toStringAsFixed(2)} - ${endPrice.toStringAsFixed(2)}',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'OK',
  //             style: GoogleFonts.poppins(color: Colors.black),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Common button style
  ButtonStyle _buttonStyle(bool isLargeScreen) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
    );
  }

  // Common gradient container
  Widget _buildGradientContainer() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 11, 9, 9),
            Color.fromARGB(255, 52, 51, 51),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
    );
  }
}

// Airport selector widget
class AirportSelector extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const AirportSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.flight_takeoff, color: Colors.black, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Multi-city booking page
class MultiCityBookingPage extends StatefulWidget {
  final bool isPayDirect;

  const MultiCityBookingPage({super.key, this.isPayDirect = false});

  @override
  _MultiCityBookingPageState createState() => _MultiCityBookingPageState();
}

class _MultiCityBookingPageState extends State<MultiCityBookingPage> {
  static final List<City> _departureCities = [
    City(
      city: 'Mumbai',
      country: 'India',
      airport: 'Chhatrapati Shivaji Airport',
      code: 'BOM',
    ),
    City(
      city: 'Delhi',
      country: 'India',
      airport: 'Indira Gandhi Airport',
      code: 'DEL',
    ),
    City(
      city: 'Kolkata',
      country: 'India',
      airport: 'Netaji Subhas Chandra Airport',
      code: 'CCU',
    ),
    City(
      city: 'Chennai',
      country: 'India',
      airport: 'Chennai Airport',
      code: 'MAA',
    ),
    City(
      city: 'Bengaluru',
      country: 'India',
      airport: 'Kempegowda Airport',
      code: 'BLR',
    ),
    City(
      city: 'Hyderabad',
      country: 'India',
      airport: 'Rajiv Gandhi Airport',
      code: 'HYD',
    ),
    City(
      city: 'Ahmedabad',
      country: 'India',
      airport: 'Sardar Vallabhbhai Patel Airport',
      code: 'AMD',
    ),
    City(city: 'Pune', country: 'India', airport: 'Pune Airport', code: 'PNQ'),
  ];

  static final List<City> _destinationCities = [
    City(
      city: 'New York',
      country: 'USA',
      airport: 'John F. Kennedy Airport',
      code: 'JFK',
    ),
    City(
      city: 'London',
      country: 'UK',
      airport: 'Heathrow Airport',
      code: 'LHR',
    ),
    City(
      city: 'Paris',
      country: 'France',
      airport: 'Charles de Gaulle Airport',
      code: 'CDG',
    ),
    City(
      city: 'Amsterdam',
      country: 'Netherlands',
      airport: 'Schiphol Airport',
      code: 'AMS',
    ),
    City(
      city: 'Frankfurt',
      country: 'Germany',
      airport: 'Frankfurt Airport',
      code: 'FRA',
    ),
    City(
      city: 'Chicago',
      country: 'USA',
      airport: "O'Hare Airport",
      code: 'ORD',
    ),
    City(
      city: 'Los Angeles',
      country: 'USA',
      airport: 'Los Angeles Airport',
      code: 'LAX',
    ),
    City(
      city: 'Rome',
      country: 'Italy',
      airport: 'Leonardo da Vinci Airport',
      code: 'FCO',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<AirlineBookingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 11, 12, 12),
                Color.fromARGB(255, 10, 14, 16),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
        title: Text(
          'Multi-City Booking',
          style: GoogleFonts.playfairDisplay(
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 248, 246, 246)),
          onPressed: () => Navigator.pop(context),
        ),

        
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/landscape-shot-brooklyn-bridge-new-usa-with-gray-gloomy-sky.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Your Multi-City Journey',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isLargeScreen ? 32 : 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add up to 5 flights',
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 18 : 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...provider.multiCitySegments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final segment = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        color: Colors.white.withOpacity(0.8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Flight ${index + 1}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (index > 0)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                      onPressed: () =>
                                          provider.removeMultiCitySegment(index),
                                      tooltip: 'Remove Flight',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              AirportSelector(
                                label: 'From',
                                value: segment['from'] ?? 'Select departure',
                                onTap: () => _showCityDialog(
                                  context,
                                  provider,
                                  true,
                                  _departureCities,
                                  index,
                                ),
                              ),
                              const Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                              AirportSelector(
                                label: 'To',
                                value: segment['to'] ?? 'Select destination',
                                onTap: () => _showCityDialog(
                                  context,
                                  provider,
                                  false,
                                  _destinationCities,
                                  index,
                                ),
                              ),
                              const Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                              InkWell(
                                onTap: () => _showDatePicker(
                                  context,
                                  provider,
                                  index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.black,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Departure Date',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            segment['date'] != null
                                                ? DateFormat('dd MMM yyyy')
                                                    .format(segment['date'])
                                                : 'Select date',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (provider.multiCitySegments.length < 5)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: provider.addMultiCitySegment,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            'Add Flight',
                            style: GoogleFonts.poppins(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '1 Adult',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: ElevatedButton(
                          onPressed: () {
                            final isValid = provider.multiCitySegments.every(
                              (segment) =>
                                  segment['from'] != null &&
                                  segment['to'] != null &&
                                  segment['date'] != null,
                            );
                            if (isValid) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MultiCityResultsPage(
                                    isPayDirect: widget.isPayDirect,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please complete all flight details',
                                    style:
                                        GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Text(
                            'Search Flights',
                            style: GoogleFonts.poppins(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityDialog(
    BuildContext context,
    AirlineBookingProvider provider,
    bool isFrom,
    List<City> cities,
    int segmentIndex,
  ) {
    if (isFrom && segmentIndex > 0) {
      final autoFilledFrom = provider.multiCitySegments[segmentIndex - 1]['to'];
      provider.updateMultiCitySegment(segmentIndex, 'from', autoFilledFrom);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 68, 64, 64),
        title: Text(
          isFrom ? 'Select Departure' : 'Select Destination',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities.map((city) {
              final selectedCity = city.formatted;
              return ListTile(
                leading: const Icon(Icons.flight, color: Colors.white),
                title: Text(
                  '${city.city}, ${city.country}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  city.airport,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                onTap: () {
                  if (!isFrom &&
                      provider.multiCitySegments[segmentIndex]['from'] ==
                          selectedCity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Departure and destination cities cannot be the same',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  provider.updateMultiCitySegment(
                    segmentIndex,
                    isFrom ? 'from' : 'to',
                    selectedCity,
                  );
                  if (!isFrom &&
                      segmentIndex < provider.multiCitySegments.length - 1) {
                    provider.updateMultiCitySegment(
                      segmentIndex + 1,
                      'from',
                      selectedCity,
                    );
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showDatePicker(
    BuildContext context,
    AirlineBookingProvider provider,
    int segmentIndex,
  ) {
    DateTime firstDate = DateTime.now();
    if (segmentIndex > 0) {
      final previousDate =
          provider.multiCitySegments[segmentIndex - 1]['date'] as DateTime?;
      if (previousDate != null) {
        firstDate = previousDate.add(const Duration(days: 1));
      }
    }

    showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textTheme: TextTheme(
            headlineSmall: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: GoogleFonts.poppins(fontSize: 16),
            bodySmall: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        child: child!,
      ),
    ).then((date) {
      if (date != null) {
        if (segmentIndex > 0) {
          final previousDate =
              provider.multiCitySegments[segmentIndex - 1]['date'] as DateTime?;
          if (previousDate != null &&
              date.isBefore(previousDate.add(const Duration(days: 1)))) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Flight ${segmentIndex + 1} date must be after Flight $segmentIndex date',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        provider.updateMultiCitySegment(segmentIndex, 'date', date);
      }
    });
  }
}

// Flight results page

class FlightResultsPage extends StatelessWidget {
  final String from;
  final String to;
  final DateTime departureDate;
  final DateTime? returnDate;
  final bool isPayDirect;

  const FlightResultsPage({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    this.returnDate,
    required this.isPayDirect,
  });

  static final List<Flight> _outboundFlights = [
    Flight(
      time: '06:00 - 15:30',
      duration: '12h 30m',
      stop: 'Connects in Dubai',
      date: '27 Jul 2025',
      aircraft: 'A380 EK501 → B777 EK723',
      economyPrice: 62500.0,
      businessPrice: 145000.0,
    ),
    Flight(
      time: '09:15 - 18:45',
      duration: '13h 30m',
      stop: 'Connects in London',
      date: '27 Jul 2025',
      aircraft: 'B777 BA138 → B777 BA112',
      economyPrice: 58900.0,
      businessPrice: 138000.0,
    ),
    Flight(
      time: '12:30 - 22:00',
      duration: '14h 30m',
      stop: 'Connects in Frankfurt',
      date: '27 Jul 2025',
      aircraft: 'A350 LH759 → A320 LH112',
      economyPrice: 60200.0,
      businessPrice: 140500.0,
    ),
    Flight(
      time: '15:45 - 02:15',
      duration: '15h 30m',
      stop: 'Connects in Paris',
      date: '27 Jul 2025 - 28 Jul 2025',
      aircraft: 'A330 AF225 → A320 AF1641',
      economyPrice: 59800.0,
      businessPrice: 142000.0,
    ),
    Flight(
      time: '18:00 - 05:30',
      duration: '16h 30m',
      stop: 'Connects in Amsterdam',
      date: '27 Jul 2025 - 28 Jul 2025',
      aircraft: 'B787 KL872 → B737 KL1349',
      economyPrice: 61000.0,
      businessPrice: 143500.0,
    ),
  ];

  static final List<Flight> _returnFlights = [
    Flight(
      time: '07:00 - 16:30',
      duration: '12h 30m',
      stop: 'Connects in Dubai',
      date: '30 Jul 2025',
      aircraft: 'A380 EK502 → B777 EK724',
      economyPrice: 63000.0,
      businessPrice: 147000.0,
    ),
    Flight(
      time: '10:15 - 19:45',
      duration: '13h 30m',
      stop: 'Connects in London',
      date: '30 Jul 2025',
      aircraft: 'B777 BA139 → B777 BA113',
      economyPrice: 59500.0,
      businessPrice: 139500.0,
    ),
    Flight(
      time: '13:30 - 23:00',
      duration: '14h 30m',
      stop: 'Connects in Frankfurt',
      date: '30 Jul 2025',
      aircraft: 'A350 LH760 → A320 LH113',
      economyPrice: 60800.0,
      businessPrice: 141500.0,
    ),
    Flight(
      time: '16:45 - 03:15',
      duration: '15h 30m',
      stop: 'Connects in Paris',
      date: '30 Jul 2025 - 31 Jul 2025',
      aircraft: 'A330 AF226 → A320 AF1642',
      economyPrice: 60400.0,
      businessPrice: 143000.0,
    ),
    Flight(
      time: '19:00 - 06:30',
      duration: '16h 30m',
      stop: 'Connects in Amsterdam',
      date: '30 Jul 2025 - 31 Jul 2025',
      aircraft: 'B787 KL873 → B737 KL1350',
      economyPrice: 61500.0,
      businessPrice: 144500.0,
    ),
  ];


@override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<AirlineBookingProvider>(context);
    final isRoundTrip = provider.tripType == 'Round-trip' && returnDate != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 10, 11, 11),
                Color.fromARGB(255, 12, 16, 18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
        title: Text(
          'Available Flights',
          style: GoogleFonts.playfairDisplay(
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/landscape-shot-brooklyn-bridge-new-usa-with-gray-gloomy-sky.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Text(
                    isRoundTrip
                        ? 'Flights from $from to $to and $to to $from'
                        : 'Flights from $from to $to',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isLargeScreen ? 32 : 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (isRoundTrip) ...[
                    Text(
                      'Outbound Flights',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ..._outboundFlights.map((flight) => FlightCard(
                        flight: flight,
                        isPayDirect: isPayDirect,
                        isRoundTrip: isRoundTrip,
                        returnDate: returnDate,
                      )),
                  if (isRoundTrip) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Return Flights',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._returnFlights.map((flight) => FlightCard(
                          flight: flight,
                          isPayDirect: isPayDirect,
                          isRoundTrip: isRoundTrip,
                          returnDate: returnDate,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class FlightResultsPage extends StatelessWidget {
//   final String from;
//   final String to;
//   final DateTime departureDate;
//   final DateTime? returnDate;
//   final bool isPayDirect;

//   const FlightResultsPage({
//     Key? key,
//     required this.from,
//     required this.to,
//     required this.departureDate,
//     this.returnDate,
//     required this.isPayDirect,
//   }) : super(key: key);

//   static final List<Flight> _flights = [
//     Flight(
//       time: '06:00 - 15:30',
//       duration: '12h 30m',
//       stop: 'Connects in Dubai',
//       date: '27 Jul 2025',
//       aircraft: 'A380 EK501 → B777 EK723',
//       economyPrice: 62500.0,
//       businessPrice: 145000.0,
//     ),
//     Flight(
//       time: '09:15 - 18:45',
//       duration: '13h 30m',
//       stop: 'Connects in London',
//       date: '27 Jul 2025',
//       aircraft: 'B777 BA138 → B777 BA112',
//       economyPrice: 58900.0,
//       businessPrice: 138000.0,
//     ),
//     Flight(
//       time: '12:30 - 22:00',
//       duration: '14h 30m',
//       stop: 'Connects in Frankfurt',
//       date: '27 Jul 2025',
//       aircraft: 'A350 LH759 → A320 LH112',
//       economyPrice: 60200.0,
//       businessPrice: 140500.0,
//     ),
//     Flight(
//       time: '15:45 - 02:15',
//       duration: '15h 30m',
//       stop: 'Connects in Paris',
//       date: '27 Jul 2025 - 28 Jul 2025',
//       aircraft: 'A330 AF225 → A320 AF1641',
//       economyPrice: 59800.0,
//       businessPrice: 142000.0,
//     ),
//     Flight(
//       time: '18:00 - 05:30',
//       duration: '16h 30m',
//       stop: 'Connects in Amsterdam',
//       date: '27 Jul 2025 - 28 Jul 2025',
//       aircraft: 'B787 KL872 → B737 KL1349',
//       economyPrice: 61000.0,
//       businessPrice: 143500.0,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final isLargeScreen = MediaQuery.of(context).size.width > 800;
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 4,
//         shadowColor: Colors.black.withOpacity(0.2),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 10, 11, 11),
//                 Color.fromARGB(255, 12, 16, 18),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             border: Border(
//               bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
//             ),
//           ),
//         ),
//         title: Text(
//           'Available Flights',
//           style: GoogleFonts.playfairDisplay(
//             fontSize: isLargeScreen ? 28 : 24,
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//             shadows: [
//               Shadow(
//                 color: Colors.black45,
//                 blurRadius: 2,
//                 offset: const Offset(1, 1),
//               ),
//             ],
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: const AssetImage(
//                   'assets/images/landscape-shot-brooklyn-bridge-new-usa-with-gray-gloomy-sky.jpg',
//                 ),
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                   Colors.black.withOpacity(0.4),
//                   BlendMode.darken,
//                 ),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//               child: Column(
//                 children: [
//                   Text(
//                     'Flights from $from to $to',
//                     style: GoogleFonts.playfairDisplay(
//                       fontSize: isLargeScreen ? 32 : 24,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                       shadows: [
//                         Shadow(
//                           color: Colors.black45,
//                           blurRadius: 2,
//                           offset: const Offset(1, 1),
//                         ),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ..._flights.map((flight) => FlightCard(
//                         flight: flight,
//                         isPayDirect: isPayDirect,
//                       )),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Multi-city results page
class MultiCityResultsPage extends StatelessWidget {
  final bool isPayDirect;

  const MultiCityResultsPage({super.key, this.isPayDirect = false});

  static final List<Flight> _flights = [
    Flight(
      time: '06:00 - 15:30',
      duration: '12h 30m',
      stop: 'Connects in Dubai',
      date: '27 Jul 2025',
      aircraft: 'A380 EK501 → B777 EK723',
      economyPrice: 62500.0,
      businessPrice: 145000.0,
    ),
    Flight(
      time: '09:15 - 18:45',
      duration: '13h 30m',
      stop: 'Connects in London',
      date: '27 Jul 2025',
      aircraft: 'B777 BA138 → B777 BA112',
      economyPrice: 58900.0,
      businessPrice: 138000.0,
    ),
    Flight(
      time: '12:30 - 22:00',
      duration: '14h 30m',
      stop: 'Connects in Frankfurt',
      date: '27 Jul 2025',
      aircraft: 'A350 LH759 → A320 LH112',
      economyPrice: 60200.0,
      businessPrice: 140500.0,
    ),
    Flight(
      time: '15:45 - 02:15',
      duration: '15h 30m',
      stop: 'Connects in Paris',
      date: '27 Jul 2025 - 28 Jul 2025',
      aircraft: 'A330 AF225 → A320 AF1641',
      economyPrice: 59800.0,
      businessPrice: 142000.0,
    ),
    Flight(
      time: '18:00 - 05:30',
      duration: '16h 30m',
      stop: 'Connects in Amsterdam',
      date: '27 Jul 2025 - 28 Jul 2025',
      aircraft: 'B787 KL872 → B737 KL1349',
      economyPrice: 61000.0,
      businessPrice: 143500.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<AirlineBookingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 10, 11, 11),
                Color.fromARGB(255, 12, 16, 18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
        title: Text(
          'Multi-City Flights',
          style: GoogleFonts.playfairDisplay(
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/landscape-shot-brooklyn-bridge-new-usa-with-gray-gloomy-sky.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Flights for Your Journey',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isLargeScreen ? 32 : 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...provider.multiCitySegments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final segment = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: Colors.white.withOpacity(0.9),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Flight ${index + 1}: ${segment['from'] ?? 'Select departure'} to ${segment['to'] ?? 'Select destination'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  segment['date'] != null
                                      ? 'Date: ${DateFormat('dd MMM yyyy').format(segment['date'])}'
                                      : 'Date: Not selected',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._flights.map(
                          (flight) => FlightCard(
                            flight: flight,
                            segmentIndex: index,
                            isPayDirect: isPayDirect,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: ElevatedButton(
                          onPressed: () {
                            if (provider.selectedMultiCityFlights.length ==
                                provider.multiCitySegments.length) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingDetailsPage(
                                    flights: provider.selectedMultiCityFlights,
                                    travelClasses:
                                        provider.selectedMultiCityClasses,
                                    isMultiCity: true,
                                    isPayDirect: isPayDirect,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select a flight for each segment',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Text(
                            'Confirm Flights',
                            style: GoogleFonts.poppins(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Flight card widget


class FlightCard extends StatefulWidget {
  final Flight flight;
  final int? segmentIndex;
  final bool isPayDirect;
  final bool isRoundTrip;
  final DateTime? returnDate;

  const FlightCard({
    super.key,
    required this.flight,
    this.segmentIndex,
    required this.isPayDirect,
    this.isRoundTrip = false,
    this.returnDate,
  });

  @override
  _FlightCardState createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
  bool _isHovered = false;
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<AirlineBookingProvider>(context);
    final convertedEconomyPrice =
        widget.flight.economyPrice * provider.currencyRates[provider.currency]!;
    final convertedBusinessPrice =
        widget.flight.businessPrice * provider.currencyRates[provider.currency]!;
    final isDisabled = widget.segmentIndex != null &&
        provider.selectedMultiCityFlights.length > widget.segmentIndex! &&
        provider.selectedMultiCityFlights[widget.segmentIndex!] != widget.flight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(_isHovered && !isDisabled ? 1.02 : 1.0),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: MouseRegion(
        onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
        onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
        child: Card(
          color: isDisabled
              ? Colors.grey.withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          elevation: _isHovered && !isDisabled ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          if (_isSelected) const SizedBox(width: 8),
                          Text(
                            widget.flight.date,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.flight,
                            color: Colors.black,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.flight.time,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.flight.duration,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        widget.flight.stop,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        widget.flight.aircraft,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildClassColumn(
                    context,
                    provider,
                    'Economy',
                    convertedEconomyPrice,
                    isLargeScreen,
                    isDisabled,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildClassColumn(
                    context,
                    provider,
                    'Business',
                    convertedBusinessPrice,
                    isLargeScreen,
                    isDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
Widget _buildClassColumn(
    BuildContext context,
    AirlineBookingProvider provider,
    String classType,
    double price,
    bool isLargeScreen,
    bool isDisabled,
  ) {
    return Column(
      children: [
        Text(
          classType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: isDisabled
              ? null
              : () {
                  setState(() => _isSelected = true);
                  if (widget.segmentIndex != null) {
                    provider.selectMultiCityFlight(
                      widget.segmentIndex!,
                      widget.flight,
                      classType,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Flight ${widget.segmentIndex! + 1} selected ($classType)',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    List<Flight> selectedFlights = [widget.flight];
                    List<String> selectedClasses = [classType];
                    if (widget.isRoundTrip && widget.returnDate != null) {
                      // Assume the same flight is selected for return for simplicity
                      selectedFlights.add(widget.flight);
                      selectedClasses.add(classType);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsPage(
                          flights: selectedFlights,
                          travelClasses: selectedClasses,
                          isMultiCity: false,
                          isPayDirect: widget.isPayDirect,
                        ),
                      ),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? Colors.grey : Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            'Select',
            style: GoogleFonts.poppins(
              fontSize: isLargeScreen ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


// class FlightCard extends StatefulWidget {
//   final Flight flight;
//   final int? segmentIndex;
//   final bool isPayDirect;

//   const FlightCard({
//     Key? key,
//     required this.flight,
//     this.segmentIndex,
//     required this.isPayDirect,
//   }) : super(key: key);

//   @override
//   _FlightCardState createState() => _FlightCardState();
// }

// class _FlightCardState extends State<FlightCard> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final isLargeScreen = MediaQuery.of(context).size.width > 800;
//     final provider = Provider.of<AirlineBookingProvider>(context);
//     final convertedEconomyPrice =
//         widget.flight.economyPrice * provider.currencyRates[provider.currency]!;
//     final convertedBusinessPrice =
//         widget.flight.businessPrice * provider.currencyRates[provider.currency]!;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       child: MouseRegion(
//         onEnter: (_) => setState(() => _isHovered = true),
//         onExit: (_) => setState(() => _isHovered = false),
//         child: Card(
//           color: Colors.white.withOpacity(0.8),
//           elevation: _isHovered ? 8 : 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.flight.date,
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.flight,
//                             color: Colors.black,
//                             size: 28,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             widget.flight.time,
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         widget.flight.duration,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       Text(
//                         widget.flight.stop,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       Text(
//                         widget.flight.aircraft,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: _buildClassColumn(
//                     context,
//                     provider,
//                     'Economy',
//                     convertedEconomyPrice,
//                     isLargeScreen,
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: _buildClassColumn(
//                     context,
//                     provider,
//                     'Business',
//                     convertedBusinessPrice,
//                     isLargeScreen,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildClassColumn(
//     BuildContext context,
//     AirlineBookingProvider provider,
//     String classType,
//     double price,
//     bool isLargeScreen,
//   ) {
//     return Column(
//       children: [
//         Text(
//           classType,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
//           style: GoogleFonts.poppins(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: () {
//             if (widget.segmentIndex != null) {
//               provider.selectMultiCityFlight(
//                 widget.segmentIndex!,
//                 widget.flight,
//                 classType,
//               );
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     'Flight ${widget.segmentIndex! + 1} selected ($classType)',
//                     style: GoogleFonts.poppins(color: Colors.white),
//                   ),
//                 ),
//               );
//             } else {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BookingDetailsPage(
//                     flights: [widget.flight],
//                     travelClasses: [classType],
//                     isPayDirect: widget.isPayDirect,
//                   ),
//                 ),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             elevation: 2,
//             shadowColor: Colors.black.withOpacity(0.3),
//           ),
//           child: Text(
//             'Select',
//             style: GoogleFonts.poppins(
//               fontSize: isLargeScreen ? 14 : 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// Booking details page
class BookingDetailsPage extends StatefulWidget {
  final List<Flight> flights;
  final List<String> travelClasses;
  final bool isMultiCity;
  final bool isPayDirect;

  const BookingDetailsPage({
    super.key,
    required this.flights,
    required this.travelClasses,
    this.isMultiCity = false,
    this.isPayDirect = false,
  });

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  // Controllers for Pay Direct form fields
  final _billingLastNameController = TextEditingController(text: 'mock');
  final _street1Controller = TextEditingController(text: 'Rowley street 1');
  final _cityController = TextEditingController(text: 'Bangalore');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _zipCodeController = TextEditingController(text: '560094');
  final _countryController = TextEditingController(text: 'IN');
  final _emailController = TextEditingController(text: 'mocktrader@myemail.com');
  final _firstNameController = TextEditingController(text: 'Mock');
  final _lastNameController = TextEditingController(text: 'Trader');
  final _cardNumberController = TextEditingController(text: '4242424242424242');
  final _expiryMonthController = TextEditingController(text: '07');
  final _expiryYearController = TextEditingController(text: '2030');
  final _cardTypeController = TextEditingController(text: 'visa');
  final _securityCodeController = TextEditingController(text: '322');

  static final List<Map<String, dynamic>> _economyBenefits = [
    {'text': 'Standard Seat Selection', 'icon': Icons.event_seat},
    {'text': 'Complimentary Meals and Beverages', 'icon': Icons.restaurant},
    {'text': '20kg Checked Baggage Allowance', 'icon': Icons.luggage},
    {'text': 'In-flight Entertainment', 'icon': Icons.movie},
    {'text': 'Priority Check-in', 'icon': Icons.check_circle},
    {'text': 'Free Wi-Fi (Limited)', 'icon': Icons.wifi},
    {
      'text': 'Comfortable Economy Seating',
      'icon': Icons.airline_seat_recline_normal,
    },
    {'text': 'Online Check-in', 'icon': Icons.phone_iphone},
  ];

  static final List<Map<String, dynamic>> _businessBenefits = [
    {'text': 'Priority Boarding', 'icon': Icons.flight_takeoff},
    {'text': 'Lie-Flat Seats', 'icon': Icons.airline_seat_flat},
    {'text': 'Gourmet Dining', 'icon': Icons.dining},
    {'text': '40kg Checked Baggage Allowance', 'icon': Icons.luggage},
    {'text': 'Premium In-flight Entertainment', 'icon': Icons.movie},
    {'text': 'Dedicated Check-in Counter', 'icon': Icons.check_circle},
    {'text': 'Unlimited Wi-Fi', 'icon': Icons.wifi},
    {'text': 'Lounge Access', 'icon': Icons.living},
  ];

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _billingLastNameController.dispose();
    _street1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cardTypeController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final provider = Provider.of<AirlineBookingProvider>(context);
    final totalPrice = _calculateTotalPrice(provider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 10, 11, 11),
                Color.fromARGB(255, 12, 16, 18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
        title: Text(
          'Booking Details',
          style: GoogleFonts.playfairDisplay(
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/landscape-shot-brooklyn-bridge-new-usa-with-gray-gloomy-sky.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Booking Summary',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isLargeScreen ? 32 : 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.flights.asMap().entries.map((entry) {
                    final index = entry.key;
                    final flight = entry.value;
                    final travelClass = widget.travelClasses[index];
                    return _buildFlightDetailsCard(
                      context,
                      provider,
                      flight,
                      travelClass,
                      index + 1,
                      isLargeScreen,
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildPriceSummary(context, provider, totalPrice, isLargeScreen),
                  if (widget.isPayDirect) ...[
                    const SizedBox(height: 24),
                    _buildBillingDetailsForm(context, isLargeScreen),
                    const SizedBox(height: 24),
                    _buildPaymentDetailsForm(context, isLargeScreen),
                  ],
                  const SizedBox(height: 24),
                  _buildConfirmButton(context, provider, totalPrice, isLargeScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds flight details card
  Widget _buildFlightDetailsCard(
  BuildContext context,
  AirlineBookingProvider provider,
  Flight flight,
  String travelClass,
  int flightNumber,
  bool isLargeScreen,
) {
  final price = (travelClass == 'Economy'
          ? flight.economyPrice
          : flight.businessPrice) *
      provider.currencyRates[provider.currency]!;
  final benefits = travelClass == 'Economy' ? _economyBenefits : _businessBenefits;
  final fromCity = provider.from.isNotEmpty ? provider.from : 'Unknown';
  final toCity = provider.to.isNotEmpty ? provider.to : 'Unknown';
  final isRoundTrip = provider.tripType == 'Round-trip' && provider.returnDate != null;

  return Card(
    color: Colors.white.withOpacity(0.9),
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isMultiCity
                ? 'Flight $flightNumber'
                : isRoundTrip
                    ? 'Flight $flightNumber: $fromCity to $toCity'
                    : 'Selected Flight: $fromCity to $toCity',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (isRoundTrip && flightNumber == 2)
            Text(
              'Return: $toCity to $fromCity',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Class: $travelClass',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            'Date: ${flight.date}',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            'Time: ${flight.time}',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            'Duration: ${flight.duration}',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            'Stop: ${flight.stop}',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          Text(
            'Aircraft: ${flight.aircraft}',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Price: ${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Benefits:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          ...benefits.map((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(benefit['icon'], size: 20, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit['text'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ),
  );
}
  // Widget _buildFlightDetailsCard(
  //   BuildContext context,
  //   AirlineBookingProvider provider,
  //   Flight flight,
  //   String travelClass,
  //   int flightNumber,
  //   bool isLargeScreen,
  // ) {
  //   final price = (travelClass == 'Economy'
  //           ? flight.economyPrice
  //           : flight.businessPrice) *
  //       provider.currencyRates[provider.currency]!;
  //   final benefits = travelClass == 'Economy' ? _economyBenefits : _businessBenefits;

  //   return Card(
  //     color: Colors.white.withOpacity(0.9),
  //     elevation: 6,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             widget.isMultiCity ? 'Flight $flightNumber' : 'Selected Flight',
  //             style: GoogleFonts.poppins(
  //               fontSize: 20,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Class: $travelClass',
  //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //           ),
  //           Text(
  //             'Date: ${flight.date}',
  //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //           ),
  //           Text(
  //             'Time: ${flight.time}',
  //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //           ),
  //           Text(
  //             'Duration: ${flight.duration}',
  //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //           ),
  //           Text(
  //             'Stop: ${flight.stop}',
  //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //           ),
  //           Text(
  //             'Aircraft: ${flight.aircraft}',
  //             style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Price: ${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
  //             style: GoogleFonts.poppins(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w700,
  //               color: Colors.black,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             'Benefits:',
  //             style: GoogleFonts.poppins(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black,
  //             ),
  //           ),
  //           ...benefits.map((benefit) => Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 4),
  //                 child: Row(
  //                   children: [
  //                     Icon(benefit['icon'], size: 20, color: Colors.black54),
  //                     const SizedBox(width: 8),
  //                     Expanded(
  //                       child: Text(
  //                         benefit['text'],
  //                         style: GoogleFonts.poppins(
  //                           fontSize: 14,
  //                           color: Colors.black54,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Builds price summary
  Widget _buildPriceSummary(
    BuildContext context,
    AirlineBookingProvider provider,
    double totalPrice,
    bool isLargeScreen,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Summary',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.flights.asMap().entries.map((entry) {
              final index = entry.key;
              final flight = entry.value;
              final travelClass = widget.travelClasses[index];
              final price = (travelClass == 'Economy'
                      ? flight.economyPrice
                      : flight.businessPrice) *
                  provider.currencyRates[provider.currency]!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isMultiCity
                          ? 'Flight ${index + 1} ($travelClass)'
                          : 'Flight ($travelClass)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${provider.getCurrencySymbol()}${price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${provider.getCurrencySymbol()}${totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds billing details form for Pay Direct
  Widget _buildBillingDetailsForm(BuildContext context, bool isLargeScreen) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _billingLastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _street1Controller,
              decoration: InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _zipCodeController,
                    decoration: InputDecoration(
                      labelText: 'Zip Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: 'Country Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  // Builds payment details form for Pay Direct
  Widget _buildPaymentDetailsForm(BuildContext context, bool isLargeScreen) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryMonthController,
                    decoration: InputDecoration(
                      labelText: 'MM',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _expiryYearController,
                    decoration: InputDecoration(
                      labelText: 'YYYY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _securityCodeController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardTypeController,
              decoration: InputDecoration(
                labelText: 'Card Type (e.g., Visa, MasterCard)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Builds confirm booking button
   Widget _buildConfirmButton(
    BuildContext context,
    AirlineBookingProvider provider,
    double totalPrice,
    bool isLargeScreen,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ElevatedButton(
          onPressed: () async {
            final dateFormatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            final ticketDateFormatter = DateFormat('yyyyMMdd');
            final now = DateTime.now();

            // Generate merchant transaction ID
            final merchantTxnId = 'TXN${now.millisecondsSinceEpoch}';

            // Get city data for mapping codes to city and country names
            final departureCities = _AirlineBookingPageState._departureCities;
            final destinationCities = _MultiCityBookingPageState._destinationCities;
            final allCities = [...departureCities, ...destinationCities];

            // Helper to get city details by code
            City? getCityByCode(String code) {
              return allCities.firstWhere(
                (city) => city.code == code,
                orElse: () => City(
                  city: 'Unknown',
                  country: 'Unknown',
                  airport: 'Unknown',
                  code: code,
                ),
              );
            }

            // Build flightData and legData
            List<Map<String, dynamic>> flightData = [];
            for (int i = 0; i < widget.flights.length; i++) {
              final flight = widget.flights[i];
              final classType = widget.travelClasses[i];
              final price = classType == 'Economy'
                  ? flight.economyPrice * provider.currencyRates[provider.currency]!
                  : flight.businessPrice * provider.currencyRates[provider.currency]!;
              totalPrice += price;

              // Extract city codes and names
              final fromCityCode = widget.isMultiCity
                  ? provider.multiCitySegments[i]['from']?.split(' — ')[0] ?? 'BOM'
                  : provider.from.split(' — ')[0];
              final toCityCode = widget.isMultiCity
                  ? provider.multiCitySegments[i]['to']?.split(' — ')[0] ?? 'JFK'
                  : provider.to.split(' — ')[0];
              final fromCity = getCityByCode(fromCityCode);
              final toCity = getCityByCode(toCityCode);

              // Get base date
              final baseDate = widget.isMultiCity
                  ? provider.multiCitySegments[i]['date'] as DateTime?
                  : provider.departureDate;
              if (baseDate == null) {
                throw Exception('Departure date is missing for segment ${i + 1}');
              }

              // Parse flight time (e.g., '06:00 - 15:30')
              final timeParts = flight.time.split(' - ');
              if (timeParts.length != 2) {
                throw Exception('Invalid flight time format: ${flight.time}');
              }
              final departureTimeParts = timeParts[0].split(':');
              final arrivalTimeParts = timeParts[1].split(':');
              if (departureTimeParts.length != 2 || arrivalTimeParts.length != 2) {
                throw Exception('Invalid time format in flight ${i + 1}');
              }

              // Construct DateTime objects
              final departureDateTime = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                int.parse(departureTimeParts[0]),
                int.parse(departureTimeParts[1]),
              );
              final arrivalDateTime = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                int.parse(arrivalTimeParts[0]),
                int.parse(arrivalTimeParts[1]),
              ).add(Duration(hours: flight.date.contains('-') ? 1 : 0));

              // Build legData for outbound flight
              List<Map<String, dynamic>> legData = [
                {
                  'routeId': '${i + 1}',
                  'legId': '1',
                  'flightNumber': flight.aircraft.split(' ').last,
                  'departureAirportCode': fromCityCode,
                  'departureCity': fromCity?.city,
                  // 'departureCountry': fromCity.country,
                  'departureDate': dateFormatter.format(departureDateTime.toUtc()),
                  'arrivalAirportCode': toCityCode,
                  'arrivalCity': toCity?.city,
                  // 'arrivalCountry': toCity.country,
                  'arrivalDate': dateFormatter.format(arrivalDateTime.toUtc()),
                  'carrierCode': flight.aircraft.split(' ')[0].substring(0, 2),
                  'serviceClass': classType.toUpperCase(),
                }
              ];

              // Add return leg for Round-trip
              if (!widget.isMultiCity &&
                  provider.tripType == 'Round-trip' &&
                  provider.returnDate != null) {
                final returnDeparture = provider.returnDate!;
                final returnArrival = returnDeparture
                    .add(Duration(hours: int.parse(flight.duration.split('h')[0])));
                legData.add({
                  'routeId': '2',
                  'legId': '1',
                  'flightNumber': 'RETURN${flight.aircraft.split(' ').last}',
                  'departureAirportCode': toCityCode,
                  'departureCity': toCity?.city,
                  // 'departureCountry': toCity.country,
                  'departureDate': dateFormatter.format(returnDeparture.toUtc()),
                  'arrivalAirportCode': fromCityCode,
                  'arrivalCity': fromCity?.city,
                  // 'arrivalCountry': fromCity.country,
                  'arrivalDate': dateFormatter.format(returnArrival.toUtc()),
                  'carrierCode': flight.aircraft.split(' ')[0].substring(0, 2),
                  'serviceClass': classType.toUpperCase(),
                });
              }

              // Build flightData entry
              flightData.add({
                'journeyType': widget.isMultiCity
                    ? 'RETURN'
                    : provider.tripType == 'Round-trip'
                        ? 'RETURN'
                        : 'ONEWAY',
                // 'ticketNumber': 'TICKET${merchantTxnId.substring(3)}',
                'reservationDate': ticketDateFormatter.format(baseDate),
                'legData': legData,
                'passengerData': [
                  {
                    'firstName': widget.isPayDirect
                        ? _firstNameController.text
                        : 'Sam', // Mock for Pay Collect
                    'lastName': widget.isPayDirect
                        ? _lastNameController.text
                        : 'Thomas', // Mock for Pay Collect
                  }
                ],
              });
            }

            if (widget.isPayDirect) {
              if (!_validatePayDirectForm()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please fill all billing and payment fields',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final paymentData = {
                'merchantTxnId': merchantTxnId,
                'paymentData': {
                  'totalAmount': totalPrice.toStringAsFixed(2),
                  'txnCurrency': provider.currency,
                  'cardData': {
                    'number': _cardNumberController.text,
                    'expiryMonth': _expiryMonthController.text,
                    'expiryYear': _expiryYearController.text,
                    'securityCode': _securityCodeController.text,
                  },
                  'billingData': {
                    'firstName': _firstNameController.text,
                    'lastName': _billingLastNameController.text,
                    'addressStreet1': _street1Controller.text,
                    'addressCity': _cityController.text,
                    'addressState': _stateController.text,
                    'addressCountry': _countryController.text,
                    'emailId': _emailController.text,
                  },
                },
                'riskData': {
                  'flightData': flightData,
                },
                'merchantCallbackURL':
                    'https://api.uat.payglocal.in/gl/v1/payments/merchantCallback',
              };

              try {
                await handleAuthPayment(context, paymentData);
                // _showBookingConfirmation(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment failed: $e',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              final bookingDetails = {
                'merchantTxnId': merchantTxnId,
                'paymentData': {
                  'totalAmount': totalPrice.toStringAsFixed(2),
                  'txnCurrency': provider.currency,
                },
                'riskData': {
                  'flightData': flightData,
                },
                'merchantCallbackURL':
                    'https://api.uat.payglocal.in/gl/v1/payments/merchantCallback',
              };

              try {
                await handleAuthPayment(context, bookingDetails);
                _showBookingConfirmation(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking failed: $e',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 24, 26, 55),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            'Confirm Booking with Payglocal',
            style: GoogleFonts.poppins(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Calculates total price
  double _calculateTotalPrice(AirlineBookingProvider provider) {
    double total = 0.0;
    for (int i = 0; i < widget.flights.length; i++) {
      final flight = widget.flights[i];
      final travelClass = widget.travelClasses[i];
      final price = travelClass == 'Economy'
          ? flight.economyPrice
          : flight.businessPrice;
      total += price * provider.currencyRates[provider.currency]! * provider.passengers;
    }
    return total;
  }

  // Validates Pay Direct form fields
  bool _validatePayDirectForm() {
    return _billingLastNameController.text.isNotEmpty &&
        _street1Controller.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _zipCodeController.text.isNotEmpty &&
        _countryController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _cardNumberController.text.isNotEmpty &&
        _expiryMonthController.text.isNotEmpty &&
        _expiryYearController.text.isNotEmpty &&
        _cardTypeController.text.isNotEmpty &&
        _securityCodeController.text.isNotEmpty;
  }

  // Shows booking confirmation dialog
  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white.withOpacity(0.9),
        title: Text(
          'Booking Confirmed',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Your booking has been successfully confirmed. You will receive a confirmation email shortly.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}








