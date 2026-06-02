import 'package:flutter/material.dart';
import '../services/clima.dart';

/// Muestra el clima actual de unas coordenadas dentro de una tarjeta.
/// Mientras carga muestra "Cargando clima…"; si falla, un aviso amable.
class ClimaVista extends StatelessWidget {
  final double lat;
  final double lng;
  const ClimaVista({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder llama a obtenerClima y se redibuja cuando llega la respuesta.
    return FutureBuilder<Clima?>(
      future: obtenerClima(lat, lng),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Row(children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('Cargando clima…'),
          ]);
        }
        final clima = snap.data;
        if (clima == null) {
          return const Row(children: [
            Icon(Icons.cloud_off, size: 18, color: Colors.grey),
            SizedBox(width: 6),
            Text('Clima no disponible'),
          ]);
        }
        return Row(children: [
          Text(clima.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text('${clima.tempC.toStringAsFixed(1)} °C · ${clima.descripcion}'),
        ]);
      },
    );
  }
}
