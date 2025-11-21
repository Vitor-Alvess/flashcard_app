import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/model/study_history.dart';

class FirestoreHistoryProvider {
  static FirestoreHistoryProvider helper = FirestoreHistoryProvider._();
  FirestoreHistoryProvider._();

  final CollectionReference historyRoot = FirebaseFirestore.instance
      .collection('users-collections');

  CollectionReference _getHistoryCollection(String userEmail) =>
      historyRoot.doc(userEmail).collection('history');

  Future<String> insertHistory(StudyHistory history, String userEmail) async {
    final map = history.toMap();
    map['completedAt'] = Timestamp.fromDate(history.completedAt);
    final docRef = await _getHistoryCollection(userEmail).add(map);
    return docRef.id;
  }

  Future<List<StudyHistory>> getHistoryByUserId(String userEmail) async {
    final querySnapshot = await _getHistoryCollection(userEmail).get();
    final histories = querySnapshot.docs.map((d) {
      final data = _normalizeDocData(d.data());
      final historyMap = Map<String, dynamic>.from(data);
      historyMap['id'] = d.id;
      return StudyHistory.fromMap(historyMap);
    }).toList();

    // Ordenar por completedAt em ordem decrescente
    histories.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return histories;
  }

  Stream<List<StudyHistory>> historyStream(String userEmail) {
    return _getHistoryCollection(userEmail)
        .snapshots()
        .map((snap) {
          final histories = snap.docs.map((d) {
            final data = _normalizeDocData(d.data());
            final historyMap = Map<String, dynamic>.from(data);
            historyMap['id'] = d.id;
            return StudyHistory.fromMap(historyMap);
          }).toList();

          // Ordenar por completedAt em ordem decrescente
          histories.sort((a, b) => b.completedAt.compareTo(a.completedAt));

          return histories;
        });
  }

  Future<void> deleteHistory(String id, String userEmail) async {
    await _getHistoryCollection(userEmail).doc(id).delete();
  }

  Map<String, dynamic> _normalizeDocData(Object? rawData) {
    if (rawData == null) return {};

    final map = Map<String, dynamic>.from(rawData as Map);

    final completedAt = map['completedAt'];
    if (completedAt is Timestamp) {
      map['completedAt'] = completedAt.toDate().toIso8601String();
    }

    return map;
  }
}
