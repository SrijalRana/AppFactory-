import 'package:brainbuzz/others/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainbuzz/screens/quiz.dart';


class CreateRoomScreen extends StatefulWidget {
  final String topic;

  const CreateRoomScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  late String gameId;
  late String roomCode;
  bool isQuizStarted = false;

  @override
  void initState() {
    super.initState();
    createGame();
  }

  void createGame() async {
    try {
      DocumentReference gameRef = FirebaseFirestore.instance.collection('games').doc();
      gameId = gameRef.id; // Get the game ID after creating the document
      roomCode = gameId.substring(0, 6);

      // Fetch 10 random questions for the selected topic
      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('topic', isEqualTo: widget.topic)
          .get();

      List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(questionSnapshot.docs.first['questions']);
      allQuestions.shuffle(); // Shuffle the questions list
      List<Map<String, dynamic>> selectedQuestions = allQuestions.take(10).toList();

      await gameRef.set({
        'roomCode': roomCode,
        'player1': FirebaseAuth.instance.currentUser!.uid,
        'player2': null,
        'isActive': true,
        'score': {
          'player1': 0,
          'player2': 0,
        },
        'player1Answered': false,
        'player2Answered': false,
        'currentQuestionIndex': 0,
        'topic': widget.topic,
        'createdAt': Timestamp.now(),
        'quizStarted': false,
        'questions': selectedQuestions, // Store selected questions in the game document
      });

      setState(() {
        gameId = gameRef.id;
      });
    } catch (e) {
      print('Error creating game: $e');
      // Handle error creating game document
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
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
          return Text('$label: Loading...');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          '$label: ${userData['name'] ?? 'Unknown'}',
          style: TextStyle(fontSize: 25),
        );
      },
    );
  }

  void startQuiz() async {
    setState(() {
      isQuizStarted = true;
    });

    await FirebaseFirestore.instance.collection('games').doc(gameId).update({
      'quizStarted': true,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          gameId: gameId,
          playerId: FirebaseAuth.instance.currentUser!.uid,
          topic: widget.topic,
          playerType: 'player1',
        ),
      ),
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
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create Room'),
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('games').doc(gameId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
                  return Text('Waiting for data...');
                }

                var gameData = snapshot.data!.data() as Map<String, dynamic>;
                var player1Id = gameData['player1'];
                var player2Id = gameData['player2'];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Room Code: $roomCode',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    buildUserProfile(player1Id, 'Player 1'),
                    SizedBox(height: 10),
                    if (player2Id != null)
                      buildUserProfile(player2Id, 'Player 2'),
                    if (player2Id == null) Text('Waiting for User 2 to join...', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    if (player2Id != null)
                      ElevatedButton(
                        onPressed: startQuiz,
                        child: Text('Start Quiz'),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
