import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _collectionNameController = TextEditingController();

  String? selectedCollectionId;
  String? selectedCollectionName;

  // 🔒 Déconnexion
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      debugPrint("Disconnection error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout: $e")),
      );
    }
  }

  // create new collection
  Future<void> _showCreateCollectionDialog() async {
    final TextEditingController _collectionNameController = TextEditingController();

    return showDialog(
      context: context, // contexte parent du widget
      builder: (dialogContext) => AlertDialog(
        title: const Text("Create a collection"),
        content: TextField(
          controller: _collectionNameController,
          decoration: const InputDecoration(
            labelText: "Collection name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _collectionNameController.clear();
              Navigator.of(dialogContext).pop(); // fermer popup avec context du builder
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_collectionNameController.text.isNotEmpty) {
                try {
                  await _firestoreService.addCollection(
                    userEmail: user!.email!,
                    nameCollection: _collectionNameController.text,
                  );
                } catch (e) {
                  print("Erreur lors de la création : $e");
                }
                _collectionNameController.clear(); // réinitialiser l'input
                if (dialogContext.mounted) Navigator.of(dialogContext).pop(); // fermer popup
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA07A),
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // print details note
  void _showDocumentDetails(QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc["title"]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_emotions, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    doc["feeling"],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    doc["date"],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Contenu :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(doc["content"]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.deleteEntry(doc.id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${user!.email}",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA07A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _logout();
          },
        ),
        actions: selectedCollectionId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedCollectionId = null;
                      selectedCollectionName = null;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: selectedCollectionId == null
            ? _buildCollectionsList()
            : _buildDocumentsList(),
      ),
      floatingActionButton: selectedCollectionId == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add_entry',
                  arguments: {
                    'collectionId': selectedCollectionId,
                    'collectionName': selectedCollectionName,
                  },
                );
              },
              backgroundColor: const Color(0xFFFFA07A),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  // Widget for list of collections
  Widget _buildCollectionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getUserCollections(user!.email!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyCollectionsState();
        }

        final collections = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: collections.length + 1,
          itemBuilder: (context, index) {
            if (index == collections.length) {
              // Bouton add new collection
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _showCreateCollectionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA07A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("New Collection"),
                ),
              );
            }

            final collection = collections[index];
            return Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.folder,
                  color: Color(0xFFFFA07A),
                  size: 28,
                ),
                title: Text(
                  collection["nameCollection"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  setState(() {
                    selectedCollectionId = collection.id;
                    selectedCollectionName = collection["nameCollection"];
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  // 📄 Widget for note list of collection
  Widget _buildDocumentsList() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Text(
            selectedCollectionName ?? "Collection",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFA07A),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // List notes
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getCollectionDocuments(selectedCollectionId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyDocumentsState();
              }

              final documents = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFA07A),
                        child: Text(
                          doc["feeling"].split(' ')[0],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        doc["title"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        doc["date"],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showDocumentDetails(doc),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // empty profile 
  Widget _buildEmptyCollectionsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 80,
              color: Color(0xFFFFA07A),
            ),
            const SizedBox(height: 16),
            const Text(
              "No collection",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA07A),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateCollectionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA07A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Create a Collection"),
            ),
          ],
        ),
      ),
    );
  }

  // No document in collection
  Widget _buildEmptyDocumentsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.note_add,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              "No document",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This collection is empty.",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Format the date
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Date unknown";
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
    super.dispose();
  }
}