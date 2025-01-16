import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'fuel_station_model.dart';

class FuelStationRepository {
  final FirebaseFirestore _firestore;

  FuelStationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<FuelStation>> getModeratorStation(String stationName) async {
    final snapshot = await _firestore
        .collection('fuel_stations')
        .where('name', isEqualTo: stationName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Station not found');
    }

    return snapshot.docs
        .map((doc) => FuelStation.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>, null))
        .toList();
  }

  Future<List<FuelStation>> getNearestFuelStations(
    Position currentPosition, {
    int limit = 5,
    double radiusInKm = 10,
  }) async {
    // Calculate geo-hash range for nearby stations
    final stationsRef = _firestore.collection('fuel_stations');

    // This is a simplified implementation. In a real-world scenario,
    // you'd use geohashing or a more efficient geospatial query
    QuerySnapshot snapshot =
        await stationsRef.orderBy('location').limit(limit).get();

    return snapshot.docs
        .map((doc) => FuelStation.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>, null))
        .where((station) {
      // Manual distance filtering
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        station.location.latitude,
        station.location.longitude,
      );
      return distance <= (radiusInKm * 1000); // Convert km to meters
    }).toList();
  }

// main function for prod
// import 'package:geoflutterfire2/geoflutterfire2.dart';
  // Future<List<FuelStation>> getNearestFuelStations(
  //   Position currentPosition, {
  //   int limit = 5,
  //   double radiusInKm = 10,
  // }) async {
  //   GeoFirePoint center = geo.point(
  //       latitude: currentPosition.latitude,
  //       longitude: currentPosition.longitude);

  //   // Add limit parameter here
  //   Stream<List<DocumentSnapshot>> stream = geo
  //       .collection(collectionRef: _firestore.collection('fuel_stations'))
  //       .within(
  //           center: center,
  //           radius: radiusInKm,
  //           field: 'location',
  //           strictMode: true)
  //       .take(limit); // Added limit using take()

  //   List<DocumentSnapshot> results = await stream.first;
  //   return results
  //       .map((doc) => FuelStation.fromFirestore(
  //           doc as DocumentSnapshot<Map<String, dynamic>>, null))
  //       .toList();
  // }

  Future<void> updateFuelStationData(
    String stationId,
    Map<String, dynamic> updateData,
    String userId,
  ) async {
    final stationRef = _firestore.collection('fuel_stations').doc(stationId);

    await stationRef.update({
      ...updateData,
      'lastUpdated': FieldValue.serverTimestamp(),
      'updatedBy': userId,
    });
  }

  Stream<FuelStation> getFuelStationStream(String stationId) {
    return _firestore
        .collection('fuel_stations')
        .doc(stationId)
        .snapshots()
        .map((snapshot) => FuelStation.fromFirestore(snapshot, null));
  }
}
