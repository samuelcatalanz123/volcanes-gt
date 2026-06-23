import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volcanes_gt/services/favoritos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('marca, desmarca y recuerda un favorito', () async {
    SharedPreferences.setMockInitialValues({});
    await Favoritos.cargar();
    expect(Favoritos.esFavorito('Tikal'), false);

    await Favoritos.alternar('Tikal');
    expect(Favoritos.esFavorito('Tikal'), true);

    await Favoritos.alternar('Tikal'); // tocar otra vez = quitar
    expect(Favoritos.esFavorito('Tikal'), false);
  });

  test('los favoritos guardados se recuperan al cargar', () async {
    SharedPreferences.setMockInitialValues({
      'favoritos': ['Semuc Champey'],
    });
    await Favoritos.cargar();
    expect(Favoritos.esFavorito('Semuc Champey'), true);
  });
}
