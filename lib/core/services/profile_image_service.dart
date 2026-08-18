import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user is signed in.');

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 88,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final contentType = _contentType(file.name);
    final ref = FirebaseStorage.instance.ref('users/${user.uid}/profile_image');

    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'profileImageUrl': url},
      SetOptions(merge: true),
    );

    return url;
  }

  static String _contentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
