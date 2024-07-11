import 'package:brainbuzz/others/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainbuzz/screens/quiz.dart';

class JoinRoomScreen extends StatefulWidget {
  final String topic;

  const JoinRoomScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  String error = '';
  String? gameId;
  bool joining = false;

  void joinRoom() async {
    String roomCode = _roomCodeController.text.trim();
    setState(() {
      joining = true;
      error = '';
    });

    try {
      QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
          .collection('games')
          .where('roomCode', isEqualTo: roomCode)
          .limit(1)
          .get();

      if (roomSnapshot.docs.isNotEmpty) {
        DocumentSnapshot roomDoc = roomSnapshot.docs.first;

        await roomDoc.reference.update({
          'player2': FirebaseAuth.instance.currentUser!.uid,
        });

        setState(() {
          gameId = roomDoc.id;
        });
      } else {
        setState(() {
          error = 'Room not found';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error joining room: $e';
      });
    } finally {
      setState(() {
        joining = false;
      });
    }
  }

  Widget buildUserProfile(String userId, String label) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Text('$label: Loading...');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          '$label: ${userData['name'] ?? 'Unknown'}',
          style: TextStyle(fontSize: 20),
        );
      },
    );
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
            foregroundColor: Colors.white, backgroundColor: Colors.black,
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(color: hexStringToColor("ff99ff")),
          ),
          labelStyle: TextStyle(color: Colors.black, fontSize: 20), // Increased size
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Join Room'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add space between label and text field
                      child: Text(
                        'Enter Room Code',
                        style: TextStyle(fontSize: 24, color: Colors.black), // Increased size
                      ),
                    ),
                  ),
                  TextField(
                    controller: _roomCodeController,
                    decoration: InputDecoration(
                      errorText: error.isNotEmpty ? error : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  joining
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: joinRoom,
                    child: Text('Join Room'),
                  ),
                  if (gameId != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('games').doc(gameId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('Waiting for data...');
                        }

                        var gameData = snapshot.data!.data() as Map<String, dynamic>;
                        var player1Id = gameData['player1'];
                        var player2Id = gameData['player2'];
                        bool quizStarted = gameData['quizStarted'];

                        if (quizStarted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  gameId: gameId!,
                                  playerId: FirebaseAuth.instance.currentUser!.uid,
                                  topic: widget.topic,
                                  playerType: 'player2',
                                ),
                              ),
                            );
                          });
                        }

                        return Column(
                          children: [
                            buildUserProfile(player1Id, 'Player 1'),
                            SizedBox(height: 10),
                            buildUserProfile(player2Id, 'Player 2'),
                            if (!quizStarted) Text('Waiting for User 1 to start the quiz...', style: TextStyle(fontSize: 20)),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
