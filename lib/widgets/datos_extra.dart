import 'package:flutter/material.dart';
import '../services/idioma.dart';

/// Muestra los datos extra de un lugar o volcán —mejor época, entrada, comida
/// típica y un dato curioso— pero SOLO las filas que no son null. Si no hay
/// ninguna, no ocupa espacio.
class DatosExtra extends StatelessWidget {
  final String? mejorEpoca;
  final String? entrada;
  final String? comida;
  final String? dato;

  const DatosExtra({
    super.key,
    this.mejorEpoca,
    this.entrada,
    this.comida,
    this.dato,
  });

  @override
  Widget build(BuildContext context) {
    final filas = <Widget>[
      if (mejorEpoca != null)
        _fila('📅', tr('Mejor época', 'Best time'), mejorEpoca!),
      if (entrada != null) _fila('🎟️', tr('Entrada', 'Entrance'), entrada!),
      if (comida != null)
        _fila('🍲', tr('Comida típica', 'Typical food'), comida!),
      if (dato != null) _fila('💡', tr('¿Sabías que…?', 'Did you know…?'), dato!),
    ];
    if (filas.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final f in filas) ...[const SizedBox(height: 8), f],
      ],
    );
  }

  Widget _fila(String emoji, String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: '$etiqueta: ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: valor),
            ]),
            style: const TextStyle(height: 1.3),
          ),
        ),
      ],
    );
  }
}
