import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/theme_provider.dart';
import '../widgets/theme_toggle.dart';
import 'map_screen.dart';
import 'place_form_screen.dart';

// Modelo
class Place {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}

// Provider de estado
final placesProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final response = await supabase
        .from('places')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Place.fromJson(e)).toList();
  } catch (e) {
    if (e.toString().contains('Usuario no autenticado') || e.toString().contains('initialize') || e is NoSuchMethodError) {
      // Mock data para testing visual sin Supabase
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        Place(id: '1', name: 'Mi Café Favorito', category: 'Comida', imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24', latitude: 0, longitude: 0),
        Place(id: '2', name: 'Gimnasio', category: 'Deporte', imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48', latitude: 0, longitude: 0),
        Place(id: '3', name: 'Biblioteca Central', category: 'Estudio', imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66', latitude: 0, longitude: 0),
      ];
    }
    // Si es un error real de Supabase (ej. RLS), lo propagamos para que se vea en UI
    throw e;
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String searchQuery = '';
  String selectedCategory = 'Todos';
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'Todos', 'icon': null},
    {'name': 'Comida', 'icon': '☕'},
    {'name': 'Estudio', 'icon': '🎓'},
    {'name': 'Deporte', 'icon': '🏋️'},
    {'name': 'Diversión', 'icon': '😃'},
  ];

  void _confirmDelete(Place place) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar lugar'),
        content: Text('¿Seguro que deseas eliminar "${place.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              // Lógica de Supabase:
              // await Supabase.instance.client.from('places').delete().eq('id', place.id);
              // ref.invalidate(placesProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lugar eliminado (${place.name})'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    
    final placesAsync = ref.watch(placesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mis Lugares',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const ThemeToggle(),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.05 : 0.05),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Buscar lugar...',
                          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: theme.colorScheme.primary),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Categories Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Categories Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat['name'];
                  
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withOpacity(isDark ? 0.2 : 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (cat['icon'] != null) ...[
                            Text(cat['icon']),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            cat['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // List of Places
            Expanded(
              child: placesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (places) {
                  // Filtrado local
                  final filtered = places.where((p) {
                    final matchCat = selectedCategory == 'Todos' || p.category == selectedCategory;
                    final matchSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
                    return matchCat && matchSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Sin lugares registrados',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final place = filtered[index];
                      
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(place.id),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark 
                                  ? theme.colorScheme.primary.withOpacity(0.3)
                                  : theme.colorScheme.onSurface.withOpacity(0.1),
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                            ]
                          ),
                          child: Row(
                            children: [
                              // Hero Image
                              Hero(
                                tag: 'image_${place.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    place.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 80,
                                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        place.category,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.navigation_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '450m', // Ejemplo estático
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Actions
                              Align(
                                alignment: Alignment.topRight,
                                child: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      // Ir a editar
                                    } else if (value == 'delete') {
                                      _confirmDelete(place);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 20),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                          SizedBox(width: 8),
                                          Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PlaceFormScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home_filled, color: theme.colorScheme.primary), onPressed: () {}),
            IconButton(
              icon: Icon(Icons.explore_outlined, color: theme.colorScheme.onSurface.withOpacity(0.4)), 
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
            ),
            IconButton(icon: Icon(Icons.favorite_border, color: theme.colorScheme.onSurface.withOpacity(0.4)), onPressed: () {}),
            IconButton(icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.4)), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
