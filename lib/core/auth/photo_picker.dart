import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the person choose a photo. A separate class so tests can replace it.
abstract interface class PhotoPicker {
  /// Returns the chosen photo as JPEG bytes, or null if nothing was chosen.
  Future<Uint8List?> pickFromGallery();
}

/// Opens the phone's gallery. The photo is shrunk to at most 512 x 512 so it is small
/// enough to keep on the phone and to upload on a slow connection.
class GalleryPhotoPicker implements PhotoPicker {
  const GalleryPhotoPicker();

  @override
  Future<Uint8List?> pickFromGallery() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file == null) {
      return null;
    }
    return file.readAsBytes();
  }
}

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => const GalleryPhotoPicker(),
);
