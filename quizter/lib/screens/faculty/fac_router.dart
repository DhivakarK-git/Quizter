import 'package:flutter/material.dart';
import 'package:quizter/screens/faculty/replaceable/fac_home.dart';
import 'package:quizter/screens/faculty/replaceable/fac_quiz.dart';
import 'package:quizter/screens/faculty/replaceable/fac_course.dart';
import 'package:quizter/screens/faculty/replaceable/fac_result.dart';
import 'package:quizter/screens/faculty/replaceable/add_quiz.dart';

class FacRouter {
  static Widget getRoute(int index, Function goback,String username,String firstname,String lastname) {
    switch (index) {
      case 0:
        {
          return FacHome();
        }
        break;
      case 1:
        {
          return FacCourse(username,firstname,lastname);
        }
        break;
      case 2:
        {
          return FacQuiz();
        }
        break;
      case 3:
        {
          return FacResult(username,firstname,lastname);
        }
        break;
      case 4:
        {
          return AddQuiz(goback);
        }
        break;
      default:
        {
          return FacHome();
        }
    }
  }
}
