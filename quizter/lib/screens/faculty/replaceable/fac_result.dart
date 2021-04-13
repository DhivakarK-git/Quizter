import 'package:flutter/material.dart';

class FacResult extends StatefulWidget {
  FacResult({Key key}) : super(key: key);

  @override
  _FacResultState createState() => _FacResultState();
}

class _FacResultState extends State<FacResult> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Result from widget"),
    );
  }
}
