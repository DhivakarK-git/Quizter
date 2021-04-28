import 'package:flutter_test/flutter_test.dart';
import 'package:quizter/screens/student/replaceable/quiz_screen.dart';
import 'package:quizter/screens/faculty/replaceable/add_quiz.dart';
import 'package:quizter/screens/student/replaceable/stud_quiz.dart';

void main() {
  group('change_date', () {
    StudQuiz a = new StudQuiz();
    test('When date is before 18:30 expect same day', () {
      String testFunction =
          a.createState().changedate(DateTime(2021, 1, 1, 0, 0).toString());
      expect(testFunction, DateTime(2021, 1, 1, 5, 30).toString());
    });
    test('When date is after 18:30 expect next day', () {
      String testFunction =
          a.createState().changedate(DateTime(2021, 1, 1, 23, 59).toString());
      expect(testFunction, DateTime(2021, 1, 2, 5, 29).toString());
    });
    test('When date is exactly 18:29 expect same day', () {
      String testFunction =
          a.createState().changedate(DateTime(2021, 1, 1, 18, 29).toString());
      expect(testFunction, DateTime(2021, 1, 1, 23, 59).toString());
    });
    test('When date is exactly 18:31 expect next day', () {
      String testFunction =
          a.createState().changedate(DateTime(2021, 1, 1, 18, 31).toString());
      expect(testFunction, DateTime(2021, 1, 2, 0, 1).toString());
    });
    test(
        'When time is in almost afternoon expect time to be afternoon in 24-hr format',
        () {
      String testFunction =
          a.createState().changedate(DateTime(2021, 1, 1, 10, 0).toString());
      expect(testFunction, DateTime(2021, 1, 1, 15, 30).toString());
    });
  });

  group('validate_date', () {
    StudQuiz a = new StudQuiz();
    test('When date is before 7 days of current date expect True', () {
      bool testFunction = a
          .createState()
          .valDate(DateTime.now().add(Duration(days: 2)).toString());
      expect(testFunction, true);
    });
    test('When date is after 7 days of current date expect False', () {
      bool testFunction = a
          .createState()
          .valDate(DateTime.now().add(Duration(days: 8)).toString());
      expect(testFunction, false);
    });
    test('When date is exact same day as current date expect True', () {
      bool testFunction = a.createState().valDate(DateTime.now().toString());
      expect(testFunction, true);
    });
    test('When date before 4 days of current date expect false', () {
      bool testFunction = a
          .createState()
          .valDate(DateTime.now().subtract(Duration(days: 4)).toString());
      expect(testFunction, false);
    });
    test('When date before 7 days of current date expect false', () {
      bool testFunction = a
          .createState()
          .valDate(DateTime.now().subtract(Duration(days: 7)).toString());
      expect(testFunction, false);
    });
    test('When date is exactly 7 days from current date expect true', () {
      bool testFunction = a
          .createState()
          .valDate(DateTime.now().add(Duration(days: 7)).toString());
      expect(testFunction, true);
    });
  });

  group('validate_time', () {
    StudQuiz a = new StudQuiz();
    test('When Date is in YY-MM-DD format expect DD-MM-YY format', () {
      String testFunction =
          a.createState().parseDate(DateTime(2021, 1, 1).toString());
      expect(testFunction, "01-01-2021");
    });
    test('When time is before start time expect False', () {
      bool testFunction = a.createState().valTime(DateTime.now().toString(),
          DateTime.now().add(Duration(hours: 5)).toString());
      expect(testFunction, false);
    });
    test('When time is in range of start time and end time expect True', () {
      bool testFunction = a.createState().valTime(
          DateTime.now().subtract(Duration(hours: 8, minutes: 30)).toString(),
          DateTime.now().toString());
      expect(testFunction, true);
    });

    test('When time is after end time expect False', () {
      bool testFunction = a.createState().valTime(
          DateTime.now().subtract(Duration(hours: 10, minutes: 30)).toString(),
          DateTime.now().subtract(Duration(hours: 8, minutes: 30)).toString());
      expect(testFunction, false);
    });

    test('When time is exactly start time expect True', () {
      bool testFunction = a.createState().valTime(
          DateTime.now().subtract(Duration(hours: 5, minutes: 30)).toString(),
          DateTime.now().add(Duration(hours: 5)).toString());
      expect(testFunction, true);
    });
    test('When time is exactly end time expect True', () {
      bool testFunction = a.createState().valTime(
          DateTime.now().subtract(Duration(hours: 8, minutes: 30)).toString(),
          DateTime.now().subtract(Duration(hours: 5, minutes: 30)).toString());
      expect(testFunction, true);
    });
  });
  group('parse_date', () {
    StudQuiz a = new StudQuiz();
    test('When Date is in YY-MM-DD format expect DD-MM-YY format', () {
      String testFunction =
          a.createState().parseDate(DateTime(2021, 1, 1).toString());
      expect(testFunction, "01-01-2021");
    });
    test('When Date is in YY-MM-DD format expect DD-MM-YY format', () {
      String testFunction =
          a.createState().parseDate(DateTime(2020, 7, 7).toString());
      expect(testFunction, "07-07-2020");
    });
  });

  group('parse_time', () {
    StudQuiz a = new StudQuiz();
    test('When time is before 12:00 expect AM in 12 hour format', () {
      String testFunction = a.createState().parseTime(
          DateTime(2021, 1, 1, 6, 50)
              .subtract(Duration(hours: 5, minutes: 30))
              .toString());
      expect(testFunction, "06:50 AM");
    });

    test('When time is 12:00 expect PM in 12 hour format', () {
      String testFunction = a.createState().parseTime(
          DateTime(2021, 1, 1, 12, 0)
              .subtract(Duration(hours: 5, minutes: 30))
              .toString());
      expect(testFunction, "12:00 PM");
    });
    test('When time is 00:00 expect 12:00 AM in 12 hour format', () {
      String testFunction = a.createState().parseTime(DateTime(2021, 1, 1, 0, 0)
          .subtract(Duration(hours: 5, minutes: 30))
          .toString());
      expect(testFunction, "12:00 AM");
    });
    test('When time is after 12:00 expect PM in 12 hour format', () {
      String testFunction = a.createState().parseTime(
          DateTime(2021, 1, 1, 18, 39)
              .subtract(Duration(hours: 5, minutes: 30))
              .toString());
      expect(testFunction, "06:39 PM");
    });
    test('When time after 00:00 expect AM in 12 hour format', () {
      String testFunction = a.createState().parseTime(
          DateTime(2021, 1, 1, 1, 40)
              .subtract(Duration(hours: 5, minutes: 30))
              .toString());
      expect(testFunction, "01:40 AM");
    });
    test(
        'When time is after 12:00 and less than 13:00 expect PM in 12 hour format',
        () {
      String testFunction = a.createState().parseTime(
          DateTime(2021, 1, 1, 12, 39)
              .subtract(Duration(hours: 5, minutes: 30))
              .toString());
      expect(testFunction, "12:39 PM");
    });
  });

  group('confirm_time', () {
    test('When there is sufficient time expect full duration', () {
      DateTime t = DateTime.now();
      QuizScreen a = new QuizScreen(
          1, "Quiztertest", t.toString().substring(0, 16), () {}, () {}, () {});

      int testFunction = a.createState().confirmTime(
          15,
          t
              .add(Duration(minutes: 40))
              .subtract(Duration(hours: 5, minutes: 30))
              .toString()
              .substring(0, 16));
      expect(testFunction,
          t.add(Duration(minutes: 15)).difference(DateTime.now()).inSeconds);
    });

    test('When time is  exactly sufficient expect full duration', () {
      DateTime t = DateTime.now();
      QuizScreen a = new QuizScreen(
          1, "Quiztertest", t.toString().substring(0, 16), () {}, () {}, () {});

      int testFunction = a.createState().confirmTime(
          20,
          t
              .add(Duration(minutes: 25))
              .subtract(Duration(hours: 5, minutes: 30))
              .toString()
              .substring(0, 16));
      expect(testFunction,
          t.add(Duration(minutes: 20)).difference(DateTime.now()).inSeconds);
    });

    test('When time is sufficient expect full duration', () {
      DateTime t = DateTime.now();
      QuizScreen a = new QuizScreen(
          1, "Quiztertest", t.toString().substring(0, 16), () {}, () {}, () {});

      int testFunction = a.createState().confirmTime(
          10,
          t
              .add(Duration(minutes: 50))
              .subtract(Duration(hours: 5, minutes: 30))
              .toString()
              .substring(0, 16));
      expect(testFunction,
          t.add(Duration(minutes: 10)).difference(DateTime.now()).inSeconds);
    });

    test('When time is not sufficient expect less duration', () {
      DateTime t = DateTime.now();
      QuizScreen a = new QuizScreen(
          1, "Quiztertest", t.toString().substring(0, 16), () {}, () {}, () {});

      int testFunction = a.createState().confirmTime(
          5,
          t
              .add(Duration(minutes: 6))
              .subtract(Duration(hours: 5, minutes: 30))
              .toString()
              .substring(0, 16));
      expect(testFunction,
          t.add(Duration(minutes: 5)).difference(DateTime.now()).inSeconds);
    });
  });

  group('random_string', () {
    AddQuiz a = new AddQuiz(() {});
    test('When there is sufficient time expect full duration', () {
      String testFunction = a.createState().getRandomString(20);
      expect(testFunction.length, 20);
    });
  });
}
