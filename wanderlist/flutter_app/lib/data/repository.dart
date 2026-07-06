import 'package:sqflite/sqflite.dart';
import '../models/city.dart';
import '../models/place.dart';
import '../models/rating.dart';
import 'database.dart';

class Repository {
  Future<Database> get _db => AppDatabase.instance;

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<Place> _enrichPlace(Database db, Map<String, dynamic> row, String? currentUser) async {
    final placeId = row['id'] as int;
    final ratings = await db.query('ratings', where: 'place_id = ?', whereArgs: [placeId]);
    final type = row['type'] as String;

    bool isFav = false;
    if (currentUser != null) {
      final favs = await db.query('favorites',
        where: 'user = ? AND place_id = ?',
        whereArgs: [currentUser, placeId],
        limit: 1,
      );
      isFav = favs.isNotEmpty;
    }

    return Place.fromMap(
      row,
      ratings: ratings.map(Rating.fromMap).toList(),
      isFavorite: isFav,
    );
  }

  // ── Cities ────────────────────────────────────────────────────────────────

  Future<List<City>> getCities() async {
    final db = await _db;
    final rows = await db.query('cities', where: 'is_deleted = 0', orderBy: 'name ASC');
    return rows.map(City.fromMap).toList();
  }

  Future<City?> getCity(int id) async {
    final db = await _db;
    final rows = await db.query('cities', where: 'id = ? AND is_deleted = 0', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : City.fromMap(rows.first);
  }

  Future<City> insertCity(City city) async {
    final db = await _db;
    final id = await db.insert('cities', city.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return city.copyWith(id: id);
  }

  Future<void> updateCity(City city) async {
    final db = await _db;
    await db.update('cities', city.toMap(), where: 'id = ?', whereArgs: [city.id]);
  }

  Future<void> deleteCity(int id) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    // Soft delete city
    await db.execute('UPDATE cities SET is_deleted = 1, updated_at = ? WHERE id = ?', [now, id]);
    // Soft delete places in city
    await db.execute('UPDATE places SET is_deleted = 1, updated_at = ? WHERE city_id = ?', [now, id]);
  }

  // ── Places ────────────────────────────────────────────────────────────────

  Future<List<Place>> getPlaces({
    required int cityId,
    String? type,
    String? category,
    String? tag,
    String? currentUser,
  }) async {
    final db = await _db;
    final where = StringBuffer('is_deleted = 0 AND city_id = ?');
    final args = <dynamic>[cityId];

    if (type != null && type.isNotEmpty) { where.write(' AND type = ?'); args.add(type); }
    if (category != null && category.isNotEmpty) { where.write(' AND category = ?'); args.add(category); }
    if (tag != null && tag.isNotEmpty) { where.write(' AND tag = ?'); args.add(tag); }

    final rows = await db.query('places', where: where.toString(), whereArgs: args);
    final places = await Future.wait(rows.map((r) => _enrichPlace(db, r, currentUser)));

    places.sort((a, b) {
      final ca = (a.category ?? 'zzz').toLowerCase();
      final cb = (b.category ?? 'zzz').toLowerCase();
      final cmp = ca.compareTo(cb);
      if (cmp != 0) return cmp;
      return (b.avgScore ?? -1).compareTo(a.avgScore ?? -1);
    });

    return places;
  }

  Future<Place?> getPlace(int id, {String? currentUser}) async {
    final db = await _db;
    final rows = await db.query('places', where: 'id = ? AND is_deleted = 0', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _enrichPlace(db, rows.first, currentUser);
  }

  Future<Place> insertPlace(Place place) async {
    final db = await _db;
    final id = await db.insert('places', place.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return Place.fromMap({...place.toMap(), 'id': id});
  }

  Future<Place> updatePlace(Place place) async {
    final db = await _db;
    await db.update('places', place.toMap(), where: 'id = ?', whereArgs: [place.id]);
    return place;
  }

  Future<void> deletePlace(int id) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.execute('UPDATE places SET is_deleted = 1, updated_at = ? WHERE id = ?', [now, id]);
  }

  Future<List<String>> getCategories({int? cityId, String? type}) async {
    final db = await _db;
    final where = StringBuffer("is_deleted = 0 AND category IS NOT NULL AND category != ''");
    final args = <dynamic>[];
    if (cityId != null) { where.write(' AND city_id = ?'); args.add(cityId); }
    if (type != null) { where.write(' AND type = ?'); args.add(type); }
    final rows = await db.query('places',
      columns: ['DISTINCT category'],
      where: where.toString(),
      whereArgs: args,
      orderBy: 'category ASC',
    );
    return rows.map((r) => r['category'] as String).toList();
  }

  // ── Ratings ───────────────────────────────────────────────────────────────

  Future<Place> upsertRating(Rating rating, {String? currentUser}) async {
    final db = await _db;
    final existing = await db.query('ratings',
      where: 'place_id = ? AND user = ?',
      whereArgs: [rating.placeId, rating.user],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('ratings', rating.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update('ratings', rating.toMap(),
        where: 'place_id = ? AND user = ?',
        whereArgs: [rating.placeId, rating.user],
      );
    }

    final place = await getPlace(rating.placeId, currentUser: currentUser);
    return place!;
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  Future<List<Place>> getFavorites(String user) async {
    final db = await _db;
    final favRows = await db.query('favorites', where: 'user = ?', whereArgs: [user]);
    final placeIds = favRows.map((r) => r['place_id'] as int).toList();
    if (placeIds.isEmpty) return [];

    final places = await Future.wait(
      placeIds.map((id) => getPlace(id, currentUser: user)),
    );
    return places.whereType<Place>().toList();
  }

  Future<void> addFavorite(String user, int placeId) async {
    final db = await _db;
    await db.insert('favorites', {
      'user': user,
      'place_id': placeId,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFavorite(String user, int placeId) async {
    final db = await _db;
    await db.delete('favorites', where: 'user = ? AND place_id = ?', whereArgs: [user, placeId]);
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  /// Export all local data for sync
  Future<Map<String, dynamic>> exportForSync() async {
    final db = await _db;
    return {
      'cities': await db.query('cities'),
      'places': await db.query('places'),
      'ratings': await db.query('ratings'),
      'favorites': await db.query('favorites'),
    };
  }

  /// Merge incoming data from server (last-write-wins on updated_at)
  Future<void> mergeFromSync(Map<String, dynamic> data) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final city in (data['cities'] as List? ?? [])) {
        final m = Map<String, dynamic>.from(city as Map);
        await txn.insert('cities', m, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final place in (data['places'] as List? ?? [])) {
        final m = Map<String, dynamic>.from(place as Map);
        await txn.insert('places', m, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final rating in (data['ratings'] as List? ?? [])) {
        final m = Map<String, dynamic>.from(rating as Map);
        await txn.insert('ratings', m, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      // favorites: simple insert/ignore
      for (final fav in (data['favorites'] as List? ?? [])) {
        final m = Map<String, dynamic>.from(fav as Map);
        await txn.insert('favorites', m, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }
}
