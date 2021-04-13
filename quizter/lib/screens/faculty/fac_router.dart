import 'package:flutter/material.dart';
import 'package:quizter/screens/faculty/replaceable/fac_home.dart';
import 'package:quizter/screens/faculty/replaceable/fac_quiz.dart';
import 'package:quizter/screens/faculty/replaceable/fac_course.dart';
import 'package:quizter/screens/faculty/replaceable/fac_result.dart';
import 'package:quizter/screens/faculty/replaceable/add_quiz.dart';

class FacRouter {
  static Widget getRoute(int index, Function goback) {
    switch (index) {
      case 0:
        {
          return FacHome();
        }
        break;
      case 1:
        {
          return FacCourse();
        }
        break;
      case 2:
        {
          return FacQuiz();
        }
        break;
      case 3:
        {
          return FacResult();
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
