import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volcanes_gt/services/tema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('por defecto sigue el sistema; alternar cambia y guarda', () async {
    SharedPreferences.setMockInitialValues({});
    await Tema.cargar();
    expect(Tema.modo.value, ThemeMode.system);

    await Tema.alternar();
    expect(Tema.modo.value, ThemeMode.dark);
    expect(Tema.esOscuro, true);

    await Tema.alternar();
    expect(Tema.modo.value, ThemeMode.light);
  });

  test('recuerda el tema oscuro guardado', () async {
    SharedPreferences.setMockInitialValues({'tema_oscuro': true});
    await Tema.cargar();
    expect(Tema.modo.value, ThemeMode.dark);
  });
}
