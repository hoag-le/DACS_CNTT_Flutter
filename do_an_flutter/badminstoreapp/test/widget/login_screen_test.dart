import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badminstoreapp/page/login_register_forget/login.dart';

void main() {
  testWidgets('LoginScreen shows required fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
  });

  testWidgets('LoginScreen shows error on empty email', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Find the login button
    final loginButton = find.widgetWithText(ElevatedButton, 'Đăng nhập');
    expect(loginButton, findsOneWidget);

    // Tap the login button without entering anything
    await tester.tap(loginButton);
    await tester.pump();

    // Should show error message
    expect(find.text('Email không được để trống'), findsOneWidget);
  });

  testWidgets('LoginScreen shows error on empty password', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter email
    final emailField = find.byType(TextField).first;
    await tester.enterText(emailField, 'test@test.com');

    // Tap the login button without entering password
    final loginButton = find.widgetWithText(ElevatedButton, 'Đăng nhập');
    await tester.tap(loginButton);
    await tester.pump();

    // Should show error message
    expect(find.text('Mật khẩu không được để trống'), findsOneWidget);
  });
}
