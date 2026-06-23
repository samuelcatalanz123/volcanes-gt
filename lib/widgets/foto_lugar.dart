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

/// Galería de varias fotos que se deslizan de lado, con un contador (1/3).
/// Si solo hay una foto, se ve igual que [FotoLugar].
class GaleriaFotos extends StatefulWidget {
  final List<String> fotos;
  const GaleriaFotos({super.key, required this.fotos});

  @override
  State<GaleriaFotos> createState() => _GaleriaFotosState();
}

class _GaleriaFotosState extends State<GaleriaFotos> {
  final _pagina = PageController();
  int _actual = 0;

  @override
  void dispose() {
    _pagina.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pagina,
              itemCount: widget.fotos.length,
              onPageChanged: (i) => setState(() => _actual = i),
              itemBuilder: (context, i) => imagenDeFoto(
                widget.fotos[i],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          // Contador "2/3" abajo a la derecha.
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${_actual + 1}/${widget.fotos.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
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
