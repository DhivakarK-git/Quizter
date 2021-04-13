import 'package:flutter/material.dart';

class StudCourse extends StatefulWidget {
  StudCourse({Key key}) : super(key: key);

  @override
  _StudCourseState createState() => _StudCourseState();
}

class _StudCourseState extends State<StudCourse> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Course from widget"),
    );
  }
}
