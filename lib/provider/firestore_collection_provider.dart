import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/model/collection.dart';

class FirestoreCollectionProvider {
  static FirestoreCollectionProvider helper = FirestoreCollectionProvider._();
  FirestoreCollectionProvider._();

  final CollectionReference collectionsRoot = FirebaseFirestore.instance
      .collection('collections');

  String collectionsDocRef = 'colecoes';

  CollectionReference get _innerCollection =>
      collectionsRoot.doc(collectionsDocRef).collection('collections');

  Future<String> insertCollection(Collection collection) async {
    if (collection.id.isNotEmpty) {
      await _innerCollection.doc(collection.id).set(collection.toMap());
      return collection.id;
    }
    final docRef = await _innerCollection.add(collection.toMap());
    return docRef.id;
  }

  Future<void> setCollection(String id, Collection collection) async {
    await _innerCollection.doc(id).set(collection.toMap());
  }

  Future<List<Collection>> getAllCollections({String? userId}) async {
    Query query = _innerCollection;
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) {
      final data = _normalizeDocData(d.data());
      final historyMap = Map<String, dynamic>.from(data);
      historyMap['id'] = d.id;
      return Collection.fromMap(historyMap);
    }).toList();
  }

  Stream<List<Collection>> collectionsStream({String? userId}) {
    Query query = _innerCollection;
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = _normalizeDocData(d.data());
        final historyMap = Map<String, dynamic>.from(data);
        historyMap['id'] = d.id;
        return Collection.fromMap(historyMap);
      }).toList();
    });
  }

  Future<Collection?> getCollectionById(String id) async {
    final doc = await _innerCollection.doc(id).get();
    if (!doc.exists) return null;
    final data = _normalizeDocData(doc.data()!);
    final historyMap = Map<String, dynamic>.from(data);
    historyMap['id'] = doc.id;
    return Collection.fromMap(historyMap);
  }

  Future<void> updateCollection(String id, Map<String, dynamic> data) async {
    await _innerCollection.doc(id).update(data);
  }

  Future<void> deleteCollection(String id) async {
    await _innerCollection.doc(id).delete();
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
