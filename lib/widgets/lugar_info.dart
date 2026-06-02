import 'package:flutter/material.dart';
import '../models/lugar.dart';

/// El ícono que representa cada tipo de lugar.
IconData iconoDe(TipoLugar tipo) {
  switch (tipo) {
    case TipoLugar.lago:
      return Icons.water;
    case TipoLugar.playa:
      return Icons.beach_access;
    case TipoLugar.montana:
      return Icons.landscape;
  }
}

/// El color que representa cada tipo de lugar.
Color colorDe(TipoLugar tipo) {
  switch (tipo) {
    case TipoLugar.lago:
      return Colors.blue;
    case TipoLugar.playa:
      return Colors.orange;
    case TipoLugar.montana:
      return Colors.brown;
  }
}

/// Nombre legible del tipo (para la leyenda y los botones).
String nombreTipo(TipoLugar tipo) {
  switch (tipo) {
    case TipoLugar.lago:
      return 'Lagos';
    case TipoLugar.playa:
      return 'Playas';
    case TipoLugar.montana:
      return 'Montañas';
  }
}

/// Muestra la info de un lugar en una hoja inferior (bottom sheet).
void mostrarLugarInfo(BuildContext context, Lugar l) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(iconoDe(l.tipo), color: colorDe(l.tipo)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l.nombre,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.place, size: 18),
            const SizedBox(width: 6),
            Text(l.departamento),
          ]),
          const SizedBox(height: 12),
          Text(l.descripcion, style: const TextStyle(height: 1.4)),
        ],
      ),
    ),
  );
}
