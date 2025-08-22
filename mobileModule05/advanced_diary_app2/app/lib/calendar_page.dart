import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'services/firestore_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;
  
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<QueryDocumentSnapshot> _selectedDayEntries = [];
  bool _isLoadingEntries = false;

  @override
  void initState() {
    super.initState();
    _loadEntriesForDay(_selectedDay);
  }

  // Charger les entrées pour une date spécifique
  Future<void> _loadEntriesForDay(DateTime day) async {
    if (user == null) return;
    
    setState(() {
      _isLoadingEntries = true;
    });

    try {
      // Récupérer toutes les collections de l'utilisateur
      final collectionsSnapshot = await _firestoreService.getUserCollections(user!.email!).first;
      List<QueryDocumentSnapshot> dayEntries = [];

      // Parcourir chaque collection pour trouver les entrées de cette date
      for (var collection in collectionsSnapshot.docs) {
        final entriesSnapshot = await _firestoreService.getCollectionDocuments(collection.id).first;
        
        // Filtrer les entrées par date (format ISO string)
        for (var entry in entriesSnapshot.docs) {
          try {
            // Convertir la date ISO string en DateTime
            DateTime entryDate = DateTime.parse(entry["date"]);
            
            // Comparer uniquement les dates (ignorer l'heure)
            if (entryDate.year == day.year && 
                entryDate.month == day.month && 
                entryDate.day == day.day) {
              dayEntries.add(entry);
            }
          } catch (e) {
            print("Erreur lors du parsing de la date: ${entry["date"]} - $e");
          }
        }
      }

      setState(() {
        _selectedDayEntries = dayEntries;
        _isLoadingEntries = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des entrées : $e");
      setState(() {
        _selectedDayEntries = [];
        _isLoadingEntries = false;
      });
    }
  }

  // Afficher les détails d'une entrée
  void _showEntryDetails(QueryDocumentSnapshot entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry["title"]),
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
                    entry["feeling"],
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
                    entry["date"],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Content :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(entry["content"]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          // TextButton(
          //   onPressed: () async {
          //     Navigator.pop(context);
          //     await _firestoreService.deleteEntry(entry.id);
          //     // Recharger les entrées après suppression
          //     _loadEntriesForDay(_selectedDay);
              
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text("Entry deleted successfully")),
          //     );
          //   },
          //   child: const Text("Delete", style: TextStyle(color: Colors.red)),
          // ),
        ],
      ),
    );
  }

  // Formatage de la date pour l'affichage
  String _formatDisplayDate(String isoDateString) {
    try {
      DateTime date = DateTime.parse(isoDateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoDateString; // Retourner la chaîne originale si erreur
    }
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
        title: const Text(
          "Calendar",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFA07A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Calendrier
            Card(
              margin: const EdgeInsets.all(16.0),
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFFFA07A),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.red),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFA07A),
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color(0xFFFFA07A),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color(0xFFFFA07A),
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadEntriesForDay(selectedDay);
                  },
                ),
              ),
            ),
            
            // Liste des entrées pour la date sélectionnée
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // En-tête
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA07A).withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Entries for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA07A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // Liste des entrées
                      Expanded(
                        child: _isLoadingEntries
                            ? const Center(child: CircularProgressIndicator())
                            : _selectedDayEntries.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.event_note,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "No entries for this date",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: _selectedDayEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _selectedDayEntries[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: const Color(0xFFFFA07A),
                                            child: Text(
                                              entry["feeling"].split(' ')[0],
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          title: Text(
                                            entry["title"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            entry["feeling"],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          trailing: const Icon(Icons.arrow_forward_ios),
                                          onTap: () => _showEntryDetails(entry),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}