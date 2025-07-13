import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/note_card.dart';
import 'add_note_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final AuthService _authService = AuthService();
  final Color primaryColor = const Color(0xFF7CBA3B);
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
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.roboto(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SigninScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Your Notes",
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Logout",
          ),
        ],
      ),
      body: _notes.isEmpty
          ? Center(
              child: Text(
                "No notes yet. Tap + to add one!",
                style: GoogleFonts.roboto(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (_, index) => NoteCard(note: _notes[index]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNoteScreen()),
          );
          if (updated == true) _loadNotes();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
