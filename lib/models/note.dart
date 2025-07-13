class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? category; // New: Optional category
  final String? imagePath; // New: Optional image path
  final String? filePath; // New: Optional file path

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.category,
    this.imagePath,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
        'imagePath': imagePath,
        'filePath': filePath,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        category: json['category'],
        imagePath: json['imagePath'],
        filePath: json['filePath'],
      );
}
