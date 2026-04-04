import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_flutter/main.dart';
import 'package:projeto_flutter/screens/login_screen.dart';
import 'package:projeto_flutter/screens/home_screen.dart';
import 'package:projeto_flutter/screens/saiba_mais_screen.dart';

void main() {
  group('FitStartApp', () {
    testWidgets('starts on the LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const FitStartApp());
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('LoginScreen shows app name and form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FitStartApp());
      expect(find.text('FitStart'), findsWidgets);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
    });

    testWidgets('login form shows validation errors when submitted empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FitStartApp());
      await tester.tap(find.text('ENTRAR'));
      await tester.pump();
      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('navigates to HomeScreen after valid login',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FitStartApp());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'teste@email.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Senha'), 'senha123');
      await tester.tap(find.text('ENTRAR'));
      await tester.pump(); // start animation/loading

      // Advance past the simulated loading delay
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('HomeScreen shows navigation buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      expect(find.text('SAIBA MAIS'), findsOneWidget);
      expect(find.text('SAIR DA CONTA'), findsOneWidget);
    });

    testWidgets('HomeScreen navigates to SaibaMaisScreen on button press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.tap(find.text('SAIBA MAIS'));
      await tester.pumpAndSettle();
      expect(find.byType(SaibaMaisScreen), findsOneWidget);
    });

    testWidgets('SaibaMaisScreen shows back button and tips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SaibaMaisScreen()),
      );
      expect(find.text('Saiba Mais'), findsOneWidget);
      expect(find.text('Dicas para Iniciantes'), findsOneWidget);
      expect(find.text('VOLTAR'), findsOneWidget);
    });

    testWidgets('HomeScreen logoff dialog shows when logout icon is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );
      await tester.tap(find.byIcon(Icons.logout).first);
      await tester.pumpAndSettle();
      expect(find.text('Sair'), findsOneWidget);
      expect(
          find.text('Deseja realmente sair da sua conta?'), findsOneWidget);
    });
  });
}
