import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:st/src/data/utils/string_utils.dart';

class UploadHelper {
  static Future<String?> uploadPhoto(String id, String firestorePath, String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      String contentType;
      String imageFormat;

      if (imagePath.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
        imageFormat = '.png';
      } else if (imagePath.toLowerCase().endsWith('.jpg') || imagePath.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
        imageFormat = '.jpg';
      } else {
        throw UnsupportedError('Unsupported image format');
      }

      final String photoUrl = StringUtils.createUrl(id);

      await FirebaseStorage.instance.ref('$firestorePath/$photoUrl$imageFormat').putFile(
            imageFile,
            SettableMetadata(contentType: contentType),
          );

      final String downloadURL =
          await FirebaseStorage.instance.ref('$firestorePath/$photoUrl$imageFormat').getDownloadURL();

      return downloadURL;
    } catch (e, st) {
      print('Error uploading image: $e');
      print(st);
      rethrow;
    }
  }
}
