// services/note_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService {
  static const String notesKey = 'notes';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(notesKey) ?? [];
    return data.map((note) => Note.fromJson(jsonDecode(note))).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(notesKey, data);
  }
}
