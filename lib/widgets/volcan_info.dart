import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/volcan.dart';
import 'foto_lugar.dart';
import 'clima_vista.dart';

/// Abre Google Maps con la ruta desde la ubicación del usuario hasta el volcán.
Future<void> _comoLlegar(Volcan v) async {
  final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${v.lat},${v.lng}');
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

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
          // Foto del volcán (si tiene), con respaldo si no carga.
          if (v.foto != null) ...[
            FotoLugar(url: v.foto!),
            const SizedBox(height: 12),
          ],
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
          // Clima actual del volcán (se pide a internet al abrir la tarjeta).
          const SizedBox(height: 6),
          ClimaVista(lat: v.lat, lng: v.lng),
          const SizedBox(height: 12),
          Text(v.consejo, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          // Botón para abrir la ruta en Google Maps.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _comoLlegar(v),
              icon: const Icon(Icons.directions),
              label: const Text('Cómo llegar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
