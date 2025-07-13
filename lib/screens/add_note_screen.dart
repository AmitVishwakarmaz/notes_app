import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? existingNote;
  const AddNoteScreen({this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NoteService _noteService = NoteService();

  String? _selectedCategory;
  File? _attachedImage;
  String? _attachedFilePath;
  bool _isSaving = false;

  final Color primaryColor = const Color(0xFF7CBA3B);
  final List<String> _categories = ['Work', 'Personal', 'Study', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      final note = widget.existingNote!;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedCategory = note.category;
      if (note.imagePath != null) {
        _attachedImage = File(note.imagePath!);
      }
      _attachedFilePath = note.filePath;
    }
  }

  void _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final note = Note(
      id: widget.existingNote?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
      category: _selectedCategory,
      imagePath: _attachedImage?.path,
      filePath: _attachedFilePath,
      isStarred: widget.existingNote?.isStarred ?? false,
    );

    final notes = await _noteService.loadNotes();
    if (widget.existingNote != null) {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) notes[index] = note;
    } else {
      notes.add(note);
    }

    await _noteService.saveNotes(notes);
    Navigator.pop(context, true);
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() => _attachedImage = File(pickedFile.path));
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F0F), Color(0xFF1F2E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Add/Edit Note",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    maxLength: 100,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Title"),
                    validator: (value) =>
                        (value == null || value.trim().length < 5)
                            ? "Title must be at least 5 characters."
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentController,
                    minLines: 5,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Content"),
                    validator: (value) =>
                        (value == null || value.trim().length < 10)
                            ? "Content must be at least 10 characters."
                            : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF1C1C1C),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Select Category"),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                  const SizedBox(height: 16),
                  if (_attachedImage != null)
                    Column(
                      children: [
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Attached Image:",
                                style: TextStyle(color: Colors.grey))),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_attachedImage!, height: 150),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  if (_attachedFilePath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "📎 ${_attachedFilePath!.split('/').last}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt, color: Color(0xFF7CBA3B)),
                          label: const Text("Capture Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        _formKey.currentState?.validate() == true && !_isSaving
                            ? _saveNote
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Note",
                            style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
