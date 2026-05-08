import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey:
          'AIzaSyCwnv6DfbUN12c_nID8Uy5GBbRIQbPcN8A', // Get from google-services.json
      appId:
          '1:1089015540051:android:9cd36b0097f1a60c8d99a6', // From your screenshot
      messagingSenderId: '1089015540051', // This is the project number
      projectId: 'ugandapris', // This might be correct
      storageBucket: 'ugandapris.appspot.com',
    );
  }
}
