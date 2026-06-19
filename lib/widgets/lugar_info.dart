import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lugar.dart';
import 'foto_lugar.dart';

/// El ícono que representa cada tipo de lugar.
IconData iconoDe(TipoLugar tipo) {
  switch (tipo) {
    case TipoLugar.lago:
      return Icons.water;
    case TipoLugar.playa:
      return Icons.beach_access;
    case TipoLugar.montana:
      return Icons.landscape;
    case TipoLugar.ciudad:
      return Icons.location_city;
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
    case TipoLugar.ciudad:
      return Colors.purple;
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
    case TipoLugar.ciudad:
      return 'Ciudades';
  }
}

/// Abre Google Maps con la ruta desde la ubicación del usuario hasta el lugar.
Future<void> _comoLlegar(Lugar l) async {
  final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${l.lat},${l.lng}');
  await launchUrl(url, mode: LaunchMode.externalApplication);
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
          // Foto del lugar (si tiene), con respaldo si no carga.
          if (l.foto != null) ...[
            FotoLugar(url: l.foto!),
            const SizedBox(height: 12),
          ],
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
          const SizedBox(height: 16),
          // Botón para abrir la ruta en Google Maps (desde tu ubicación).
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _comoLlegar(l),
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
