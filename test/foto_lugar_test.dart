import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volcanes_gt/widgets/foto_lugar.dart';

void main() {
  test('imagenDeFoto usa asset local para rutas que empiezan con assets/', () {
    final img = imagenDeFoto('assets/fotos/garita-escuintla.jpg');
    expect(img.image, isA<AssetImage>());
  });

  test('imagenDeFoto usa internet para las URLs', () {
    final img = imagenDeFoto('https://ejemplo.com/foto.jpg');
    expect(img.image, isA<NetworkImage>());
  });
}
