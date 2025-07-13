class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  String? category;
  bool isStarred;
  String? imagePath;
  String? filePath;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.category,
    this.isStarred = false,
    this.imagePath,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
        'isStarred': isStarred,
        'imagePath': imagePath,
        'filePath': filePath,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        category: json['category'],
        isStarred: json['isStarred'] ?? false,
        imagePath: json['imagePath'],
        filePath: json['filePath'],
      );
}
