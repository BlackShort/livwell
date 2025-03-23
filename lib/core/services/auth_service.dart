import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/core/errors/auth_exceptions.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Authentication state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // Email & Password Sign Up
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.toString()}');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw handleAuthException(e);
    }
  }

  // Update User Display Name
  Future<void> updateUserDisplayName(User user, String displayName) async {
    try {
      await user.updateDisplayName(displayName);
    } catch (e) {
      throw Exception('Failed to update display name: ${e.toString()}');
    }
  }

  // Create User Profile - Improved version with consistent timestamps
  Future<UserModel> createUserProfile(Map<String, dynamic> userData) async {
    try {
      // Always use server timestamp for consistency
      final Map<String, dynamic> sanitizedData = {
        'uid': userData['uid'] ?? '',
        'email': userData['email'] ?? '',
        'firstName': userData['firstName'] ?? '',
        'lastName': userData['lastName'] ?? '',
        'photoUrl': userData['photoUrl'],
        'phone': userData['phone'],
        'createdAt': FieldValue.serverTimestamp(),
        'interests': userData['interests'] ?? [],
        'eventsAttended': userData['eventsAttended'] ?? [],
        'nonprofitsFollowed': userData['nonprofitsFollowed'] ?? [],
        'isProfileComplete': userData['isProfileComplete'] ?? false,
      };

      // Store in Firestore
      await _firestore
          .collection('users')
          .doc(userData['uid'])
          .set(sanitizedData);
      
      // Fetch the document we just created to get the server timestamp
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userData['uid'])
          .get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(docSnapshot.data()!);
      } else {
        // If for some reason we can't fetch, create with local timestamp
        return UserModel(
          uid: userData['uid'] ?? '',
          email: userData['email'] ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          photoUrl: userData['photoUrl'],
          phone: userData['phone'],
          createdAt: DateTime.now(),
          interests: List<String>.from(userData['interests'] ?? []),
          eventsAttended: List<String>.from(userData['eventsAttended'] ?? []),
          nonprofitsFollowed: List<String>.from(userData['nonprofitsFollowed'] ?? []),
          isProfileComplete: userData['isProfileComplete'] ?? false,
        );
      }
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Get User Profile - Improved with better error messaging
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update User Profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
  
  // Helper method for fix timestamps if needed
  Future<void> fixUserProfileTimestamps() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      
      List<Future> updateOperations = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        if (data['createdAt'] == null) {
          updateOperations.add(
            _firestore.collection('users').doc(doc.id).update({
              'createdAt': FieldValue.serverTimestamp(),
            }),
          );
        }
      }
      
      if (updateOperations.isNotEmpty) {
        await Future.wait(updateOperations);
      }
    } catch (e) {
      throw Exception('Failed to fix timestamps: ${e.toString()}');
    }
  }
}