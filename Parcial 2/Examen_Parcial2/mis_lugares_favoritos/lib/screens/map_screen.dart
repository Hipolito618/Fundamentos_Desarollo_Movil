import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/theme_provider.dart';
import '../widgets/theme_toggle.dart';
import 'home_screen.dart'; // Para importar el modelo Place

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  
  // Ubicación actual simulada (San Luis Potosí, Capital)
  final LatLng myLocation = const LatLng(22.1565, -100.9855);
  
  Place? selectedPlace;
  bool isCardVisible = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Lugares de prueba

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(
        begin: mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _onPlaceTap(Place place) {
    setState(() {
      selectedPlace = place;
      isCardVisible = true;
    });
    // Centrar suavemente y hacer zoom
    _animatedMapMove(LatLng(place.latitude, place.longitude), 16.0);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (isCardVisible) {
      setState(() => isCardVisible = false);
    }
  }

  void _goToMyLocation() {
    if (isCardVisible) setState(() => isCardVisible = false);
    _animatedMapMove(myLocation, 15.0);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'comida': return Icons.local_cafe_rounded;
      case 'deporte': return Icons.fitness_center_rounded;
      case 'estudio': return Icons.school_rounded;
      case 'casa': return Icons.home_rounded;
      default: return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final placesList = ref.watch(placesProvider).maybeWhen(
      data: (data) => data,
      orElse: () => <Place>[],
    );

    final tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Mapa
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: myLocation,
              initialZoom: 14.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'mx.edu.parcial2.mislugares.app',
              ),
              MarkerLayer(
                markers: [
                  // Marcador "Mi ubicación" animado
                  Marker(
                    point: myLocation,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 30 * _pulseAnimation.value,
                              height: 30 * _pulseAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withOpacity(0.3),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.navigation_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  // Pines de Lugares
                  ...placesList.map((place) => Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 50,
                        height: 50,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _onPlaceTap(place),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _getCategoryIcon(place.category),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              // Punto inferior del pin
                              Container(
                                width: 4,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // 2. Floating App Bar Superior
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.colorScheme.onSurface),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mis Lugares Favoritos',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const ThemeToggle(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.05 : 0.05),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar en el mapa...',
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Botón flotante para mi ubicación
          Positioned(
            right: 20,
            bottom: isCardVisible ? 220 : 30, // Sube si la tarjeta está visible
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: FloatingActionButton(
                heroTag: 'myLocationBtn',
                mini: true,
                backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                foregroundColor: theme.colorScheme.primary,
                onPressed: _goToMyLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),

          // 4. Smooth Card Inferior (Detalles del lugar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            left: 20,
            right: 20,
            bottom: isCardVisible ? 30 : -250, // Animación de subida/bajada
            child: selectedPlace == null ? const SizedBox.shrink() : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'map_image_${selectedPlace!.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            selectedPlace!.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, err, stack) => Container(
                              width: 80, height: 80, color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPlace!.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                selectedPlace!.category,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text(
                                  '1.2 km', // Simulado
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => isCardVisible = false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: BorderSide(color: isDark ? Colors.redAccent.withOpacity(0.5) : Colors.redAccent.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

