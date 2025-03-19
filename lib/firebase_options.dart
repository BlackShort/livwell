import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApgv32VFo9qZ9piX2Xf1RnOUxpSfm7Tug',
    appId: '1:96937746430:android:3e5a4694c88df4862aeaaf',
    messagingSenderId: '96937746430',
    projectId: 'livwell-3653d',
    storageBucket: 'livwell-3653d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASizLUqKaZv5doQwH3ShQ38lhsS7pcmZc',
    appId: '1:96937746430:ios:30a04c01f291a3fb2aeaaf',
    messagingSenderId: '96937746430',
    projectId: 'livwell-3653d',
    storageBucket: 'livwell-3653d.firebasestorage.app',
    androidClientId: '96937746430-r95v4avrjgelf0682mik3u6ff0q4qb6n.apps.googleusercontent.com',
    iosClientId: '96937746430-d0gf6lie8kpe5ug7amrrc5068ear8bbm.apps.googleusercontent.com',
    iosBundleId: 'com.livwell.app',
  );
}
