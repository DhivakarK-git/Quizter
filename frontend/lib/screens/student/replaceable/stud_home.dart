import 'package:flutter/material.dart';

class StudHome extends StatefulWidget {
  StudHome({Key key}) : super(key: key);

  @override
  _StudHomeState createState() => _StudHomeState();
}

class _StudHomeState extends State<StudHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Home from widget"),
    );
  }
}
