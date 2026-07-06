import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../models/rating.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/star_rating.dart';
import '../widgets/places_map.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final int placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeDetailProvider(placeId));
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (user != null) ...[
            Consumer(builder: (ctx, ref, _) {
              final place = ref.watch(placeDetailProvider(placeId)).valueOrNull;
              if (place == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  place.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: place.isFavorite ? AppTheme.terra : null,
                ),
                onPressed: () => _toggleFav(ref, place),
              );
            }),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await context.push('/place-form', extra: {'placeId': placeId});
                ref.invalidate(placeDetailProvider(placeId));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ],
      ),
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (place) {
          if (place == null) return const Center(child: Text('Posto non trovato'));
          return _PlaceDetail(place: place, currentUser: user?.username);
        },
      ),
    );
  }

  void _toggleFav(WidgetRef ref, Place place) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(repositoryProvider);
    if (place.isFavorite) {
      await repo.removeFavorite(user.username, place.id!);
    } else {
      await repo.addFavorite(user.username, place.id!);
    }
    ref.invalidate(placeDetailProvider(placeId));
    ref.invalidate(favoritesProvider);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina posto'),
        content: const Text('Sei sicuro di voler eliminare questo posto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(repositoryProvider).deletePlace(placeId);
              if (context.mounted) context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}

class _PlaceDetail extends ConsumerStatefulWidget {
  final Place place;
  final String? currentUser;
  const _PlaceDetail({required this.place, this.currentUser});

  @override
  ConsumerState<_PlaceDetail> createState() => _PlaceDetailState();
}

class _PlaceDetailState extends ConsumerState<_PlaceDetail> {
  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final isFood = p.type == 'food';
    final lRating = p.ratingFor('luchino');
    final aRating = p.ratingFor('alix');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main card ──────────────────────────────────────────────
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color stripe
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFood
                          ? [AppTheme.terra, AppTheme.terraLight]
                          : [AppTheme.sage, AppTheme.sageLight],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Wrap(spacing: 6, children: [
                        if (p.category != null) _Chip(p.category!),
                        if (p.tag != null) _Chip(p.tag!, color: AppTheme.skyColor.withOpacity(0.12), textColor: AppTheme.skyColor),
                      ]),
                      const SizedBox(height: 10),
                      // Name + score row
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          child: Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                        ),
                        if (p.avgScore != null) ...[
                          const SizedBox(width: 12),
                          Column(children: [
                            Text(p.avgScore!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.terra)),
                            const Text('/ 5', style: TextStyle(fontSize: 11, color: AppTheme.inkLight)),
                          ]),
                        ],
                      ]),
                      // Address
                      if (p.address != null) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.inkLight),
                          const SizedBox(width: 4),
                          Expanded(child: Text(p.address!, style: const TextStyle(fontSize: 13, color: AppTheme.inkLight))),
                        ]),
                      ],
                      // Date
                      if (p.dateVisited != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.inkLight),
                          const SizedBox(width: 4),
                          Text(p.dateVisited!, style: const TextStyle(fontSize: 12, color: AppTheme.inkLight)),
                        ]),
                      ],
                      // Note
                      if (p.note != null && p.note!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('"${p.note!}"',
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppTheme.inkLight)),
                      ],
                      // Maps button
                      if (p.lat != null && p.lng != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _openMaps(p),
                          icon: const Icon(Icons.navigation_outlined, size: 16),
                          label: const Text('Indicazioni'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Ratings of others ──────────────────────────────────────
          if (lRating != null || aRating != null)
            Row(children: [
              if (lRating != null) Expanded(child: _RatingCard(rating: lRating, placeType: p.type, label: '🧑 Luchino')),
              if (lRating != null && aRating != null) const SizedBox(width: 10),
              if (aRating != null) Expanded(child: _RatingCard(rating: aRating, placeType: p.type, label: '👩 Alix')),
            ]),

          // ── My rating input ────────────────────────────────────────
          if (widget.currentUser != null) ...[
            const SizedBox(height: 16),
            _MyRatingInput(place: p, user: widget.currentUser!),
          ],

          // ── Mini map ───────────────────────────────────────────────
          if (p.lat != null && p.lng != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(height: 200, child: PlacesMap(places: [p], zoom: 15)),
            ),
          ],
        ],
      ),
    );
  }

  void _openMaps(Place p) {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

class _RatingCard extends StatelessWidget {
  final Rating rating;
  final String placeType;
  final String label;
  const _RatingCard({required this.rating, required this.placeType, required this.label});

  @override
  Widget build(BuildContext context) {
    final isFood = placeType == 'food';
    final fields = isFood
        ? [('Qualità', rating.quality), ('Quantità', rating.quantity), ('Prezzo', rating.price), ('Servizio', rating.service), ('Pulizia', rating.cleanliness)]
        : [('Bellezza', rating.beauty), ('Costo', rating.cost)];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...fields.where((f) => f.$2 != null).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Expanded(child: Text(f.$1, style: const TextStyle(fontSize: 12, color: AppTheme.inkLight))),
                StarDisplay(score: f.$2!),
              ]),
            )),
            const Divider(height: 12),
            Row(children: [
              const Expanded(child: Text('Media', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              if (rating.avg(placeType) != null)
                StarDisplay(score: rating.avg(placeType)!, large: true),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MyRatingInput extends ConsumerStatefulWidget {
  final Place place;
  final String user;
  const _MyRatingInput({required this.place, required this.user});

  @override
  ConsumerState<_MyRatingInput> createState() => _MyRatingInputState();
}

class _MyRatingInputState extends ConsumerState<_MyRatingInput> {
  late Map<String, double?> _values;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final r = widget.place.ratingFor(widget.user);
    _values = {
      'quality': r?.quality, 'quantity': r?.quantity, 'price': r?.price,
      'service': r?.service, 'cleanliness': r?.cleanliness,
      'beauty': r?.beauty, 'cost': r?.cost,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isFood = widget.place.type == 'food';
    final label = widget.user == 'luchino' ? '🧑 Il tuo voto (Luchino)' : '👩 Il tuo voto (Alix)';
    final fields = isFood
        ? [('Qualità', 'quality'), ('Quantità', 'quantity'), ('Prezzo', 'price'), ('Servizio', 'service'), ('Pulizia', 'cleanliness')]
        : [('Bellezza', 'beauty'), ('Costo', 'cost')];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: Text(f.$1, style: const TextStyle(fontSize: 13))),
                StarInput(
                  value: _values[f.$2],
                  onChange: (v) => setState(() => _values[f.$2] = v),
                ),
              ]),
            )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_saved ? '✓ Salvato' : 'Salva voto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final existing = widget.place.ratingFor(widget.user);
      final rating = existing != null
          ? existing.copyWith(
              quality: _values['quality'], quantity: _values['quantity'],
              price: _values['price'], service: _values['service'],
              cleanliness: _values['cleanliness'], beauty: _values['beauty'],
              cost: _values['cost'],
            )
          : Rating.create(
              placeId: widget.place.id!,
              user: widget.user,
              quality: _values['quality'], quantity: _values['quantity'],
              price: _values['price'], service: _values['service'],
              cleanliness: _values['cleanliness'], beauty: _values['beauty'],
              cost: _values['cost'],
            );

      await ref.read(repositoryProvider).upsertRating(rating, currentUser: widget.user);
      ref.invalidate(placeDetailProvider(widget.place.id!));
      setState(() { _saved = true; _saving = false; });
      Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _saved = false); });
    } catch (_) {
      setState(() => _saving = false);
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  const _Chip(this.label, {this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? AppTheme.paperDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor ?? AppTheme.inkLight)),
    );
  }
}
