import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/volcan.dart';

/// Muestra la info de un volcán en una hoja inferior (bottom sheet).
/// Si [desde] no es null (la ubicación del usuario), muestra la distancia.
void mostrarVolcanInfo(BuildContext context, Volcan v, {LatLng? desde}) {
  // Calcula la distancia en kilómetros desde el usuario hasta el volcán.
  String? distanciaTexto;
  if (desde != null) {
    final metros = const Distance().as(LengthUnit.Meter, desde, v.punto);
    distanciaTexto = 'A ${(metros / 1000).toStringAsFixed(1)} km de ti';
  }

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
          if (distanciaTexto != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.straighten, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Text(distanciaTexto),
            ]),
          ],
          const SizedBox(height: 12),
          Text(v.consejo, style: const TextStyle(height: 1.4)),
        ],
      ),
    ),
  );
}
