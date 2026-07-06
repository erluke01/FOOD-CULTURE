import 'package:uuid/uuid.dart';

class City {
  final int? id;
  final String syncId;
  final String name;
  final String? country;
  final double? lat;
  final double? lng;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;

  const City({
    this.id,
    required this.syncId,
    required this.name,
    this.country,
    this.lat,
    this.lng,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory City.create({
    required String name,
    String? country,
    double? lat,
    double? lng,
  }) {
    final now = DateTime.now().toIso8601String();
    return City(
      syncId: const Uuid().v4(),
      name: name,
      country: country,
      lat: lat,
      lng: lng,
      createdAt: now,
      updatedAt: now,
    );
  }

  City copyWith({
    int? id,
    String? name,
    String? country,
    double? lat,
    double? lng,
    bool? isDeleted,
  }) {
    return City(
      id: id ?? this.id,
      syncId: syncId,
      name: name ?? this.name,
      country: country ?? this.country,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sync_id': syncId,
    'name': name,
    'country': country,
    'lat': lat,
    'lng': lng,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'is_deleted': isDeleted ? 1 : 0,
  };

  factory City.fromMap(Map<String, dynamic> m) => City(
    id: m['id'] as int?,
    syncId: m['sync_id'] as String,
    name: m['name'] as String,
    country: m['country'] as String?,
    lat: m['lat'] as double?,
    lng: m['lng'] as double?,
    createdAt: m['created_at'] as String,
    updatedAt: m['updated_at'] as String,
    isDeleted: (m['is_deleted'] as int? ?? 0) == 1,
  );
}
