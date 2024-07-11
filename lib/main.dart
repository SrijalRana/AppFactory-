import 'package:brainbuzz/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyC-sv4NHs4mdHLLjGVv4cHCkDrQHtBPIeE",
        authDomain: "brainbuzz-66f5f.firebaseapp.com",
        databaseURL: "https://brainbuzz-66f5f-default-rtdb.firebaseio.com",
        projectId: "brainbuzz-66f5f",
        storageBucket: "brainbuzz-66f5f.appspot.com",
        messagingSenderId: "328001802341",
        appId: "1:328001802341:web:446cf85b8f54def603b68c",
        measurementId: "G-49M4FD1HVF"));
  }else
    await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
