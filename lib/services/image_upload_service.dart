import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  // Compress image to reduce size using dart image package
  Future<Uint8List?> compressImage(File file) async {
    try {
      // Read image file
      final bytes = await file.readAsBytes();
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Resize image to max 512x512 while maintaining aspect ratio
      img.Image resized = img.copyResize(
        image,
        width: image.width > 512 ? 512 : null,
        height: image.height > 512 ? 512 : null,
      );
      
      // Compress as JPEG with quality 70
      final compressed = img.encodeJpg(resized, quality: 70);
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // Convert image to Base64 string
  Future<String?> imageToBase64(File imageFile) async {
    try {
      // Compress image first
      final compressed = await compressImage(imageFile);
      
      if (compressed == null) {
        // Fallback to original if compression fails
        final bytes = await imageFile.readAsBytes();
        
        // Check size before encoding
        final sizeInKB = bytes.length / 1024;
        if (sizeInKB > 700) {
          print('Original image too large: ${sizeInKB.toStringAsFixed(2)} KB');
          return null;
        }
        
        return base64Encode(bytes);
      }
      
      // Check compressed size
      final sizeInKB = compressed.length / 1024;
      print('Compressed image size: ${sizeInKB.toStringAsFixed(2)} KB');
      
      if (sizeInKB > 700) {
        print('Compressed image still too large');
        return null;
      }
      
      return base64Encode(compressed);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // Save profile picture to Firestore (as base64)
  // Note: Firestore has a 1MB document size limit, so we compress heavily
  Future<bool> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final base64Image = await imageToBase64(imageFile);
      
      if (base64Image == null) {
        return false;
      }

      // Check size (Firestore has ~1MB limit per document)
      // Base64 is ~33% larger than original, so we aim for < 700KB compressed
      final sizeInBytes = base64Image.length;
      final sizeInKB = sizeInBytes / 1024;
      
      print('Final base64 size: ${sizeInKB.toStringAsFixed(2)} KB');
      
      if (sizeInKB > 800) {
        print('Error: Image too large for Firestore');
        return false;
      }

      // Save to Firestore user document
      await _firestore.collection('users').doc(userId).update({
        'profilePictureBase64': base64Image,
        'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }

  // Alternative: Save to separate collection for better organization
  Future<bool> uploadProfilePictureToCollection(String userId, File imageFile) async {
    try {
      final base64Image = await imageToBase64(imageFile);
      
      if (base64Image == null) {
        return false;
      }

      // Check size
      final sizeInBytes = base64Image.length;
      final sizeInKB = sizeInBytes / 1024;
      
      print('Image size: ${sizeInKB.toStringAsFixed(2)} KB');
      
      if (sizeInKB > 800) {
        print('Error: Image too large for Firestore');
        return false;
      }

      // Save to separate collection
      await _firestore.collection('profile_pictures').doc(userId).set({
        'imageBase64': base64Image,
        'uploadedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      // Update user document with reference
      await _firestore.collection('users').doc(userId).update({
        'hasProfilePicture': true,
        'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }

  // Get profile picture from Firestore
  Future<String?> getProfilePicture(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return doc.data()?['profilePictureBase64'];
      }
      return null;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  // Alternative: Get from separate collection
  Future<String?> getProfilePictureFromCollection(String userId) async {
    try {
      final doc = await _firestore.collection('profile_pictures').doc(userId).get();
      
      if (doc.exists) {
        return doc.data()?['imageBase64'];
      }
      return null;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profilePictureBase64': FieldValue.delete(),
        'profilePictureUpdatedAt': FieldValue.delete(),
      });
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Alternative: Delete from separate collection
  Future<bool> deleteProfilePictureFromCollection(String userId) async {
    try {
      await _firestore.collection('profile_pictures').doc(userId).delete();
      
      await _firestore.collection('users').doc(userId).update({
        'hasProfilePicture': false,
      });
      
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Show image source dialog
  Future<File?> showImageSourceDialog(context) async {
    return await showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galerie'),
              onTap: () async {
                final image = await pickImageFromGallery();
                Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Appareil photo'),
              onTap: () async {
                final image = await pickImageFromCamera();
                Navigator.pop(context, image);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

// Helper widget to display base64 image
// Usage: Base64ImageWidget(base64String: user.profilePictureBase64)
class Base64ImageWidget extends StatelessWidget {
  final String? base64String;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const Base64ImageWidget({
    Key? key,
    required this.base64String,
    this.radius = 50,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (base64String == null || base64String!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
        child: Icon(
          fallbackIcon,
          size: radius * 1.2,
          color: Colors.grey,
        ),
      );
    }

    try {
      final bytes = base64Decode(base64String!);
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.transparent,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (e) {
      print('Error decoding base64 image: $e');
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
        child: Icon(
          fallbackIcon,
          size: radius * 1.2,
          color: Colors.grey,
        ),
      );
    }
  }
}