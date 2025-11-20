import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/model/study_history.dart';

class FirestoreHistoryProvider {
  static FirestoreHistoryProvider helper = FirestoreHistoryProvider._();
  FirestoreHistoryProvider._();

  final CollectionReference historyRoot = FirebaseFirestore.instance.collection(
    'study_history',
  );

  String historyDocRef = 'histories';

  CollectionReference get _innerCollection =>
      historyRoot.doc(historyDocRef).collection('histories');

  Future<String> insertHistory(StudyHistory history) async {
    final map = history.toMap();
    map['completedAt'] = Timestamp.fromDate(history.completedAt);
    final docRef = await _innerCollection.add(map);
    return docRef.id;
  }

  Future<List<StudyHistory>> getHistoryByUserId(String userId) async {
    try {
      print('getHistoryByUserId called for userId: $userId');
      print('Querying collection: ${_innerCollection.path}');
      
      // Add timeout to prevent hanging
      final query = await _innerCollection
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Query timeout after 10 seconds');
              throw TimeoutException('History query timed out');
            },
          );

      print('Query completed. Found ${query.docs.length} documents');

      if (query.docs.isEmpty) {
        print('No history documents found for user: $userId');
        return [];
      }

      final histories = query.docs.map((d) {
        try {
          final data = _normalizeDocData(d.data());
          final historyMap = Map<String, dynamic>.from(data);
          historyMap['id'] = d.id;
          return StudyHistory.fromMap(historyMap);
        } catch (e) {
          print('Error parsing history document ${d.id}: $e');
          return null;
        }
      }).whereType<StudyHistory>().toList();

      // Ordenar por completedAt em ordem decrescente
      histories.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      print('Returning ${histories.length} histories');
      return histories;
    } on TimeoutException catch (e) {
      print('Timeout in getHistoryByUserId: $e');
      return [];
    } catch (e, stackTrace) {
      print('Error in getHistoryByUserId: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Stream<List<StudyHistory>> historyStream(String userId) {
    try {
      print('Creating historyStream for userId: $userId');
      return _innerCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
            print('History stream snapshot received: ${snap.docs.length} docs');
            try {
              final histories = snap.docs
                  .map((d) {
                    try {
                      final data = _normalizeDocData(d.data());
                      final historyMap = Map<String, dynamic>.from(data);
                      historyMap['id'] = d.id;
                      return StudyHistory.fromMap(historyMap);
                    } catch (e) {
                      print('Error parsing history doc ${d.id}: $e');
                      return null;
                    }
                  })
                  .whereType<StudyHistory>()
                  .toList();

              histories.sort((a, b) => b.completedAt.compareTo(a.completedAt));
              print('Parsed ${histories.length} histories');
              return histories;
            } catch (e) {
              print('Error processing snapshot: $e');
              return <StudyHistory>[];
            }
          })
          .handleError((error, stackTrace) {
            print('Error in historyStream: $error');
            print('Stack trace: $stackTrace');
            // Re-throw para que o listener possa tratar
            throw error;
          });
    } catch (e, stackTrace) {
      print('Error creating historyStream: $e');
      print('Stack trace: $stackTrace');
      return Stream.value(<StudyHistory>[]);
    }
  }

  Future<void> deleteHistory(String id) async {
    await _innerCollection.doc(id).delete();
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
