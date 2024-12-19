import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FuelStation extends Equatable {
  final String id;
  final String name;
  final String address;
  final GeoPoint location;
  final int fuelPrice;
  final bool hasFuel;
  final DateTime lastUpdated;
  final String? updatedBy;

  const FuelStation({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.fuelPrice,
    this.hasFuel = false,
    required this.lastUpdated,
    this.updatedBy,
  });

  factory FuelStation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return FuelStation(
      id: snapshot.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      fuelPrice: data['fuelPrices'] ?? 0,
      hasFuel: data['hasFuel'] ?? false,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'location': location,
      'fuelPrices': fuelPrice,
      'hasFuel': hasFuel,
      'lastUpdated': lastUpdated,
      'updatedBy': updatedBy,
    };
  }

  FuelStation copyWith({
    String? name,
    String? address,
    int? fuelPrice,
    bool? hasDiesel,
    bool? hasFuel,
    String? updatedBy,
  }) {
    return FuelStation(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location,
      fuelPrice: fuelPrice ?? this.fuelPrice,
      hasFuel: hasFuel ?? this.hasFuel,
      lastUpdated: DateTime.now(),
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, address, location, fuelPrice, hasFuel, lastUpdated, updatedBy];
}
