import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/comic_controller.dart';

 
 
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComicController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Comics"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search comics...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => DropdownButton<String>(
                      value: controller.sortOrder.value,
                      items: const [
                        DropdownMenuItem(value: 'Recently Added', child: Text('Recently Added')),
                        DropdownMenuItem(value: 'Last Read', child: Text('Last Read')),
                        DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                        DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.sortOrder.value = value;
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.importComic,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final comics = controller.filteredComics;

        if (comics.isEmpty) {
          return const Center(
            child: Text("No comics found."),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            itemCount: comics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final comic = comics[index];
              return GestureDetector(
                onTap: () {
                  // TODO: Navigate to reader
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: comic.coverPath != null
                          ? Image.file(File(comic.coverPath!), fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.book, size: 48, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
