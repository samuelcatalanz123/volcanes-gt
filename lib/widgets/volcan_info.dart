import 'package:flutter/material.dart';
import '../models/volcan.dart';

/// Muestra la info de un volcán en una hoja inferior (bottom sheet).
void mostrarVolcanInfo(BuildContext context, Volcan v) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.terrain, size: 18),
            const SizedBox(width: 6),
            Text('${v.alturaM} m  ·  ${v.departamento}'),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Icon(v.activo ? Icons.local_fire_department : Icons.check_circle,
                size: 18, color: v.activo ? Colors.red : Colors.green),
            const SizedBox(width: 6),
            Text(v.activo ? 'Volcán ACTIVO' : 'Inactivo'),
          ]),
          const SizedBox(height: 12),
          Text(v.consejo, style: const TextStyle(height: 1.4)),
        ],
      ),
    ),
  );
}
