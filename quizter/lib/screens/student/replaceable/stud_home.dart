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

class StudHome extends StatefulWidget {
  @override
  _StudHomeState createState() => _StudHomeState();
}

class _StudHomeState extends State<StudHome> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var quizset = [], starttime = [];
  bool showquiz = false;
  int quizid = -1, userId = -1, id = -1;
  String quizname = 'ERROR 404';
  var un,fn,ln,cls,email,qs,yr,dept="CSE";
  void getQuizes() async {

    final QueryResult quiz = await _quiz.queryA(gq.getSprofile());
    un=quiz.data['me']['usert']['user']['username'].toString();
    fn=quiz.data['me']['usert']['user']['firstName'].toString();
    ln=quiz.data['me']['usert']['user']['lastName'].toString();
    email=quiz.data['me']['usert']['user']['email'].toString();
    cls=quiz.data['me']['usert']['belongsSet'][0]['clas']['className'];
    qs=quiz.data['me']['usert']['takesSet'][0]['quizzes'].length;

    try {
              switch (int.parse(cls[0])) {
                case 1:
                  yr = "First Year";
                  break;
                case 2:
                  yr = "Second Year";
                  break;
                case 3:
                  yr= "Third Year";
                  break;
                case 4:
                  yr = "Fourth Year";
                  break;
              }

        } 
        catch (e) {}
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
      quizset = [-1];
      setState(() {});
    } else {
      try {
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
          DateTime sd=DateTime.parse(quizs[i]['startTime'].toString().substring(0,10));
          DateTime nd=DateTime.parse(DateTime.now().toString().substring(0,10));
          if (user.contains(userId) &&
              nd == sd &&
              times[user.indexOf(userId)] < quizs[i]['timesCanTake']) {
            quizset.add(quizs[i]);
            try {
              starttime.add(changedate(start[user.indexOf(userId)]));
            } catch (e) {
              starttime.add("-1");
            }
          }
        }
        if (quizset.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          quizset.add(-1);
        }
      } catch (exception1) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        quizset.add(-1);
      }
      setState(() {});
    }
  }

  String changedate(String dt) {
    return DateTime.parse(dt)
        .add(const Duration(hours: 5, minutes: 30))
        .toString();
  }

  bool valTime(String dt, String et) {
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
                'Your quiz was auto submitted.\n\nNote:   In case, the last question you have been working on was a short answer, numerical or fill in the blanks; it may have not been saved.',
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
      return Column(
        children: [
          Expanded(child: 
          Container(color: kFrost,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,left:40),
                      child: Text("Profile",style:Theme.of(context).textTheme.headline4),
                    ),
                  ),    
                ],
              ),
              Divider(
                color: kIgris,
                thickness: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Username:  ${un}',style:Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Name:  ${fn} ${ln}',style:Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Email:  ${email}',style:Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Department:  ${dept}',style:Theme.of(context).textTheme.headline6,),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Year:  ${yr}',style:Theme.of(context).textTheme.headline6,),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Class:  ${cls}',style:Theme.of(context).textTheme.headline6,),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:20,left:40),
                      child: Text('Total Quizzes Assigned:  ${qs}',style:Theme.of(context).textTheme.headline6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          )
          ),
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
                              Text("Todays Quizzes",
                                  style: Theme.of(context).textTheme.headline4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                    ),
                                    color: kMatte,
                                    tooltip: 'Refresh',
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
                            height: MediaQuery.of(context).size.height/2 -122,
                            child: Padding (
                              padding:EdgeInsets.only(bottom: 32),
                              child:quizset.isEmpty
                                ? ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 32.0),
                                    itemCount: 6,
                                    scrollDirection: Axis.horizontal,
                                    
                                    itemBuilder: (BuildContext context, int index) {
                                      return Card(
                                        color: kIgris,
                                        elevation: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                    MainAxisAlignment.spaceBetween,
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
                                                    MainAxisAlignment.spaceBetween,
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
                                        
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return TextButton(
                                            onPressed: () async {
                                              quizid =
                                                  int.parse(quizset[index]['id']);
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
                                                  starttime[index] = dt;
                                                  final QueryResult quiz = await _quiz
                                                      .queryA(gq.updateStartTime(
                                                          userid: userId,
                                                          quizid: quizid,
                                                          dt: dt));
                                                  setState(() {});
                                                } else
                                                  setState(() {});
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        duration:
                                                            Duration(seconds: 5),
                                                        elevation: 4,
                                                        backgroundColor: kMatte,
                                                        content: Text(
                                                          'The Quiz you are trying to attempt, either has not started yet or is completed.',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyText2
                                                              .copyWith(
                                                                  color: kFrost),
                                                        )));
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                                shadowColor: kMatte),
                                            child: kIsWeb
                                                ? cardQuiz(index, context)
                                                    
                                                : cardQuiz(index, context),
                                          );
                                        })),
                      )),
                    ],
                  ),
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