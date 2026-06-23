import 'package:flutter/material.dart';
import 'screens/mapa_screen.dart';
import 'services/favoritos.dart';
import 'services/tema.dart';
import 'services/idioma.dart';
import 'services/conexion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Favoritos.cargar(); // recupera los favoritos guardados
  await Tema.cargar(); // recupera el tema (claro/oscuro) guardado
  await Idioma.cargar(); // recupera el idioma (español/inglés) guardado
  await Conexion.iniciar(); // empieza a vigilar la conexión a internet
  runApp(const VolcanesApp());
}

class VolcanesApp extends StatelessWidget {
  const VolcanesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se redibuja sola cuando cambia el tema (claro/oscuro) o el idioma.
    return ListenableBuilder(
      listenable: Listenable.merge([Tema.modo, Idioma.ingles]),
      builder: (context, _) => MaterialApp(
        title: 'Volcanes GT',
        theme:
            ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.deepOrange,
            brightness: Brightness.dark,
            useMaterial3: true),
        themeMode: Tema.modo.value,
        home: const MapaScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
