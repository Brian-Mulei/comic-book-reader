import 'dart:io';
import 'package:comic_book_reader/config/db_config.dart';
import 'package:comic_book_reader/core/thumbnail_helper.dart';
import 'package:comic_book_reader/models/comics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart'; // Import this
 
class ComicController extends GetxController {
  RxList<Comic> comics = <Comic>[].obs;

  // Search query and sort order
  RxString searchQuery = ''.obs;
  RxString sortOrder = 'Recently Added'.obs;

  // Filtered & sorted comics
  RxList<Comic> filteredComics = <Comic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadComics();
        everAll([comics, searchQuery, sortOrder], (_) => _applyFilters());
  }

  /// Load comics from Sqflite
  Future<void> loadComics() async {
    final allComics = await DatabaseHelper().getComics();
    comics.assignAll(allComics);
  }

 
  void _applyFilters() {
    List<Comic> temp = List.from(comics);

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      temp = temp
          .where((c) => c.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (sortOrder.value) {
      case 'Last Read':
        temp.sort((a, b) {
          final aTime = a.lastOpened ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.lastOpened ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        break;
      case 'Recently Added':
        temp.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case 'A-Z':
        temp.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'Z-A':
        temp.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    filteredComics.assignAll(temp);
  }




// ... other imports

Future<void> importComic() async {
  try {
    // 1. USE FILE_PICKER INSTEAD OF OPENFILE
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['cbz', 'cbr', 'pdf', 'epub'],
      // onFileLoading: (status) => print(status), // Optional: for UI feedback
    );

    if (result == null) return; // User canceled

    // Get the path directly from the result
    final filePath = result.files.single.path;
    
    if (filePath == null) {
      print("Error: Could not retrieve file path");
      return;
    }

    // 2. The rest of your logic remains the same!
    
    // Check file size (e.g., limit to 500MB)
    final fileSize = await File(filePath).length();
    if (fileSize > 5000 * 1024 * 1024) {
      print('File too large to import (>500MB)');
      return;
    }

    // Determine library destination
    final docs = await getApplicationDocumentsDirectory();
    final libraryDir = Directory(p.join(docs.path, 'library'));
    if (!await libraryDir.exists()) {
      await libraryDir.create(recursive: true);
    }

    final newPath = p.join(libraryDir.path, p.basename(filePath));

    final format = p.extension(filePath).replaceFirst('.', '').toLowerCase();
     await compute(_copyFileSync, [filePath, newPath]);

    final coverPath = await generateThumbnail(newPath, format);
    // Create Comic object
    final comic = Comic(
      title: p.basenameWithoutExtension(filePath),
      filePath: newPath,
      format: format,
      coverPath: coverPath
    );

    // Insert into database
    await DatabaseHelper().insertComic(comic);

    // Reload comics list
    await loadComics();
  } catch (e, stack) {
    print('Import comic error: $e');
    print(stack);
  }
}
 
  // Helper for compute (runs in isolate)
  static void _copyFileSync(List<String> paths) {
    final src = File(paths[0]);
    final dest = File(paths[1]);
    src.copySync(dest.path);
  }
  /// Delete a comic
  Future<void> deleteComic(Comic comic) async {
    try {
      if (comic.id != null) {
        await DatabaseHelper().deleteComic(comic.id!);
        // Optionally delete file from disk
        final file = File(comic.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        await loadComics();
      }
    } catch (e) {
      print("Delete comic error: $e");
    }
  }

  /// Update a comic (e.g., reading progress, coverPath)
  Future<void> updateComic(Comic comic) async {
    try {
      if (comic.id != null) {
        await DatabaseHelper().insertComic(comic); // insertComic does upsert
        await loadComics();
      }
    } catch (e) {
      print("Update comic error: $e");
    }
  }
}
