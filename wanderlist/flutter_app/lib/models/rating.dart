import 'package:uuid/uuid.dart';

class Rating {
  final int? id;
  final String syncId;
  final int placeId;
  final String user;
  final double? quality;
  final double? quantity;
  final double? price;
  final double? service;
  final double? cleanliness;
  final double? beauty;
  final double? cost;
  final String updatedAt;

  const Rating({
    this.id,
    required this.syncId,
    required this.placeId,
    required this.user,
    this.quality,
    this.quantity,
    this.price,
    this.service,
    this.cleanliness,
    this.beauty,
    this.cost,
    required this.updatedAt,
  });

  factory Rating.create({
    required int placeId,
    required String user,
    double? quality,
    double? quantity,
    double? price,
    double? service,
    double? cleanliness,
    double? beauty,
    double? cost,
  }) => Rating(
    syncId: const Uuid().v4(),
    placeId: placeId,
    user: user,
    quality: quality,
    quantity: quantity,
    price: price,
    service: service,
    cleanliness: cleanliness,
    beauty: beauty,
    cost: cost,
    updatedAt: DateTime.now().toIso8601String(),
  );

  Rating copyWith({
    double? quality,
    double? quantity,
    double? price,
    double? service,
    double? cleanliness,
    double? beauty,
    double? cost,
  }) => Rating(
    id: id,
    syncId: syncId,
    placeId: placeId,
    user: user,
    quality: quality ?? this.quality,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    service: service ?? this.service,
    cleanliness: cleanliness ?? this.cleanliness,
    beauty: beauty ?? this.beauty,
    cost: cost ?? this.cost,
    updatedAt: DateTime.now().toIso8601String(),
  );

  // Average score per type
  double? avg(String placeType) {
    final vals = placeType == 'food'
        ? [quality, quantity, price, service, cleanliness]
        : [beauty, cost];
    final nonNull = vals.whereType<double>().toList();
    if (nonNull.isEmpty) return null;
    return nonNull.reduce((a, b) => a + b) / nonNull.length;
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sync_id': syncId,
    'place_id': placeId,
    'user': user,
    'quality': quality,
    'quantity': quantity,
    'price': price,
    'service': service,
    'cleanliness': cleanliness,
    'beauty': beauty,
    'cost': cost,
    'updated_at': updatedAt,
  };

  factory Rating.fromMap(Map<String, dynamic> m) => Rating(
    id: m['id'] as int?,
    syncId: m['sync_id'] as String,
    placeId: m['place_id'] as int,
    user: m['user'] as String,
    quality: m['quality'] as double?,
    quantity: m['quantity'] as double?,
    price: m['price'] as double?,
    service: m['service'] as double?,
    cleanliness: m['cleanliness'] as double?,
    beauty: m['beauty'] as double?,
    cost: m['cost'] as double?,
    updatedAt: m['updated_at'] as String,
  );
}
