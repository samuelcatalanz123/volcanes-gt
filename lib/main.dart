import 'package:flutter/material.dart';
import 'screens/mapa_screen.dart';
import 'services/favoritos.dart';
import 'services/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Favoritos.cargar(); // recupera los favoritos guardados
  await Tema.cargar(); // recupera el tema (claro/oscuro) guardado
  runApp(const VolcanesApp());
}

class VolcanesApp extends StatelessWidget {
  const VolcanesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se redibuja sola cuando el usuario cambia entre claro y oscuro.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: Tema.modo,
      builder: (context, modo, _) => MaterialApp(
        title: 'Volcanes GT',
        theme:
            ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.deepOrange,
            brightness: Brightness.dark,
            useMaterial3: true),
        themeMode: modo,
        home: const MapaScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
