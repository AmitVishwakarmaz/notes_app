import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'add_note_screen.dart';
import '../widgets/note_card.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final AuthService _authService = AuthService();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    _notes = await _noteService.loadNotes();
    setState(() {});
  }

  void _logout() async {
    await _authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Notes"),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: _notes.isEmpty
          ? Center(child: Text("No notes yet. Tap + to add one!"))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (_, index) => NoteCard(note: _notes[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNoteScreen()),
          );
          if (updated == true) _loadNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
