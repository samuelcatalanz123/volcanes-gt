import 'package:flutter_test/flutter_test.dart';
import 'package:volcanes_gt/data/volcanes.dart';

void main() {
  test('hay varios volcanes y todos tienen datos válidos', () {
    expect(volcanes.length, greaterThanOrEqualTo(8));
    for (final v in volcanes) {
      expect(v.nombre.isNotEmpty, true, reason: 'nombre vacío');
      expect(v.alturaM, greaterThan(0), reason: '${v.nombre} sin altura');
      // Coordenadas dentro de Guatemala (aprox).
      expect(v.lat, inInclusiveRange(13.5, 18.0), reason: '${v.nombre} lat fuera de rango');
      expect(v.lng, inInclusiveRange(-92.5, -88.0), reason: '${v.nombre} lng fuera de rango');
      expect(v.consejo.isNotEmpty, true, reason: '${v.nombre} sin consejo');
    }
  });
}
