import 'package:uuid/uuid.dart';
import 'rating.dart';

class Place {
  final int? id;
  final String syncId;
  final int cityId;
  final String type; // 'food' | 'visit'
  final String name;
  final String? address;
  final String? category;
  final String? tag;
  final double? lat;
  final double? lng;
  final String? dateVisited;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String? createdBy;

  // Enriched at query time
  final List<Rating> ratings;
  final bool isFavorite;

  const Place({
    this.id,
    required this.syncId,
    required this.cityId,
    required this.type,
    required this.name,
    this.address,
    this.category,
    this.tag,
    this.lat,
    this.lng,
    this.dateVisited,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.createdBy,
    this.ratings = const [],
    this.isFavorite = false,
  });

  factory Place.create({
    required int cityId,
    required String type,
    required String name,
    String? address,
    String? category,
    String? tag,
    double? lat,
    double? lng,
    String? dateVisited,
    String? note,
    String? createdBy,
  }) {
    final now = DateTime.now().toIso8601String();
    return Place(
      syncId: const Uuid().v4(),
      cityId: cityId,
      type: type,
      name: name,
      address: address,
      category: category,
      tag: tag,
      lat: lat,
      lng: lng,
      dateVisited: dateVisited,
      note: note,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
    );
  }

  Place copyWith({
    String? type,
    String? name,
    String? address,
    String? category,
    String? tag,
    double? lat,
    double? lng,
    String? dateVisited,
    String? note,
    bool? isDeleted,
    List<Rating>? ratings,
    bool? isFavorite,
  }) => Place(
    id: id,
    syncId: syncId,
    cityId: cityId,
    type: type ?? this.type,
    name: name ?? this.name,
    address: address ?? this.address,
    category: category ?? this.category,
    tag: tag ?? this.tag,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    dateVisited: dateVisited ?? this.dateVisited,
    note: note ?? this.note,
    createdAt: createdAt,
    updatedAt: DateTime.now().toIso8601String(),
    isDeleted: isDeleted ?? this.isDeleted,
    createdBy: createdBy,
    ratings: ratings ?? this.ratings,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  /// Global average of all users' ratings
  double? get avgScore {
    final avgs = ratings
        .map((r) => r.avg(type))
        .whereType<double>()
        .toList();
    if (avgs.isEmpty) return null;
    return double.parse(
      (avgs.reduce((a, b) => a + b) / avgs.length).toStringAsFixed(2),
    );
  }

  Rating? ratingFor(String user) =>
      ratings.where((r) => r.user == user).firstOrNull;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sync_id': syncId,
    'city_id': cityId,
    'type': type,
    'name': name,
    'address': address,
    'category': category,
    'tag': tag,
    'lat': lat,
    'lng': lng,
    'date_visited': dateVisited,
    'note': note,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'is_deleted': isDeleted ? 1 : 0,
    'created_by': createdBy,
  };

  factory Place.fromMap(Map<String, dynamic> m, {List<Rating> ratings = const [], bool isFavorite = false}) =>
      Place(
        id: m['id'] as int?,
        syncId: m['sync_id'] as String,
        cityId: m['city_id'] as int,
        type: m['type'] as String,
        name: m['name'] as String,
        address: m['address'] as String?,
        category: m['category'] as String?,
        tag: m['tag'] as String?,
        lat: m['lat'] as double?,
        lng: m['lng'] as double?,
        dateVisited: m['date_visited'] as String?,
        note: m['note'] as String?,
        createdAt: m['created_at'] as String,
        updatedAt: m['updated_at'] as String,
        isDeleted: (m['is_deleted'] as int? ?? 0) == 1,
        createdBy: m['created_by'] as String?,
        ratings: ratings,
        isFavorite: isFavorite,
      );
}
