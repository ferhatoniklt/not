import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'new_note_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CyberNoteApp());
}

class CyberNoteApp extends StatelessWidget {
  const CyberNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Orbitron',
        scaffoldBackgroundColor: const Color(0xFF000000),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      home: const CyberNoteHomePage(),
    );
  }
}

class CyberNoteHomePage extends StatefulWidget {
  const CyberNoteHomePage({super.key});

  @override
  State<CyberNoteHomePage> createState() => _CyberNoteHomePageState();
}

class _CyberNoteHomePageState extends State<CyberNoteHomePage> {
  final TextEditingController searchController = TextEditingController();
  Set<String> selectedNotes = {};

  void openNewNotePage({Map<String, dynamic>? existingNote, String? docId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewNotePage(note: existingNote, docId: docId),
      ),
    );
  }

  void deleteSelectedNotes() async {
    for (var docId in selectedNotes) {
      await FirebaseFirestore.instance.collection('notes').doc(docId).delete();
    }
    setState(() => selectedNotes.clear());
  }

  void toggleSelection(String docId) {
    setState(() {
      if (selectedNotes.contains(docId)) {
        selectedNotes.remove(docId);
      } else {
        selectedNotes.add(docId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: selectedNotes.isEmpty
            ? const Center(child: Text('NOTLAR', style: TextStyle(color: Colors.redAccent)))
            : Text('${selectedNotes.length} Seçildi', style: const TextStyle(color: Colors.redAccent)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.redAccent),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (selectedNotes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: deleteSelectedNotes,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Image.asset('assets/avatar.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 130,
                    child: Image.asset('assets/a.gif', fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Not ara...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Hata oluştu'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.data!.docs;

                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final query = searchController.text.toLowerCase();
                  return data['title'].toString().toLowerCase().contains(query) ||
                      data['content'].toString().toLowerCase().contains(query);
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final isSelected = selectedNotes.contains(docId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          if (selectedNotes.isEmpty) {
                            openNewNotePage(existingNote: data, docId: docId);
                          } else {
                            toggleSelection(docId);
                          }
                        },
                        onLongPress: () => toggleSelection(docId),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.redAccent.withOpacity(0.3) : const Color(0xFF0B0A0F),
                            border: Border.all(color: Colors.redAccent),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.asset('assets/z1.gif', fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['title'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                                    Text(data['content'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70)),
                                    Text(data['date'] ?? '',
                                        style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('Canlı Notlar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: Image.asset('assets/22.gif', fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => openNewNotePage(),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('© 2025 NEO KLOTHO . All rights reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
