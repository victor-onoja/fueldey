import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FuelStation extends Equatable {
  final String id;
  final String name;
  final String address;
  final GeoPoint location;
  final Map<String, dynamic> fuelPrices;
  final bool hasDiesel;
  final bool hasFuel;
  final DateTime lastUpdated;
  final String? updatedBy;

  const FuelStation({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.fuelPrices,
    this.hasDiesel = false,
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
      fuelPrices: data['fuelPrices'] ?? {},
      hasDiesel: data['hasDiesel'] ?? false,
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
      'fuelPrices': fuelPrices,
      'hasDiesel': hasDiesel,
      'hasFuel': hasFuel,
      'lastUpdated': lastUpdated,
      'updatedBy': updatedBy,
    };
  }

  FuelStation copyWith({
    String? name,
    String? address,
    Map<String, dynamic>? fuelPrices,
    bool? hasDiesel,
    bool? hasFuel,
    String? updatedBy,
  }) {
    return FuelStation(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location,
      fuelPrices: fuelPrices ?? this.fuelPrices,
      hasDiesel: hasDiesel ?? this.hasDiesel,
      hasFuel: hasFuel ?? this.hasFuel,
      lastUpdated: DateTime.now(),
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        location,
        fuelPrices,
        hasDiesel,
        hasFuel,
        lastUpdated,
        updatedBy
      ];
}
