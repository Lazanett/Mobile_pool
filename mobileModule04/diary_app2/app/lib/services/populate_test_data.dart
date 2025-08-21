import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> populateTestDataForUser(String userEmail) async {
//   final db = FirebaseFirestore.instance;

//   // Helpers pour transformer email / noms en clés sûres
//   String normalize(String s) => s
//       .toLowerCase()
//       .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
//       .replaceAll(RegExp(r'_+'), '_')
//       .replaceAll(RegExp(r'^_|_$'), '');

//   String emailKey(String e) =>
//       e.toLowerCase().replaceAll('@', '_at_').replaceAll('.', '_dot_');

//   // Les 3 collections logiques
//   final names = ['Journal Personnel', 'Travail', 'Santé'];

//   final batch = db.batch();
//   final now = FieldValue.serverTimestamp();

//   for (final name in names) {
//     final docId = 'u:${emailKey(userEmail)}|c:${normalize(name)}';
//     final ref = db.collection('collections').doc(docId);

//     // set avec merge → si le doc existe déjà, il est mis à jour
//     batch.set(ref, {
//       "emailUser": userEmail,
//       "nameCollection": name,
//       "createdAt": now,
//     }, SetOptions(merge: true));
//   }

//   await batch.commit();
//   print("✅ Les 3 collections sont prêtes pour $userEmail");
// }
