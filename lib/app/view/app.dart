import 'package:flutter/material.dart';
import 'package:marikinanavigator_app/counter/counter.dart';
import 'package:marikinanavigator_app/l10n/l10n.dart';
import 'package:marikinanavigator_app/landing/view/landing.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LandingPage(),
    );
  }
}
