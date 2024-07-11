import 'package:brainbuzz/others/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainbuzz/screens/home.dart';

class ResultsScreen extends StatelessWidget {
  final int player1Score;
  final int player2Score;
  final String playerId;
  final String gameId;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final List<String?> player1Answers;
  final List<String?> player2Answers;

  ResultsScreen({
    required this.player1Score,
    required this.player2Score,
    required this.totalQuestions,
    required this.questions,
    required this.player1Answers,
    required this.player2Answers,
    required this.playerId,
    required this.gameId,
  });

  Future<Map<String, int>> fetchScores() async {
    DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance.collection('games').doc(gameId).get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    return {
      'player1Score': gameData['player1Score'],
      'player2Score': gameData['player2Score'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: fetchScores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Results'),
              backgroundColor: hexStringToColor("ff99ff"),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Results'),
              backgroundColor: hexStringToColor("ff99ff"),
            ),
            body: Center(child: Text('Error loading results')),
          );
        }

        int? player1Score = snapshot.data!['player1Score'];
        int? player2Score = snapshot.data!['player2Score'];

        return Scaffold(
          appBar: AppBar(
            title: Text('Results'),
            backgroundColor: hexStringToColor("ff99ff"),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Player 1 Score: $player1Score / $totalQuestions',
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Player 2 Score: $player2Score / $totalQuestions',
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        var question = questions[index];
                        var player1Answer = player1Answers[index] ?? 'No answer';
                        var player2Answer = player2Answers[index] ?? 'No answer';
                        var correctAnswer = question['answer'];

                        return Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Question ${index + 1}: ${question['question']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Player 1 Answer: $player1Answer',
                                  style: TextStyle(
                                    color: player1Answer == correctAnswer ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Player 2 Answer: $player2Answer',
                                  style: TextStyle(
                                    color: player2Answer == correctAnswer ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Correct Answer: $correctAnswer',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hexStringToColor("ff99ff"),
                    ),
                    child: Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
