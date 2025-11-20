import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/model/collection_result.dart';

class FirestoreCollectionResultProvider {
  static FirestoreCollectionResultProvider helper =
      FirestoreCollectionResultProvider._();

  final CollectionReference resultsCollection = FirebaseFirestore.instance
      .collection("results");

  FirestoreCollectionResultProvider._();

  dynamic insertResult(CollectionResult result, String uid) {
    resultsCollection.doc(uid).collection("history").add(result.toMap());
  }

  Future<List<CollectionResult>> getUserHistory(String userEmail) async {
    final query = await resultsCollection
        .doc(userEmail)
        .collection("history")
        .get();

    return query.docs.map((d) {
      final data = _normalizeDocData(d.data());
      return CollectionResult.fromMap(data);
    }).toList();
  }

  Map<String, dynamic> _normalizeDocData(Object? rawData) {
    if (rawData == null) return {};

    final map = Map<String, dynamic>.from(rawData as Map);

    final created = map['resolvedAt'];
    if (created is Timestamp) {
      map['resolvedAt'] = created.toDate().toIso8601String();
    }
    return map;
  }
}
