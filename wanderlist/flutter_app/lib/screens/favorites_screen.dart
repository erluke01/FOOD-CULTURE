import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/place_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final favsAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei preferiti'),
        actions: [
          if (user == null)
            TextButton(onPressed: () => context.push('/login'), child: const Text('Accedi')),
        ],
      ),
      body: user == null
          ? _NotLoggedIn()
          : favsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Errore: $e')),
              data: (places) {
                if (places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Nessun preferito ancora', style: TextStyle(fontSize: 16, color: AppTheme.inkLight)),
                        const SizedBox(height: 8),
                        const Text('Tocca il cuore su un posto per aggiungerlo qui.',
                          style: TextStyle(fontSize: 13, color: AppTheme.inkLight), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(favoritesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: places.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => PlaceCard(
                      place: places[i],
                      onFavToggle: () => ref.invalidate(favoritesProvider),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Accedi per vedere i tuoi preferiti', style: TextStyle(fontSize: 16, color: AppTheme.inkLight)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Accedi'),
          ),
        ],
      ),
    );
  }
}
