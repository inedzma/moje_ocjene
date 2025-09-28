import 'package:flutter/material.dart';
import 'package:moje_ocjene/providers/predmeti_provider.dart';
import 'package:moje_ocjene/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (_) => PredmetiProvider()..ucitajPredmete(),
        child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moje Ocjene',
      home: HomeScreen()
    );
  }
}

