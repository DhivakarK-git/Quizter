import 'package:flutter/material.dart';
import 'package:quizter/screens/student/replaceable/stud_home.dart';
import 'package:quizter/screens/student/replaceable/stud_quiz.dart';
import 'package:quizter/screens/student/replaceable/stud_course.dart';
import 'package:quizter/screens/student/replaceable/stud_result.dart';

class StudRouter {
  static Widget getRoute(int index,String username,String firstname,String lastname) {
    switch (index) {
      case 0:
        {
          return StudHome();
        }
        break;
      case 1:
        {
          return StudCourse(username,firstname,lastname);
        }
        break;
      case 2:
        {
          return StudQuiz();
        }
        break;
      case 3:
        {
          return StudResult();
        }
        break;
      default:
        {
          return StudHome();
        }
    }
  }
}
