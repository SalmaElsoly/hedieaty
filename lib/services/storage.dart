import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance.ref();

  Future<String> uploadImageToGifts(String imageName, String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw Exception('File not found at $imagePath');
      }

      final uploadTask = await _storage.child('gifts/$imageName').putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('Download URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImageToUsers(String imageName, String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw Exception('File not found at $imagePath');
    }

    final uploadTask = await _storage.child('users/$imageName').putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteImageFromGifts(String imageName) async {
    await _storage.child('gifts/$imageName').delete();
  }

  Future<void> deleteImageFromUsers(String imageName) async {
    await _storage.child('users/$imageName').delete();
  }
}
