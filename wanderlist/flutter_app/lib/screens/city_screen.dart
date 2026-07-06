import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/place_card.dart';
import '../widgets/places_map.dart';

class CityScreen extends ConsumerStatefulWidget {
  final int cityId;
  const CityScreen({super.key, required this.cityId});

  @override
  ConsumerState<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends ConsumerState<CityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _showMap = false;

  static const _foodTags = ['Colazione','Brunch','Pranzo','Pranzo veloce','Merenda','Aperitivo','Cena','Dopocena'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(citiesProvider).valueOrNull
        ?.firstWhereOrNull((c) => c.id == widget.cityId);
    final filter = ref.watch(placesFilterProvider(widget.cityId));
    final placesAsync = ref.watch(placesProvider(filter));
    final catsAsync = ref.watch(categoriesProvider(widget.cityId));
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city?.name ?? '…'),
            if (city?.country != null)
              Text(city!.country!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.inkLight)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.grid_view : Icons.map_outlined),
            tooltip: _showMap ? 'Vista griglia' : 'Vista mappa',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Filtri',
            onPressed: () => _showFilterSheet(catsAsync.valueOrNull ?? []),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.terra,
          unselectedLabelColor: AppTheme.inkLight,
          indicatorColor: AppTheme.terra,
          tabs: const [
            Tab(text: '🍽️  Mangiare', icon: null),
            Tab(text: '🗺️  Visitare', icon: null),
          ],
          onTap: (i) {
            ref.read(placesFilterProvider(widget.cityId).notifier)
                .state = filter.copyWith(type: i == 0 ? 'food' : 'visit');
          },
        ),
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (places) {
          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_outlined, size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Nessun posto trovato', style: TextStyle(color: AppTheme.inkLight)),
                  if (filter.type.isNotEmpty || filter.category.isNotEmpty || filter.tag.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.read(placesFilterProvider(widget.cityId).notifier)
                          .state = PlacesFilter(cityId: widget.cityId),
                      child: const Text('Reset filtri'),
                    ),
                  ],
                ],
              ),
            );
          }

          if (_showMap) {
            return PlacesMap(places: places);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(placesProvider(filter)),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => PlaceCard(
                place: places[i],
                onFavToggle: () => ref.invalidate(placesProvider(filter)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/place-form', extra: {'cityId': widget.cityId});
                ref.invalidate(placesProvider(filter));
                ref.invalidate(categoriesProvider(widget.cityId));
              },
              backgroundColor: AppTheme.terra,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showFilterSheet(List<String> categories) {
    final filter = ref.read(placesFilterProvider(widget.cityId));
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSS) {
          var f = filter;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Filtri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(placesFilterProvider(widget.cityId).notifier).state =
                          PlacesFilter(cityId: widget.cityId);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset'),
                  ),
                ]),
                const SizedBox(height: 12),
                if (categories.isNotEmpty) ...[
                  const Text('Categoria', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkLight)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categories.map((c) => FilterChip(
                      label: Text(c),
                      selected: f.category == c,
                      onSelected: (v) => setSS(() => f = f.copyWith(category: v ? c : '')),
                      selectedColor: AppTheme.terra.withOpacity(0.15),
                      checkmarkColor: AppTheme.terra,
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text('Momento (food)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkLight)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _foodTags.map((t) => FilterChip(
                    label: Text(t),
                    selected: f.tag == t,
                    onSelected: (v) => setSS(() => f = f.copyWith(tag: v ? t : '')),
                    selectedColor: AppTheme.skyColor.withOpacity(0.15),
                    checkmarkColor: AppTheme.skyColor,
                  )).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(placesFilterProvider(widget.cityId).notifier).state = f;
                      Navigator.pop(ctx);
                    },
                    child: const Text('Applica filtri'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
