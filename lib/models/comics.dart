class Comic {
  int? id;                   // database id
  late String title;
  late String filePath;       // path to file on disk
  String? coverPath;          // thumbnail
  late String format;         // cbz/cbr/pdf/epub/folder

  int currentPage = 0;
  int totalPages = 0;

  DateTime addedAt = DateTime.now();
  DateTime? lastOpened;

  Comic({
    this.id,
    required this.title,
    required this.filePath,
    this.coverPath,
    required this.format,
    this.currentPage = 0,
    this.totalPages = 0,
    DateTime? addedAt,
    this.lastOpened,
  }) {
    this.addedAt = addedAt ?? DateTime.now();
  }

  // Convert Comic to Map for Sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'coverPath': coverPath,
      'format': format,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'addedAt': addedAt.toIso8601String(),
      'lastOpened': lastOpened?.toIso8601String(),
    };
  }

  // Create Comic from database Map
  factory Comic.fromMap(Map<String, dynamic> map) {
    return Comic(
      id: map['id'],
      title: map['title'],
      filePath: map['filePath'],
      coverPath: map['coverPath'],
      format: map['format'],
      currentPage: map['currentPage'] ?? 0,
      totalPages: map['totalPages'] ?? 0,
      addedAt: map['addedAt'] != null ? DateTime.parse(map['addedAt']) : DateTime.now(),
      lastOpened: map['lastOpened'] != null ? DateTime.parse(map['lastOpened']) : null,
    );
  }
}
