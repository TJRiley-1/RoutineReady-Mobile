import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _maxFileSize = 2 * 1024 * 1024; // 2MB
const _warnFileSize = 500 * 1024; // 500KB

class ImageUploadResult {
  final String? publicUrl;
  final String? error;
  final bool isWarning;

  ImageUploadResult({this.publicUrl, this.error, this.isWarning = false});
}

/// Pick an image from gallery and upload to Supabase Storage.
/// Returns the public URL on success, or an error message.
Future<ImageUploadResult> pickAndUploadTaskImage(String schoolId) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 80,
  );

  if (picked == null) {
    return ImageUploadResult(error: 'cancelled');
  }

  final bytes = await picked.readAsBytes();

  if (bytes.length > _maxFileSize) {
    return ImageUploadResult(
      error: 'Image is too large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB). Maximum is 2MB.',
    );
  }

  final isLarge = bytes.length > _warnFileSize;
  final ext = _extensionFromName(picked.name);
  final fileName = '${const Uuid().v4()}.$ext';
  final storagePath = '$schoolId/$fileName';

  try {
    await Supabase.instance.client.storage
        .from('task-images')
        .uploadBinary(storagePath, bytes, fileOptions: FileOptions(
          contentType: picked.mimeType ?? 'image/$ext',
        ));

    final publicUrl = Supabase.instance.client.storage
        .from('task-images')
        .getPublicUrl(storagePath);

    return ImageUploadResult(publicUrl: publicUrl, isWarning: isLarge);
  } catch (e) {
    return ImageUploadResult(error: 'Upload failed: $e');
  }
}

/// Delete an image from Supabase Storage by its public URL.
Future<void> deleteTaskImage(String publicUrl) async {
  final uri = Uri.parse(publicUrl);
  // URL format: .../storage/v1/object/public/task-images/schoolId/filename.ext
  final segments = uri.pathSegments;
  final bucketIndex = segments.indexOf('task-images');
  if (bucketIndex < 0 || bucketIndex + 2 >= segments.length) return;

  final storagePath = segments.sublist(bucketIndex + 1).join('/');
  try {
    await Supabase.instance.client.storage
        .from('task-images')
        .remove([storagePath]);
  } catch (_) {
    // Best-effort deletion — don't block the UI
  }
}

/// Upload raw bytes (for programmatic use, e.g. banner images).
Future<ImageUploadResult> uploadImageBytes({
  required String schoolId,
  required Uint8List bytes,
  required String fileName,
  String? mimeType,
}) async {
  if (bytes.length > _maxFileSize) {
    return ImageUploadResult(
      error: 'Image is too large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB). Maximum is 2MB.',
    );
  }

  final ext = _extensionFromName(fileName);
  final storagePath = '$schoolId/${const Uuid().v4()}.$ext';

  try {
    await Supabase.instance.client.storage
        .from('task-images')
        .uploadBinary(storagePath, bytes, fileOptions: FileOptions(
          contentType: mimeType ?? 'image/$ext',
        ));

    final publicUrl = Supabase.instance.client.storage
        .from('task-images')
        .getPublicUrl(storagePath);

    return ImageUploadResult(publicUrl: publicUrl);
  } catch (e) {
    return ImageUploadResult(error: 'Upload failed: $e');
  }
}

String _extensionFromName(String name) {
  final dot = name.lastIndexOf('.');
  if (dot < 0) return 'jpg';
  final ext = name.substring(dot + 1).toLowerCase();
  if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) return ext;
  return 'jpg';
}
