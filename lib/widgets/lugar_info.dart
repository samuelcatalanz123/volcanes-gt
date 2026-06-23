import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lugar.dart';
import '../screens/navegacion_screen.dart';
import '../services/favoritos.dart';
import 'datos_extra.dart';
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
    case TipoLugar.sitio:
      return Icons.castle;
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
    case TipoLugar.sitio:
      return Colors.teal;
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
    case TipoLugar.sitio:
      return 'Sitios';
  }
}

/// Abre Google Maps con la ruta desde la ubicación del usuario hasta el lugar.
Future<void> _comoLlegar(Lugar l) async {
  // travelmode=driving + dir_action=navigate arranca la navegación EN CARRO
  // (Google Maps te va guiando por voz: "gira aquí, sigue derecho").
  final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${l.lat},${l.lng}'
      '&travelmode=driving&dir_action=navigate');
  await launchUrl(url,
      mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
}

/// Comparte el lugar por WhatsApp, con un mensaje y un enlace a su ubicación.
Future<void> _compartir(Lugar l) async {
  final ubic =
      'https://www.google.com/maps/search/?api=1&query=${l.lat},${l.lng}';
  final texto = Uri.encodeComponent(
      '¡Visita ${l.nombre} en Guatemala! 🌋\n$ubic\n\nCompartido desde Volcanes GT');
  await launchUrl(Uri.parse('https://wa.me/?text=$texto'),
      mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
}

/// Muestra la info de un lugar en una hoja inferior (bottom sheet).
void mostrarLugarInfo(BuildContext context, Lugar l) {
  final ctxRaiz = context; // para abrir la pantalla de navegación
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galería (si tiene varias fotos) o una sola foto.
          if (l.fotos != null && l.fotos!.length > 1) ...[
            GaleriaFotos(fotos: l.fotos!),
            const SizedBox(height: 12),
          ] else if (l.foto != null) ...[
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
            BotonFavorito(nombre: l.nombre),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.place, size: 18),
            const SizedBox(width: 6),
            Text(l.departamento),
          ]),
          const SizedBox(height: 12),
          Text(l.descripcion, style: const TextStyle(height: 1.4)),
          DatosExtra(
            mejorEpoca: l.mejorEpoca,
            entrada: l.entrada,
            comida: l.comida,
            dato: l.dato,
          ),
          const SizedBox(height: 16),
          // Botón principal: navegación por voz DENTRO de la app.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  ctxRaiz,
                  MaterialPageRoute(
                    builder: (_) => NavegacionScreen(
                        destino: l.punto, nombreDestino: l.nombre),
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Navegar con voz 🗣️'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _comoLlegar(l),
              icon: const Icon(Icons.map),
              label: const Text('Abrir en Google Maps'),
            ),
          ),
          const SizedBox(height: 8),
          // Compartir el lugar por WhatsApp.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _compartir(l),
              icon: const Icon(Icons.share),
              label: const Text('Compartir 📲'),
            ),
          ),
        ],
      ),
    ),
  );
}
