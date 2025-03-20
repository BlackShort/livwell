import 'package:firebase_auth/firebase_auth.dart';

// ✅ Handle Firebase Auth exceptions

String handleAuthException(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Wrong password provided.';
    case 'email-already-in-use':
      return 'The email address is already in use.';
    case 'invalid-email':
      return 'The email address is invalid.';
    case 'weak-password':
      return 'The password is too weak.';
    case 'operation-not-allowed':
      return 'This sign-in method is not allowed. Please contact support.';
    case 'user-disabled':
      return 'This user has been disabled. Please contact support.';
    case 'too-many-requests':
      return 'Too many requests. Try again later.';
    case 'network-request-failed':
      return 'A network error occurred. Check your connection.';
    default:
      return 'An error occurred: ${exception.message}';
  }
}
