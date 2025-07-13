import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'add_note_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  final Color primaryColor = const Color(0xFF7CBA3B);

  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];

  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadUserName();
    _searchController.addListener(_applyTextSearch);
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final email = user.email!;
      final name = email.contains('@') ? email.split('@')[0] : email;
      setState(() {
        _userName = name[0].toUpperCase() + name.substring(1);
      });
    }
  }

  void _loadNotes() async {
    _allNotes = await _noteService.loadNotes();
    _filteredNotes = List.from(_allNotes);
    setState(() {});
  }

  void _applyTextSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _allNotes.where((note) {
        return note.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _pickDateTimeFilter() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: primaryColor,
                onPrimary: Colors.white,
                surface: Colors.black,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF121212),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _filteredNotes = _allNotes.where((note) {
            return note.createdAt.year == selectedDateTime.year &&
                note.createdAt.month == selectedDateTime.month &&
                note.createdAt.day == selectedDateTime.day &&
                note.createdAt.hour == selectedDateTime.hour &&
                (note.createdAt.minute - selectedDateTime.minute).abs() <= 5;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Filtered by ${DateFormat.yMMMd().add_jm().format(selectedDateTime)}'),
            backgroundColor: Colors.grey[900],
          ),
        );
      }
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _filteredNotes = List.from(_allNotes);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters cleared. Showing all notes.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pop(context); // or redirect to login
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Hey, $_userName 👋",
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search by title...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF121212),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _pickDateTimeFilter,
                  tooltip: 'Filter by date & time',
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: _clearFilters,
                  tooltip: 'Clear filters',
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(
                    child: Text(
                      "📝 No notes found!",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (_, index) {
                      final note = _filteredNotes[index];
                      return Card(
                        color: const Color(0xFF121212),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(note.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.content.length > 100
                                    ? note.content.substring(0, 100) + "..."
                                    : note.content,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEE, MMM d • hh:mm a')
                                    .format(note.createdAt),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
