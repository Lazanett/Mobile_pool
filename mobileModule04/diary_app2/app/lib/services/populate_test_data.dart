import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateTestDataForUser(String userEmail) async {
  final db = FirebaseFirestore.instance;

    if (userEmail != "u4284112739@gmail.com") {
    return;
  }
  // Vérifier si les données de test existent déjà
  final existingCollections = await db
      .collection('collections')
      .where('emailUser', isEqualTo: userEmail)
      .where('isTestData', isEqualTo: true)
      .get();

  if (existingCollections.docs.isNotEmpty) {
    print("✅ Les données de test existent déjà pour $userEmail");
    return;
  }

  // Définir les collections et leurs documents de test
  final collectionsData = [
    {
      'name': 'Journal Personnel',
      'documents': [
        {
          'title': 'Ma première journée',
          'feeling': '😊 Heureux',
          'content': 'Aujourd\'hui a été une journée fantastique ! J\'ai commencé un nouveau projet qui me passionne beaucoup.',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'title': 'Réflexions du soir',
          'feeling': '🤔 Pensif',
          'content': 'Je repense à mes objectifs de l\'année. Il est important de faire le point régulièrement sur ses progrès.',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
      ],
    },
    {
      'name': 'Travail',
      'documents': [
        {
          'title': 'Réunion équipe',
          'feeling': '💼 Professionnel',
          'content': 'Réunion productive avec l\'équipe. Nous avons défini les priorités pour le prochain sprint.',
          'date': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'title': 'Formation Flutter',
          'feeling': '🚀 Motivé',
          'content': 'J\'ai appris de nouvelles techniques en Flutter aujourd\'hui. Le développement mobile devient de plus en plus intéressant !',
          'date': DateTime.now().subtract(const Duration(hours: 5)),
        },
      ],
    },
    {
      'name': 'Santé',
      'documents': [
        {
          'title': 'Séance de sport',
          'feeling': '💪 Énergique',
          'content': 'Excellente séance de sport ce matin ! Je me sens plein d\'énergie pour attaquer la journée.',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
      ],
    },
  ];

  final batch = db.batch();
  final now = FieldValue.serverTimestamp();

  // Créer les collections et leurs documents
  for (final collectionData in collectionsData) {
    // Créer la collection avec un ID auto-généré (comme dans addCollection)
    final collectionRef = db.collection('collections').doc();
    
    batch.set(collectionRef, {
      "emailUser": userEmail,
      "nameCollection": collectionData['name'],
      "createdAt": now,
      "isTestData": true, // Flag pour identifier les données de test
    });

    // Créer les documents pour cette collection
    final documents = collectionData['documents'] as List<Map<String, dynamic>>;
    for (final docData in documents) {
      final entryRef = db.collection('entries').doc();
      
      batch.set(entryRef, {
        "collectionId": collectionRef.id, // Référence à la collection
        "email": userEmail,
        "title": docData['title'],
        "feeling": docData['feeling'],
        "content": docData['content'],
        "date": (docData['date'] as DateTime).toIso8601String(),
      });
    }
  }

  await batch.commit();
  print("✅ Les collections et documents de test ont été créés pour $userEmail");
}