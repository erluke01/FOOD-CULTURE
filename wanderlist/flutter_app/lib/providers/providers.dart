import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository.dart';
import '../models/city.dart';
import '../models/place.dart';
import '../models/rating.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

// ── Core services ─────────────────────────────────────────────────────────

final repositoryProvider = Provider<Repository>((ref) => Repository());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final syncServiceProvider = Provider<SyncService>((ref) => SyncService(
  ref.read(repositoryProvider),
  ref.read(authServiceProvider),
));

// ── Auth state ────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    return ref.read(authServiceProvider).restoreSession();
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).login(username, password),
    );
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);

// ── Cities ────────────────────────────────────────────────────────────────

class CitiesNotifier extends AsyncNotifier<List<City>> {
  @override
  Future<List<City>> build() => ref.read(repositoryProvider).getCities();

  Future<void> add(City city) async {
    final saved = await ref.read(repositoryProvider).insertCity(city);
    state = AsyncData([...state.valueOrNull ?? [], saved]
      ..sort((a, b) => a.name.compareTo(b.name)));
  }

  Future<void> delete(int id) async {
    await ref.read(repositoryProvider).deleteCity(id);
    state = AsyncData((state.valueOrNull ?? []).where((c) => c.id != id).toList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(repositoryProvider).getCities());
  }
}

final citiesProvider = AsyncNotifierProvider<CitiesNotifier, List<City>>(CitiesNotifier.new);

// ── Places ────────────────────────────────────────────────────────────────

class PlacesFilter {
  final int cityId;
  final String type;
  final String category;
  final String tag;

  const PlacesFilter({
    required this.cityId,
    this.type = '',
    this.category = '',
    this.tag = '',
  });

  PlacesFilter copyWith({String? type, String? category, String? tag}) => PlacesFilter(
    cityId: cityId,
    type: type ?? this.type,
    category: category ?? this.category,
    tag: tag ?? this.tag,
  );
}

final placesFilterProvider = StateProvider.family<PlacesFilter, int>(
  (ref, cityId) => PlacesFilter(cityId: cityId),
);

final placesProvider = FutureProvider.family<List<Place>, PlacesFilter>((ref, filter) async {
  final user = ref.watch(authProvider).valueOrNull;
  final repo = ref.read(repositoryProvider);
  return repo.getPlaces(
    cityId: filter.cityId,
    type: filter.type.isEmpty ? null : filter.type,
    category: filter.category.isEmpty ? null : filter.category,
    tag: filter.tag.isEmpty ? null : filter.tag,
    currentUser: user?.username,
  );
});

final categoriesProvider = FutureProvider.family<List<String>, int>((ref, cityId) async {
  return ref.read(repositoryProvider).getCategories(cityId: cityId);
});

final placeDetailProvider = FutureProvider.family<Place?, int>((ref, placeId) async {
  final user = ref.watch(authProvider).valueOrNull;
  return ref.read(repositoryProvider).getPlace(placeId, currentUser: user?.username);
});

final favoritesProvider = FutureProvider<List<Place>>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return [];
  return ref.read(repositoryProvider).getFavorites(user.username);
});

// ── Sync ──────────────────────────────────────────────────────────────────

class SyncNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;

  Future<String?> sync() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return 'Devi essere loggato per sincronizzare';

    state = SyncStatus.syncing;
    final result = await ref.read(syncServiceProvider).sync(user);

    if (result.status == SyncStatus.success) {
      state = SyncStatus.success;
      // Refresh all data
      ref.invalidate(citiesProvider);
      ref.invalidate(favoritesProvider);
      return null;
    } else {
      state = SyncStatus.error;
      return result.message;
    }
  }
}

final syncStatusProvider = NotifierProvider<SyncNotifier, SyncStatus>(SyncNotifier.new);
