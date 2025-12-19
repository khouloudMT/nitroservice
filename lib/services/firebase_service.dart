import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/booking_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User actuel
  User? get currentUser => _auth.currentUser;

  // Stream de l'utilisateur
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription
  Future<UserCredential> signUp(String email, String password, String name, String? phone) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Créer document utilisateur
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Connexion
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer profil utilisateur
  Future<UserModel?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Créer réservation
  Future<String> createBooking(BookingModel booking) async {
    try {
      print('Firebase: Creating booking with data: ${booking.toMap()}');
      DocumentReference ref = await _firestore.collection('bookings').add(booking.toMap());
      print('Firebase: Booking saved with ID: ${ref.id}');
      return ref.id;
    } catch (e) {
      print(' Firebase: Error saving booking: $e');
      rethrow;
    }
  }

  // Stream des réservations utilisateur
  Stream<List<BookingModel>> getUserBookings(String userId) {
    print(' Querying Firestore for bookings where userId = $userId');
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Firestore returned ${snapshot.docs.length} documents');
      final bookings = snapshot.docs.map((doc) {
        print('   - Doc ID: ${doc.id}');
        return BookingModel.fromFirestore(doc);
      }).toList();
      return bookings;
    });
  }

  // Annuler réservation
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  // Mettre à jour profil
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final storageRef = _storage.ref().child('profiles/$userId/profile.jpg');
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }
}