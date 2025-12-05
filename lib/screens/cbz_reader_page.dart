import 'dart:io';
import 'package:comic_book_reader/controllers/comic_controller.dart';
import 'package:comic_book_reader/models/comics.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:get/get.dart';
  
class CBZReaderPage extends StatefulWidget {
  final Comic comic;

  const CBZReaderPage({super.key, required this.comic});

  @override
  _CBZReaderPageState createState() => _CBZReaderPageState();
}

class _CBZReaderPageState extends State<CBZReaderPage> {
  List<ArchiveFile> _pages = [];
  int _currentPage = 0;

final controller = Get.find<ComicController>();
  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    final bytes = File(widget.comic.filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Only images, sorted by name
    final images = archive.files
        .where((f) => !f.isFile ? false : f.name.endsWith('.jpg') || f.name.endsWith('.png'))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _pages = images;
      _currentPage = widget.comic.currentPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: PageController(initialPage: _currentPage),
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          // Optionally save current page to DB
          widget.comic.currentPage = index;
              controller.updateCurrentPage(widget.comic, index);
        },
        itemBuilder: (context, index) {
          final file = _pages[index];
          final image = file.content ;
          return InteractiveViewer(
            child: Image.memory(
              image,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
