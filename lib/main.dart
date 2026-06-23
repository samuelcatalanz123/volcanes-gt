import 'package:flutter/material.dart';
import 'screens/mapa_screen.dart';
import 'services/favoritos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Favoritos.cargar(); // recupera los favoritos guardados
  runApp(const VolcanesApp());
}

class VolcanesApp extends StatelessWidget {
  const VolcanesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volcanes GT',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: const MapaScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
