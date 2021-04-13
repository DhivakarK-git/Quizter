import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/screens/login_screen.dart';
import 'package:flutter/animation.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween(begin: 216.0, end: 108.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          Timer(
              Duration(milliseconds: 1008),
              () async => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 694),
                    pageBuilder: (_, __, ___) => LoginScreen(694),
                  )));
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kQuiz,
      body: Stack(
        children: [
          Hero(
            tag: 'matte',
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: kMatte,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset(
                      "images/login.png",
                      height: MediaQuery.of(context).size.height -
                          animation.value * 1.5,
                      width: MediaQuery.of(context).size.width -
                          animation.value * 1.5,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 400,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 10),
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kGlacier),
                  backgroundColor: kMatte,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
