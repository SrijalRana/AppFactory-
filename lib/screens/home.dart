import 'package:brainbuzz/screens/waiting.dart';
import 'package:flutter/material.dart';
import 'package:brainbuzz/others/color.dart';
import 'package:brainbuzz/others/reusable.dart';
import 'package:brainbuzz/screens/profile.dart';
import 'package:brainbuzz/others/gradient_button.dart';
import 'package:flutter/services.dart'; // Import this to use SystemNavigator

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final List<ButtonData> buttonDataList = [
    ButtonData(text: 'GK', imagePath: 'assets/image/gk.png'),
    ButtonData(text: 'Geography', imagePath: 'assets/image/geo.png'),
    ButtonData(text: 'History', imagePath: 'assets/image/history.png'),
    ButtonData(text: 'Movies', imagePath: 'assets/image/movies.png'),
    ButtonData(text: 'Animals', imagePath: 'assets/image/animals.png'),
    ButtonData(text: 'Technology', imagePath: 'assets/image/tech.png'),
    ButtonData(text: 'Cars', imagePath: 'assets/image/cars.png'),
    ButtonData(text: 'Sports', imagePath: 'assets/image/sports.png'),
    ButtonData(text: 'Maths', imagePath: 'assets/image/maths.png'),

  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Home",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigate to profile screen without userId
                  );
                },
                child: Image.asset(
                  'assets/image/profile.png', // Replace with your image path
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
            ),
            ClipPath(
              clipper: CurvedClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.35,
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
                    padding: const EdgeInsets.only(top: 55.0),
                    child: logoWidget("assets/image/logo.png"),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.25,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: buttonDataList.length,
                  itemBuilder: (context, index) {
                    final buttonData = buttonDataList[index];
                    return GradientButton(
                      text: buttonData.text,
                      imagePath: buttonData.imagePath,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WaitingScreen(topic: buttonData.text),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
