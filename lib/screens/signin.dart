import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../others/color.dart';
import '../others/reusable.dart';
import '../screens/home.dart';
import '../screens/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/image/logo.png"),
                SizedBox(height: 30),
                reusableTextField(
                  "Enter Email Id",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                SizedBox(height: 20),
                signInSignUpButton(context, true, _signInWithEmailAndPassword),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInWithEmailAndPassword() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: _emailTextController.text.trim(),
      password: _passwordTextController.text.trim(),
    )
        .then((value) async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update last sign-in time
        DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        DocumentSnapshot docSnapshot = await userDoc.get();
        if (docSnapshot.exists) {
          userDoc.update({
            'lastSignIn': Timestamp.now(),
          });
        }

        // Clear text fields
        _emailTextController.clear();
        _passwordTextController.clear();

        print("Logged in");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }).catchError((error) {
      print("Error ${error.toString()}");
      _showErrorDialog(context, error.toString());
    });
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.black87),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUp()),
            );
          },
          child: const Text(
            " Sign Up",
            style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sign In Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
