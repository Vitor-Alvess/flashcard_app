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
    if (collection.id.isNotEmpty) {
      await collectionsRoot
          .doc(userEmail)
          .collection("collections")
          .doc(collection.id)
          .set(collection.toMap());
      return collection.id;
    }
    final docRef = await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .add(collection.toMap());
    return docRef.id;
  }

  Future<void> setCollection(String id, Collection collection, String userEmail) async {
    await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .doc(id)
        .set(collection.toMap());
  }

  Future<List<Collection>> getAllCollections(String userEmail) async {
    final querySnapshot = await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .get();
    return querySnapshot.docs.map((d) {
      final data = _normalizeDocData(d.data());
      final historyMap = Map<String, dynamic>.from(data);
      historyMap['id'] = d.id;
      return Collection.fromMap(historyMap);
    }).toList();
  }

  Stream<List<Collection>> collectionsStream({String? userId}) {
    if (userId != null && userId.isNotEmpty) {
      return collectionsRoot
          .doc(userId)
          .collection('collections')
          .snapshots()
          .map((snap) {
            return snap.docs.map((d) {
              final data = _normalizeDocData(d.data());
              final historyMap = Map<String, dynamic>.from(data);
              historyMap['id'] = d.id;
              return Collection.fromMap(historyMap);
            }).toList();
          });
    }
    return Stream.value(<Collection>[]);
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

  Future<Collection?> getCollectionById(String id, String userEmail) async {
    final doc = await collectionsRoot
        .doc(userEmail)
        .collection("collections")
        .doc(id)
        .get();
    if (!doc.exists) return null;
    final data = _normalizeDocData(doc.data()!);
    final historyMap = Map<String, dynamic>.from(data);
    historyMap['id'] = doc.id;
    return Collection.fromMap(historyMap);
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
