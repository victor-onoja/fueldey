import 'package:cloud_firestore/cloud_firestore.dart';

class ModeratorValidator {
  final FirebaseFirestore _firestore;

  ModeratorValidator({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> validateModerator(
      String stationName, String moderatorName) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('fuel_stations')
          .where('name', isEqualTo: stationName)
          .where('moderators', arrayContains: moderatorName)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error validating moderator: $e');
      return false;
    }
  }
}
