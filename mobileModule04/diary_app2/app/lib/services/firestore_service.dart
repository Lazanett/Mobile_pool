import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a collection
  Future<void> addCollection({
    required String userEmail,
    required String nameCollection,
  }) async {
    await _db.collection("collections").add({
      "emailUser": userEmail,
      "nameCollection": nameCollection,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Recover all collections of a user
  Stream<QuerySnapshot> getUserCollections(String userEmail) {
    return _db
        .collection("collections")
        .where("emailUser", isEqualTo: userEmail)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Add note in a collection
  Future<void> addEntry({
    required String collectionId,
    required String userEmail,
    required String title,
    required String feeling,
    required String content,
    required DateTime date,
  }) async {
    await _db.collection("entries").add({
      "collectionId": collectionId,
      "email": userEmail,
      "title": title,
      "feeling": feeling,
      "content": content,
      "date": date.toIso8601String(),
    });
  }

  // Consult the note of a collection
  Stream<QuerySnapshot> getCollectionDocuments(String collectionId) {
    return _db
        .collection("entries")
        .where("collectionId", isEqualTo: collectionId)
        .orderBy("date", descending: true)
        .snapshots();
  }

  // Consult all note
  Stream<QuerySnapshot> getUserEntries(String userEmail) {
    return _db
        .collection("entries")
        .where("email", isEqualTo: userEmail)
        .orderBy("date", descending: true)
        .snapshots();
  }

  // Delete a note
  Future<void> deleteEntry(String entryId) async {
    await _db.collection("entries").doc(entryId).delete();
  }
}
