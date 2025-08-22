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
      'name': 'Personal Diary',
      'documents': [
        {
          'title': 'My first day',
          'feeling': '😊 Happy',
          'content': 'Today was a fantastic day! I started a new project that I am very excited about.',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'title': 'Evening reflections',
          'feeling': '😮 Surprise',
          'content': 'I think back on my goals for the year.',
          'date': DateTime.now().subtract(const Duration(days: 1)),
        },
      ],
    },
    {
      'name': 'Work',
      'documents': [
        {
          'title': 'Team meeting',
          'feeling': '😊 Happy',
          'content': 'Productive meeting with the team. We defined the priorities for the next sprint.',
          'date': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'title': 'Flutter Training',
          'feeling': '😊 Happy',
          'content': 'I learned some new Flutter techniques today. Mobile development is getting more and more interesting!',
          'date': DateTime.now().subtract(const Duration(hours: 5)),
        },
      ],
    },
    {
      'name': 'Health',
      'documents': [
        {
          'title': 'Workout session',
          'feeling': '😊 Happy',
          'content': 'Great workout this morning! I feel energized and ready to tackle the day.',
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