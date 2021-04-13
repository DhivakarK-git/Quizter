import 'package:flutter/material.dart';

class FacHome extends StatefulWidget {
  FacHome({Key key}) : super(key: key);

  @override
  _FacHomeState createState() => _FacHomeState();
}

class _FacHomeState extends State<FacHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Home from widget"),
    );
  }
}
