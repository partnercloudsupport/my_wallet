// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:my_wallet/ui/splash/presentation/view/splash_view.dart';
import 'package:my_wallet/ui/user/login/presentation/view/login_view.dart';
import 'package:my_wallet/ui/user/register/presentation/view/register_view.dart';

void main() {
  testWidgets('Test splash screen', (WidgetTester tester) async {
    // Start app with out user or home
    await tester.pumpWidget(MaterialApp(
      home: SplashView(),
    ));

    expect(find.text('Loading data...'), findsOneWidget);
  });

  testWidgets('Test Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Login(),
    ));

    // expect to open Login page
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register your email'), findsOneWidget);
  });

  testWidgets('Test Register new user screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Register(),
    ));

    // verify content on Register your email
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('Sample Name'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('SampleEmail@domain.com'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('samplepassword'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
