import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/model/user.dart';

class FirestoreUserProvider {
  static FirestoreUserProvider helper = FirestoreUserProvider._();
  FirestoreUserProvider._();

  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection("users");

  String usersDocRef = "usuarios";

  insertUser(User user) {
    userCollection.doc(usersDocRef).collection("users").add(user.toMap());
  }

  Future<User?> findUserByEmail(String email) async {
    final query = await userCollection
        .doc(usersDocRef)
        .collection("users")
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    return User.fromMap(data);
  }
}
