import 'package:flutter_test/flutter_test.dart';
import 'package:volcanes_gt/services/busqueda.dart';

void main() {
  test('el buscador encuentra "Antigua" (es un lugar, no un volcán)', () {
    final res = buscarTodo('Antigua');
    expect(
      res.any((r) => r.nombre.toLowerCase().contains('antigua')),
      true,
      reason: 'Debería encontrar "La Antigua Guatemala" al buscar Antigua',
    );
  });

  test('el buscador sigue encontrando volcanes (ej. "Tajumulco")', () {
    final res = buscarTodo('Tajumulco');
    expect(res.any((r) => r.nombre.contains('Tajumulco')), true);
  });

  test('buscar por departamento devuelve volcanes y lugares de ahí', () {
    final res = buscarTodo('Sacatepéquez');
    expect(res.any((r) => r.esVolcan), true,
        reason: 'hay volcanes en Sacatepéquez');
    expect(res.any((r) => !r.esVolcan && r.nombre.contains('Antigua')), true,
        reason: 'Antigua está en Sacatepéquez');
  });

  test('con búsqueda vacía devuelve TODO (volcanes + lugares)', () {
    final res = buscarTodo('');
    expect(res.any((r) => r.esVolcan), true);
    expect(res.any((r) => !r.esVolcan), true);
  });
}
