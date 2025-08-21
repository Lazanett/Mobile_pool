// import 'package:flutter/widgets.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firestore_service.dart'; // ton fichier firestore_service.dart

// Future<void> populateTestData() async {
//   final firestore = FirestoreService();
//   const testUserEmail = "u4284112739@gmail.com";

//   final collections = ["Journal Personnel", "Vacances", "Travail", "Santé", "Projets"];
//   final entries = [
//     {"title": "Première entrée", "feeling": "Heureux", "content": "Aujourd'hui, j'ai testé mon app de journal."},
//     {"title": "Deuxième entrée", "feeling": "Fatigué", "content": "J'ai beaucoup codé aujourd'hui."},
//     {"title": "Troisième entrée", "feeling": "Motivé", "content": "Je suis prêt pour de nouveaux défis!"}
//   ];

//   // Ajouter les collections
//   for (var colName in collections) {
//     await firestore.addCollection(userEmail: testUserEmail, nameCollection: colName);
//   }

//   // Récupérer les collections créées
//   final collectionsSnapshot = await FirebaseFirestore.instance
//       .collection("collections")
//       .where("emailUser", isEqualTo: testUserEmail)
//       .get();

//   // Ajouter des entrées dans chaque collection
//   for (var col in collectionsSnapshot.docs) {
//     final colId = col.id;
//     for (var entry in entries) {
//       await firestore.addEntry(
//         collectionId: colId,
//         userEmail: testUserEmail,
//         title: entry["title"]!,
//         feeling: entry["feeling"]!,
//         content: entry["content"]!,
//         date: DateTime.now().subtract(Duration(days: entries.indexOf(entry))),
//       );
//     }
//   }

//   print("Données de test ajoutées !");
// }
