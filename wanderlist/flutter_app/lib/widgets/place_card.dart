import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/place.dart';
import '../providers/providers.dart';
import '../theme.dart';
import 'star_rating.dart';

class PlaceCard extends ConsumerStatefulWidget {
  final Place place;
  final VoidCallback? onFavToggle;

  const PlaceCard({super.key, required this.place, this.onFavToggle});

  @override
  ConsumerState<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends ConsumerState<PlaceCard> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.place.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final user = ref.watch(authProvider).valueOrNull;
    final isFood = p.type == 'food';
    final lRating = p.ratingFor('luchino');
    final aRating = p.ratingFor('alix');

    return Card(
      child: InkWell(
        onTap: () => context.push('/place/${p.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Color stripe
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isFood ? AppTheme.terra : AppTheme.sage,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          Wrap(spacing: 5, children: [
                            if (p.category != null)
                              _Tag(p.category!),
                            if (p.tag != null)
                              _Tag(p.tag!, color: AppTheme.skyColor.withOpacity(0.12), textColor: AppTheme.skyColor),
                          ]),
                          const SizedBox(height: 5),
                          // Name
                          Text(p.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.inkColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Address
                          if (p.address != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(p.address!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.inkLight),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Right: fav + score
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      if (user != null)
                        GestureDetector(
                          onTap: _toggleFav,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              _isFav ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(_isFav),
                              size: 20,
                              color: _isFav ? AppTheme.terra : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      if (p.avgScore != null) ...[
                        const SizedBox(height: 4),
                        Text(p.avgScore!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.terra)),
                        const Text('/ 5', style: TextStyle(fontSize: 10, color: AppTheme.inkLight)),
                      ],
                    ]),
                  ]),

                  // Ratings bar
                  if (lRating != null || aRating != null) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (lRating?.avg(p.type) != null) ...[
                        const Text('🧑 ', style: TextStyle(fontSize: 12)),
                        StarDisplay(score: lRating!.avg(p.type)!),
                        const SizedBox(width: 12),
                      ],
                      if (aRating?.avg(p.type) != null) ...[
                        const Text('👩 ', style: TextStyle(fontSize: 12)),
                        StarDisplay(score: aRating!.avg(p.type)!),
                      ],
                    ]),
                  ],

                  // Date
                  if (p.dateVisited != null) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(p.dateVisited!, style: const TextStyle(fontSize: 11, color: AppTheme.inkLight)),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFav() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(repositoryProvider);
    setState(() => _isFav = !_isFav);
    if (_isFav) {
      await repo.addFavorite(user.username, widget.place.id!);
    } else {
      await repo.removeFavorite(user.username, widget.place.id!);
    }
    ref.invalidate(favoritesProvider);
    widget.onFavToggle?.call();
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  const _Tag(this.label, {this.color, this.textColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color ?? AppTheme.paperDark,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor ?? AppTheme.inkLight)),
  );
}
