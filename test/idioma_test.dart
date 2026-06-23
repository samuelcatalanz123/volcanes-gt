import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volcanes_gt/services/idioma.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('por defecto español; alternar cambia a inglés y guarda', () async {
    SharedPreferences.setMockInitialValues({});
    await Idioma.cargar();
    expect(Idioma.esIngles, false);
    expect(tr('Hola', 'Hello'), 'Hola');

    await Idioma.alternar();
    expect(Idioma.esIngles, true);
    expect(tr('Hola', 'Hello'), 'Hello');
  });

  test('recuerda el idioma inglés guardado', () async {
    SharedPreferences.setMockInitialValues({'idioma_ingles': true});
    await Idioma.cargar();
    expect(Idioma.esIngles, true);
  });
}
