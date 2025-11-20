import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/model/collection.dart';

class FirestoreCollectionProvider {
  static FirestoreCollectionProvider helper = FirestoreCollectionProvider._();
  FirestoreCollectionProvider._();

  final CollectionReference collectionsRoot = FirebaseFirestore.instance
      .collection('users-collections');

  Future<String> insertCollection(
    Collection collection,
    String userEmail,
  ) async {
    final docRef = await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .add(collection.toMap());
    return docRef.id;
  }

  Future<List<Collection>> getAllCollections(String userEmail) async {
    final querySnapshot = await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .get();
    return querySnapshot.docs.map((d) {
      final data = _normalizeDocData(d.data());
      return Collection.fromMap(data);
    }).toList();
  }

  Stream<List<Collection>> collectionsStream() {
    return collectionsRoot.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = _normalizeDocData(d.data());
        return Collection.fromMap(data);
      }).toList();
    });
  }

  /// Stream the collections for a specific user (by email or id used as doc)
  Stream<List<Collection>> collectionsStreamForUser(String userEmail) {
    return collectionsRoot
        .doc(userEmail)
        .collection('collections')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = _normalizeDocData(d.data());
            return Collection.fromMap(data..['id'] = d.id);
          }).toList(),
        );
  }

  Future<void> updateCollection(
    String id,
    Map<String, dynamic> data,
    String userEmail,
  ) async {
    await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .doc(id)
        .update(data);
  }

  Future<void> deleteCollection(
    String id,
    Map<String, dynamic> data,
    String userEmail,
  ) async {
    await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .doc(id)
        .delete();
  }

  Map<String, dynamic> _normalizeDocData(Object? rawData) {
    if (rawData == null) return {};

    final map = Map<String, dynamic>.from(rawData as Map);

    final created = map['createdAt'];
    if (created is Timestamp) {
      map['createdAt'] = created.toDate().toIso8601String();
    }

    final flashcards = map['flashcards'];
    if (flashcards is Iterable && flashcards.isNotEmpty) {
      map['flashcards'] = flashcards.map((fc) {
        if (fc is Map<String, dynamic>) return fc;
        if (fc is Map) return Map<String, dynamic>.from(fc);
        return <String, dynamic>{};
      }).toList();
    }

    return map;
  }
}
