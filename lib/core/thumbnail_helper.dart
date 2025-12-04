import 'dart:io';
 
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img; // for image processing

/// Generate a thumbnail for a comic file.
/// Returns the path to the thumbnail, or null if failed.
Future<String?> generateThumbnail(String filePath, String format) async {
  switch (format.toLowerCase()) {
    case 'cbz':
      return await _generateCbzThumbnail(filePath);
    // case 'pdf':
    //   return await _generatePdfThumbnail(filePath);
    case 'folder':
      return await _generateFolderThumbnail(filePath);
    default:
      return null; // For CBR or EPUB, can add later
  }
}

/// ----- CBZ -----
Future<String?> _generateCbzThumbnail(String cbzPath) async {
  try {
    final bytes = File(cbzPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final images = archive.files
        .where((f) => !f.isFile ? false : f.name.endsWith('.jpg') || f.name.endsWith('.png'))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (images.isEmpty) return null;

    final firstImage = images.first;
    final imageData = firstImage.content ;
    final image = img.decodeImage(imageData);
    if (image == null) return null;

    final thumbnail = img.copyResize(image, width: 200);

    final thumbPath =
        p.join(p.dirname(cbzPath), 'thumb_${p.basenameWithoutExtension(cbzPath)}.png');
    File(thumbPath).writeAsBytesSync(img.encodePng(thumbnail));
    return thumbPath;
  } catch (e) {
    print('CBZ thumbnail error: $e');
    return null;
  }
}

/// ----- PDF -----
/// 
/*
Future<String?> _generatePdfThumbnail(String pdfPath) async {
  try {
    final doc = await PdfDocument.openFile(pdfPath);
    final page = await doc.getPage(1);
    final pageImage = await page.render(width: 200); // width in pixels
    final image = img.Image.fromBytes(pageImage.width, pageImage.height, pageImage.bytes);
    final thumbnail = img.copyResize(image, width: 200);

    final thumbPath =
        p.join(p.dirname(pdfPath), 'thumb_${p.basenameWithoutExtension(pdfPath)}.png');
    File(thumbPath).writeAsBytesSync(img.encodePng(thumbnail));

    await page.close();
    await doc.close();
    return thumbPath;
  } catch (e) {
    print('PDF thumbnail error: $e');
    return null;
  }
}

*/
/// ----- Folder -----
Future<String?> _generateFolderThumbnail(String folderPath) async {
  try {
    final dir = Directory(folderPath);
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    if (files.isEmpty) return null;

    final image = img.decodeImage(await files.first.readAsBytes());
    if (image == null) return null;

    final thumbnail = img.copyResize(image, width: 200);
    final thumbPath = p.join(dir.path, 'thumb_${p.basename(dir.path)}.png');
    File(thumbPath).writeAsBytesSync(img.encodePng(thumbnail));
    return thumbPath;
  } catch (e) {
    print('Folder thumbnail error: $e');
    return null;
  }
}
