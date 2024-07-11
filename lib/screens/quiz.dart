import 'package:brainbuzz/others/color.dart'; // Ensure this import is present
import 'package:brainbuzz/screens/result.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  final String topic;
  final String gameId;
  final String playerId;
  final String playerType;

  QuizScreen({
    required this.topic,
    required this.gameId,
    required this.playerId,
    required this.playerType,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  String? selectedAnswer;
  String? errorMessage;
  late Timer _timer;
  int _countDown = 10;
  int player1Score = 0;
  int player2Score = 0;
  List<String?> userAnswers = [];
  List<String?> player1Answers = [];
  List<String?> player2Answers = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    try {
      DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance.collection('games').doc(widget.gameId).get();
      if (gameSnapshot.exists) {
        Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;
        questions = List<Map<String, dynamic>>.from(gameData['questions']);
        setState(() {
          isLoading = false;
        });
        startTimer();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Game not found.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching questions: $e';
      });
      print('Error fetching questions: $e');
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countDown > 0) {
        setState(() {
          _countDown--;
        });
      } else {
        timer.cancel();
        handleTimeout();
      }
    });
  }

  void handleTimeout() {
    setState(() {
      selectedAnswer = null;
    });
    nextQuestion();
  }

  void selectAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
    });

    if (widget.playerType == 'player1') {
      player1Answers.add(answer);
    } else {
      player2Answers.add(answer);
    }

    // Save the answer to Firestore
    await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
      '${widget.playerType}Answers': FieldValue.arrayUnion([answer]),
    });

    _timer.cancel();
    nextQuestion();
  }

  void nextQuestion() async {
    bool isCorrect = selectedAnswer == questions[currentQuestionIndex]['answer'];

    if (widget.playerType == 'player1') {
      if (isCorrect) player1Score++;
      await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
        'player1Score': player1Score,
      });
    } else {
      if (isCorrect) player2Score++;
      await FirebaseFirestore.instance.collection('games').doc(widget.gameId).update({
        'player2Score': player2Score,
      });
    }

    // Proceed to the next question or finish quiz
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null; // Reset selected answer for the next question
        _countDown = 10; // Reset the countdown for each question
      });
      startTimer();
    } else {
      // Check if both players have completed the quiz
      DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance.collection('games').doc(widget.gameId).get();
      Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

      bool player1Finished = gameData['player1Answers'].length == questions.length;
      bool player2Finished = gameData['player2Answers'].length == questions.length;

      if (player1Finished && player2Finished) {
        navigateToResultsScreen();
      } else {
        // Show message or handle the case where both players haven't finished
        print('Both players have not finished the quiz yet.');
      }
    }
  }

  Future<void> navigateToResultsScreen() async {
    DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance.collection('games').doc(widget.gameId).get();
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;

    List<String?> player1AnswersFromDb = List<String?>.from(gameData['player1Answers']);
    List<String?> player2AnswersFromDb = List<String?>.from(gameData['player2Answers']);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          player1Score: player1Score,
          player2Score: player2Score,
          totalQuestions: questions.length,
          questions: questions,
          player1Answers: player1AnswersFromDb,
          player2Answers: player2AnswersFromDb,
          playerId: widget.playerId,
          gameId: widget.gameId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: Text(errorMessage!)),
      );
    }

    var currentQuestion = questions[currentQuestionIndex];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: hexStringToColor("ff99ff"),
        scaffoldBackgroundColor: Colors.white,
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
      ),
      home: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(); // Navigate back to the previous screen (waiting screen)
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Quiz'),
            backgroundColor: hexStringToColor("7700b3"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}/${questions.length}',
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hexStringToColor("c44dff"),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentQuestion['question'],
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                for (var option in currentQuestion['options'])
                  GestureDetector(
                    onTap: () => selectAnswer(option),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: selectedAnswer == option
                            ? Colors.blueAccent
                            : hexStringToColor("ff99ff"),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Spacer(),
                Text(
                  'Time left: $_countDown seconds',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: selectedAnswer != null ? nextQuestion : null,
                  child: Text(
                    currentQuestionIndex < questions.length - 1
                        ? 'Next Question'
                        : 'Finish Quiz',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
