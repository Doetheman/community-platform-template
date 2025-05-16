import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class VideoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<String?> pickAndUploadVideo({
    required String chatId,
    required String senderId,
    Duration? maxDuration,
  }) async {
    try {
      // Pick video
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );

      if (video == null) return null;

      // Check file size (max 100MB)
      final file = File(video.path);
      if (await file.length() > 100 * 1024 * 1024) {
        throw Exception('Video file too large. Maximum size is 100MB');
      }

      // Generate unique filename
      final extension = path.extension(video.path);
      final filename = '${_uuid.v4()}$extension';
      final ref = _storage.ref().child('chats/$chatId/videos/$filename');

      // Upload video
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'senderId': senderId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Get download URL
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVideo(String videoUrl) async {
    try {
      final ref = _storage.refFromURL(videoUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}
