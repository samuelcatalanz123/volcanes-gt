import 'package:flutter/material.dart';

/// Carga una imagen desde un asset local (si la ruta empieza con 'assets/') o
/// desde internet (si es una URL). Así un lugar puede tener su foto local
/// (p. ej. la garita de Escuintla) o de la web, sin cambiar el resto del código.
Image imagenDeFoto(
  String ruta, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (ruta.startsWith('assets/')) {
    return Image.asset(ruta,
        width: width, height: height, fit: fit, errorBuilder: errorBuilder);
  }
  return Image.network(ruta,
      width: width, height: height, fit: fit, errorBuilder: errorBuilder);
}

/// Muestra una foto (local o de internet), con esquinas redondeadas.
/// Si falla, muestra un ícono de respaldo.
class FotoLugar extends StatelessWidget {
  final String url;
  const FotoLugar({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      // Image SIMPLE: en Flutter web, loadingBuilder/frameBuilder a veces
      // dejan la imagen invisible. Sin ellos, carga igual que el mapa.
      child: imagenDeFoto(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        // Si la imagen no se puede cargar, muestra un respaldo.
        errorBuilder: (context, error, stack) => Container(
          height: 180,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image_not_supported,
                size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
