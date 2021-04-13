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

class FacQuiz extends StatefulWidget {
  @override
  _FacQuizState createState() => _FacQuizState();
}

class _FacQuizState extends State<FacQuiz> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var quizset = [];
  bool showquiz = false;
  int quizid = -1;
  String quizname = 'ERROR 404', accesscode = '';

  void getQuizes() async {
    final QueryResult quiz = await _quiz.queryA(gq.getTQuiz());
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
          int userId = int.parse(quiz.data['me']['usert']['id']);
          var quizs = quiz.data['me']['usert']['makesSet'][0]['quizzes'];
          for (int i = 0; i < quizs.length; i++) {
            var takers = quizs[i]['makers'];
            var user = [];
            for (int j = 0; j < takers.length; j++) {
              user.add(int.parse(takers[j]['user']['id']));
            }
            if (user.contains(userId)) {
              quizset.add(quizs[i]);
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
                        Text("Quizzes",
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
                              onPressed: () {
                                quizid = int.parse(quizset[index]['id']);
                                quizname = quizset[index]['quizName'];
                                accesscode = quizset[index]['accessCode'];
                                showquiz = true;
                                setState(() {});
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
