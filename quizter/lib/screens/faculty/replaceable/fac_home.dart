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

class FacHome extends StatefulWidget {
  @override
  _FacHomeState createState() => _FacHomeState();
}

class _FacHomeState extends State<FacHome> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var quizset = [];
  bool showquiz = false, show = false;
  int quizid = -1;
  String quizname = 'ERROR 404', accesscode = '';
  var un, fn, ln, dept, email, qz;

  void getQuizes() async {
    final QueryResult quiz = await _quiz.queryA(gq.getFprofile());
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
      setState(() {
        quizset = [-1];
      });
    } else {
      un = quiz.data['me']['usert']['user']['username'].toString();
      fn = quiz.data['me']['usert']['user']['firstName'].toString();
      ln = quiz.data['me']['usert']['user']['lastName'].toString();
      email = quiz.data['me']['usert']['user']['email'].toString();
      qz = quiz.data['me']['usert']['makesSet'][0]['quizzes'].length;
      try {
        int userId = int.parse(quiz.data['me']['usert']['id']);
        var quizs = quiz.data['me']['usert']['makesSet'][0]['quizzes'];
        for (int i = 0; i < quizs.length; i++) {
          var takers = quizs[i]['makers'];
          var user = [];
          for (int j = 0; j < takers.length; j++) {
            user.add(int.parse(takers[j]['user']['id']));
          }
          DateTime sd =
              DateTime.parse(quizs[i]['startTime'].toString().substring(0, 10));
          DateTime nd =
              DateTime.parse(DateTime.now().toString().substring(0, 10));
          if (user.contains(userId) && sd == nd) {
            quizset.add(quizs[i]);
          }
        }
        if (quizset.isEmpty) {
          setState(() {
            quizset = [-1];
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
              elevation: 2,
              backgroundColor: kMatte,
              content: Text(
                'No quizzes are available for you today.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: kFrost),
              )));
        }
      } catch (exception1) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          quizset = [-1];
        });
      }
      setState(() {
        show = true;
      });
    }
  }

  String changedate(String dt) {
    return DateTime.parse(dt)
        .add(const Duration(hours: 5, minutes: 30))
        .toString();
  }

  String parseDate(String dt) {
    dt = changedate(dt);
    return (dt.substring(8, 10) + dt.substring(4, 8) + dt.substring(0, 4));
  }

  String parseTime(String t) {
    t = changedate(t);
    t = t.substring(11, 16);
    int p = int.parse(t.substring(0, 2));
    if (p > 12) {
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
      return QuizScreen(
        quizid,
        quizname,
        accesscode,
        () {
          quizid = -1;
          quizname = '';
          showquiz = false;
          setState(() {});
        },
      );
    } else
      return Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Card(
                    color: kGlacier,
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_box,
                          size: 200,
                        ),
                        !show
                            ? Text('Faculty',
                                style: Theme.of(context).textTheme.headline6)
                            : Text('$un',
                                style: Theme.of(context).textTheme.headline6),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Card(
                    color: kIgris,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!show)
                            Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: kFrost,
                                ),
                              ),
                            ),
                          !show
                              ? Container()
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text('Name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: kGlacier)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text('$fn $ln',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: kGlacier)),
                                    ),
                                  ],
                                ),
                          !show
                              ? Container()
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text('Email',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: kGlacier)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text('$email',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: kGlacier)),
                                    ),
                                  ],
                                ),
                          if (!show)
                            Container()
                          else
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text('Department',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(color: kGlacier)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('CSE',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(color: kGlacier)),
                                ),
                              ],
                            ),
                          !show
                              ? Container()
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text('Quizzes Created',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: kGlacier)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text('$qz',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(color: kGlacier)),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: kFrost,
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_box,
                          size: 200,
                          color: kFrost,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
          Expanded(
            child: Row(
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
                              Text("Today Quizzes",
                                  style: Theme.of(context).textTheme.headline4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                    ),
                                    color: kMatte,
                                    tooltip: 'Filter Quizzes',
                                    onPressed: () {
                                      refresh();
                                    },
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.tune,
                                    ),
                                    color: kMatte,
                                    tooltip: 'Filter Quizzes',
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height:
                                MediaQuery.of(context).size.height / 2 - 122,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: quizset.isEmpty
                                  ? ListView.builder(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 32.0),
                                      itemCount: 6,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Card(
                                          color: kIgris,
                                          elevation: 2,
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      color: kQuiz,
                                                      height: 24,
                                                      width: 132,
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Container(
                                                      color: kQuiz,
                                                      height: 16,
                                                      width: 72,
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  color: kQuiz,
                                                  height: 14,
                                                  width: 72,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      color: kQuiz,
                                                      height: 14,
                                                      width: 132,
                                                    ),
                                                    Container(
                                                      color: kQuiz,
                                                      height: 14,
                                                      width: 72,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      color: kQuiz,
                                                      height: 14,
                                                      width: 72,
                                                    ),
                                                    Container(
                                                      color: kQuiz,
                                                      height: 14,
                                                      width: 72,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                  : quizset[0] == -1
                                      ? Container()
                                      : ListView.builder(
                                          //TODO: fix card overflow
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 32.0),
                                          itemCount: quizset.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return TextButton(
                                              onPressed: () {
                                                quizid = int.parse(
                                                    quizset[index]['id']);
                                                quizname =
                                                    quizset[index]['quizName'];
                                                accesscode = quizset[index]
                                                    ['accessCode'];
                                                showquiz = true;
                                                setState(() {});
                                              },
                                              style: TextButton.styleFrom(
                                                  shadowColor: kMatte),
                                              child: kIsWeb
                                                  ? cardQuiz(index, context)
                                                      .moveUpOnHover
                                                  : cardQuiz(index, context),
                                            );
                                          }),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget cardQuiz(int index, BuildContext context) {
    try {
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
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${quizset[index]['duration']} Mins',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: kGlacier),
                    ),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '${quizset[index]['marks']} marks',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: kGlacier),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Tooltip(
        message: "Unpublished Quiz",
        child: Card(
          color: kIgris,
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${quizset[index]['quizName']}',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: kFrost),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    ag = new AuthGraphQL();
    ag.setAuth(Provider.of<Token>(context, listen: false).getToken());
    _quiz = ag.getClient();
    getQuizes();
  }

  void refresh() {
    setState(() {
      quizset = [];
    });
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
