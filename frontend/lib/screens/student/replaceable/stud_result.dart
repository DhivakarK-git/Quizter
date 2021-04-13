import 'package:flutter/material.dart';

class StudResult extends StatefulWidget {
  StudResult({Key key}) : super(key: key);

  @override
  _StudResultState createState() => _StudResultState();
}

class _StudResultState extends State<StudResult> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Result from widget"),
    );
  }
}
