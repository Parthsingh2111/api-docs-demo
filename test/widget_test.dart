import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centralproject/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PayGlocalProdDemoApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that the home screen is displayed
    expect(find.text('PayGlocal Showcase'), findsOneWidget);
  });
}
