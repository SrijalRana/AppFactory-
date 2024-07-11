import 'package:brainbuzz/others/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<DocumentSnapshot> getUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user signed in');
    }

    // Fetch user data from Firestore using the user's ID
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("c44dff"), // Set appbar background color here
        elevation: 0, // Remove appbar elevation
        title: Text(
          'Your Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Set appbar title text color
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print('No data found for user');
            return Center(child: Text('No data found for user'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          print('User data: $userData');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 100, // Increase size of profile image
                  backgroundImage: AssetImage('assets/image/profile.png'), // Replace with actual profile image
                ),
                SizedBox(height: 20),
                Text(
                  userData['name'] ?? 'Name not available',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  userData['email'] ?? 'Email not available',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
