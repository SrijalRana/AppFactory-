import 'package:brainbuzz/others/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainbuzz/screens/room.dart';
import 'package:brainbuzz/screens/joinroom.dart';

class WaitingScreen extends StatefulWidget {
  final String topic;

  const WaitingScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late String playerName;

  @override
  void initState() {
    super.initState();
    fetchPlayerName();
  }

  void fetchPlayerName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userSnapshot.exists) {
          setState(() {
            playerName = userSnapshot['name'];
          });
        } else {
          print('User profile not found.');
        }
      } else {
        print('User not authenticated.');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: hexStringToColor("ff99ff"),
        scaffoldBackgroundColor: hexStringToColor("7700b3"),
        appBarTheme: AppBarTheme(
          backgroundColor: hexStringToColor("ff99ff"),
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Play with Friend'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringToColor("ff99ff"),
                hexStringToColor("c44dff"),
                hexStringToColor("7700b3"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selected Topic: ${widget.topic}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateRoomScreen(topic: widget.topic,),
                      ),
                    );
                  },
                  child: Text('Create Room'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JoinRoomScreen(topic: widget.topic),
                      ),
                    );
                  },
                  child: Text('Join Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
