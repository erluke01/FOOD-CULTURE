import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/city.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/sync_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.inkColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wanderlist',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text('Il nostro diario di viaggio',
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1C1917), Color(0xFF2D1A0E)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SyncButton(),
                        if (user == null)
                          TextButton.icon(
                            onPressed: () => context.push('/login'),
                            icon: const Icon(Icons.login, size: 16, color: Colors.white70),
                            label: const Text('Accedi', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Search bar ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cerca città…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); },
                        )
                      : null,
                  isDense: true,
                ),
              ),
            ),
          ),

          // ── Cities grid ────────────────────────────────────────────
          citiesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Errore: $e')),
            ),
            data: (cities) {
              final filtered = _query.isEmpty
                  ? cities
                  : cities.where((c) =>
                      c.name.toLowerCase().contains(_query) ||
                      (c.country ?? '').toLowerCase().contains(_query)).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(onAdd: user != null ? _showAddCity : null),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _CityCard(city: filtered[i]),
                    childCount: filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: ref.watch(authProvider).valueOrNull != null
          ? FloatingActionButton.extended(
              onPressed: _showAddCity,
              icon: const Icon(Icons.add),
              label: const Text('Nuova città'),
              backgroundColor: AppTheme.terra,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  void _showAddCity() {
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuova città', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome città *'), textCapitalization: TextCapitalization.words),
            const SizedBox(height: 12),
            TextField(controller: countryCtrl, decoration: const InputDecoration(labelText: 'Paese'), textCapitalization: TextCapitalization.words),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(ctx);
                  await ref.read(citiesProvider.notifier).add(
                    City.create(name: name, country: countryCtrl.text.trim().isEmpty ? null : countryCtrl.text.trim()),
                  );
                },
                child: const Text('Aggiungi'),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CityCard extends ConsumerWidget {
  final City city;
  const _CityCard({required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Card(
      child: InkWell(
        onTap: () => context.push('/city/${city.id}'),
        onLongPress: user != null ? () => _confirmDelete(context, ref) : null,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Color bar
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.terra, AppTheme.terraLight]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppTheme.terra),
                        const Spacer(),
                        if (user != null)
                          Icon(Icons.more_horiz, size: 16, color: Colors.grey.shade300),
                      ],
                    ),
                    const Spacer(),
                    Text(city.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.inkColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (city.country != null)
                      Text(city.country!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.inkLight),
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina città'),
        content: Text('Vuoi eliminare "${city.name}" e tutti i suoi posti?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(citiesProvider.notifier).delete(city.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const _EmptyState({this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Nessuna città nel diario', style: TextStyle(fontSize: 16, color: AppTheme.inkLight)),
          const SizedBox(height: 8),
          const Text('Tieni premuto su una carta per eliminarla', style: TextStyle(fontSize: 12, color: AppTheme.inkLight)),
          if (onAdd != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi la prima città'),
            ),
          ],
        ],
      ),
    );
  }
}
