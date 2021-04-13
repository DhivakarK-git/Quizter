import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/widgets/hover_extensions.dart';
import 'package:provider/provider.dart';
import 'package:quizter/graphql/authentication/token.dart';
import 'package:quizter/graphql/authentication/auth_graphql.dart';
import 'package:graphql/client.dart';
import 'quiz_screen.dart';
import 'package:quizter/graphql/graphqueries.dart';
import 'package:animations/animations.dart';

final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
final hoverTransform = Matrix4.identity()..translate(0, -5, 0);

class StudQuiz extends StatefulWidget {
  @override
  _StudQuizState createState() => _StudQuizState();
}

class _StudQuizState extends State<StudQuiz> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var quizset = [], starttime = [];
  bool showquiz = false;
  int quizid = -1, userId = -1, id = -1;
  String quizname = 'ERROR 404';
  void getQuizes() async {
    final QueryResult quiz = await _quiz.queryA(gq.getMeQuiz());
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        elevation: 2,
        backgroundColor: kMatte,
        content: Text(
          'Sorry, we have trouble finding quizzes for you right now. Please try again.',
          style: Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
        ));
    if (quiz.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      try {
        setState(() {
          userId = int.parse(quiz.data['me']['usert']['id']);
          var quizs = quiz.data['me']['usert']['takesSet'][0]['quizzes'];
          for (int i = 0; i < quizs.length; i++) {
            var takers = quizs[i]['takers'];
            var user = [], times = [], start = [];
            for (int j = 0; j < takers.length; j++) {
              user.add(int.parse(takers[j]['user']['id']));
              times.add(takers[j]['timesTaken']);
              start.add(takers[j]['startTime']);
            }
            if (user.contains(userId) &&
                valDate(quizs[i]['startTime']) &&
                times[user.indexOf(userId)] < quizs[i]['timesCanTake']) {
              quizset.add(quizs[i]);
              try {
                starttime.add(changedate(start[user.indexOf(userId)]));
              } catch (e) {
                starttime.add("-1");
              }
            }
          }
        });
      } catch (exception1) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  String changedate(String dt) {
    return DateTime.parse(dt)
        .add(const Duration(hours: 5, minutes: 30))
        .toString();
  }

  bool valDate(String dt) {
    dt = changedate(dt);
    dt = dt.substring(0, 10);
    String d = DateTime.now().toString().substring(0, 10);
    if (dt.substring(5, 7) == d.substring(5, 7)) {
      int dti = int.parse(dt.substring(8));
      int di = int.parse(d.substring(8));
      if (di <= dti && dti <= (di + 7))
        return true;
      else
        return false;
    } else
      return false;
  }

  bool valTime(String dt, String et) {
    dt = changedate(dt);
    et = changedate(et);
    DateTime d = DateTime.parse(DateTime.now().toString().substring(0, 16));
    DateTime s = DateTime.parse(DateTime.parse(dt)
            .subtract(Duration(minutes: 1))
            .toString()
            .substring(0, 16)),
        e = DateTime.parse(DateTime.parse(et)
            .add(Duration(minutes: 1))
            .toString()
            .substring(0, 16));
    return ((e.isAfter(d) && s.isBefore(d)) ? true : false);
  }

  String parseDate(String dt) {
    dt = changedate(dt);
    return (dt.substring(8, 10) + dt.substring(4, 8) + dt.substring(0, 4));
  }

  String parseTime(String t) {
    t = changedate(t);
    t = t.substring(11, 16);
    int p = int.parse(t.substring(0, 2));
    if (p == 12) {
      t = "12" +
          t.substring(
            2,
          ) +
          " PM";
    } else if (p == 0) {
      t = "12" +
          t.substring(
            2,
          ) +
          " AM";
    } else if (p > 12) {
      p = p - 12;
      t = p.toString() +
          t.substring(
            2,
          ) +
          " PM";

      if (p < 10) t = "0" + t;
    } else
      t = t + " AM";
    return t;
  }

  Widget swap() {
    if (showquiz) {
      return QuizScreen(quizid, quizname, starttime[id], () async {
        quizid = -1;
        quizname = '';
        showquiz = false;
        quizset = [];
        getQuizes();
        setState(() {});
      }, () async {
        final QueryResult quiz =
            await _quiz.queryA(gq.updateTimes(userid: userId, quizid: quizid));
        quizid = -1;
        quizname = '';
        showquiz = false;
        quizset = [];
        getQuizes();
        setState(() {});
        Navigator.of(context).pop();
      }, () async {
        final QueryResult quiz =
            await _quiz.queryA(gq.updateTimes(userid: userId, quizid: quizid));
        quizid = -1;
        quizname = '';
        showquiz = false;
        quizset = [];
        getQuizes();
        setState(() {});
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Quiz Submitted',
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: kGlacier),
              ),
              backgroundColor: kMatte,
              content: Text(
                'Your quiz was auto submitted.\n\nNote:\tIn case, the last question you have been working on was a short answer, numerical or fill in the blanks; it may have not been saved.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: kFrost),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OKAY',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: kFrost),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            );
          },
        );
      });
    } else
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 24.0),
                  child: SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Upcoming Quizzes",
                            style: Theme.of(context).textTheme.headline4),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                          ),
                          color: kMatte,
                          tooltip: 'Filter Quizzes',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 208,
                      child: GridView.builder(
                          //TODO: fix card overflow
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 32.0),
                          itemCount: quizset.length,
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount:
                                (MediaQuery.of(context).size.width) ~/ 347,
                            childAspectRatio: 1.729,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return TextButton(
                              onPressed: () async {
                                quizid = int.parse(quizset[index]['id']);
                                quizname = quizset[index]['quizName'];
                                if (valTime(quizset[index]['startTime'],
                                    quizset[index]['endTime'])) {
                                  showquiz = true;
                                  id = index;
                                  if (starttime[index] == "-1") {
                                    String dt = DateTime.now()
                                        .toString()
                                        .substring(0, 16);
                                    dt = dt.substring(0, 10) +
                                        'T' +
                                        dt.substring(11);
                                    final QueryResult quiz = await _quiz.queryA(
                                        gq.updateStartTime(
                                            userid: userId,
                                            quizid: quizid,
                                            dt: dt));
                                    setState(() {});
                                  } else
                                    setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 5),
                                          elevation: 4,
                                          backgroundColor: kMatte,
                                          content: Text(
                                            'The Quiz you are trying to attempt, either has not started yet or is completed.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(color: kFrost),
                                          )));
                                }
                              },
                              style: TextButton.styleFrom(shadowColor: kMatte),
                              child: kIsWeb
                                  ? cardQuiz(index, context).moveUpOnHover
                                  : cardQuiz(index, context),
                            );
                          })),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Card cardQuiz(int index, BuildContext context) {
    return Card(
      color: kIgris,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${quizset[index]['quizName']}',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: kGlacier),
                ),
                Text(
                  '${quizset[index]['course']['courseId']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: kGlacier),
                ),
              ],
            ),
            Text(
              '${parseDate(quizset[index]['startTime'])}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: kGlacier),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${parseTime(quizset[index]['startTime'])} - ${parseTime(quizset[index]['endTime'])}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: kGlacier),
                ),
                Text(
                  '${quizset[index]['duration']} Mins',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: kGlacier),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quizset[index]['linear'] ? 'Linear' : 'Non-Linear'}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: kGlacier),
                ),
                Text(
                  '${quizset[index]['marks']} marks',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: kGlacier),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ag = new AuthGraphQL();
    ag.setAuth(Provider.of<Token>(context, listen: false).getToken());
    _quiz = ag.getClient();
    getQuizes();
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Color(0x00000000),
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      child: swap(),
      reverse: !showquiz,
    );
  }
}
