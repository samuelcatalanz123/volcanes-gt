import 'package:flutter/material.dart';
import 'screens/mapa_screen.dart';
import 'services/favoritos.dart';
import 'services/tema.dart';
import 'services/idioma.dart';
import 'services/conexion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cada servicio se carga por separado y protegido: si uno falla (p. ej. un
  // plugin que no está disponible en el navegador), la app NO se queda en
  // blanco; sigue funcionando con valores por defecto.
  await _intentar(Favoritos.cargar); // favoritos guardados
  await _intentar(Tema.cargar); // tema claro/oscuro
  await _intentar(Idioma.cargar); // idioma español/inglés
  await _intentar(Conexion.iniciar); // vigilancia de la conexión
  runApp(const VolcanesApp());
}

/// Ejecuta [accion] y se traga cualquier error, para que un servicio que falle
/// al arrancar nunca impida que la app se dibuje.
Future<void> _intentar(Future<void> Function() accion) async {
  try {
    await accion();
  } catch (_) {
    // Seguimos con los valores por defecto.
  }
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
