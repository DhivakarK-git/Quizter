import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/widgets/hover_extensions.dart';
import 'package:provider/provider.dart';
import 'package:quizter/graphql/authentication/token.dart';
import 'package:quizter/graphql/authentication/auth_graphql.dart';
import 'package:graphql/client.dart';
import 'package:quizter/graphql/graphqueries.dart';
import 'package:animations/animations.dart';
import 'package:charts_flutter/flutter.dart' as charts;

final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
final hoverTransform = Matrix4.identity()..translate(0, -5, 0);

class FacResult extends StatefulWidget {
  @override
  _FacResultState createState() => _FacResultState();
}

class _FacResultState extends State<FacResult> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var quiz,
      quizset = [],
      quesset = [],
      optset = [],
      pickedset = [],
      scores = [],
      scoresseries = Map(),
      current,
      past,
      userId;
  List<ScoresSeries> chart;
  bool showquiz = false, showresult = false;
  int quizid = -1;
  String quizname = 'ERROR 404', courseId = '';

  double median(var scores) {
    double median;
    int middle = scores.length ~/ 2;
    if (scores.length % 2 == 1) {
      median = scores[middle];
    } else {
      median = ((scores[middle - 1] + scores[middle]) / 2.0);
    }
    return median;
  }

  Future<void> getOptions(int quesId) async {
    final QueryResult quiz =
        await _quiz.queryA(gq.getROptions(quizId: quizid, quesId: quesId));
    if (quiz.hasException) {
      print(quiz.exception);
    } else {
      optset = quiz.data['me']['usert']['makesSet'][0]['quiz']['question']
          ['options'];
      for (int i = 0; i < optset.length; i++) {
        if (optset[i]['user']['id'] == userId) {
          for (int j = 0; j < past.length; j++) {
            if (past[j] == int.parse(optset[i]['answer']['id'])) {
              current[j] = 1;
            }
          }
        }
      }
    }
  }

  Future<String> getAnswerText(int quesId) async {
    try {
      final QueryResult quiz =
          await _quiz.queryA(gq.getOptions(quizId: quizid, quesId: quesId));
      optset = quiz.data['me']['usert']['takesSet'][0]['quiz']['question']
          ['options'];
      var iter = "";
      if (optset.isNotEmpty) {
        if (optset[0]['user']['id'] == userId)
          iter = optset[0]['answer']['answerText'];
      }
      return iter;
    } catch (exception) {
      return "";
    }
  }

  Future<void> getQuestions() async {
    final QueryResult quiz = await _quiz.queryA(gq.getRQuiz(quizid));
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        elevation: 2,
        backgroundColor: kMatte,
        content: Text(
          'Sorry, we have trouble finding questions for your quiz right now. Please try again.',
          style: Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
        ));
    if (quiz.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      var temp = quiz.data['me']['usert']['makesSet'][0]['quiz'];
      if (temp['questions'].length != 0) {
        quesset = temp['questions'];
        pickedset = [];
        for (int i = 0; i < quesset.length; i++) {
          past = [];
          var type = quesset[i]['questionType'];
          if (type == 'SCA' || type == 'MCA') {
            for (int j = 0; j < quesset[i]['answers'].length; j++)
              past.add(int.parse(quesset[i]['answers'][j]['id']));
            current = List<int>.generate(
                quesset[i]['answers'].length, (int index) => 0);
            await getOptions(int.parse(quesset[i]['id']));
            pickedset.add(current);
          } else if (type == 'FITB' || type == 'NUM') {
            String answer = await getAnswerText(int.parse(quesset[i]['id']));
            pickedset.add(answer);
          }
        }
      } else
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void getQuizes() async {
    final QueryResult quiz = await _quiz.queryA(gq.getFRQuiz());
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
    ScrollController _icarus = new ScrollController();
    if (showresult) {
      return Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: kMatte,
                      onPressed: () {
                        setState(() {
                          showresult = false;
                        });
                      }),
                  Padding(
                    padding: EdgeInsets.only(left: 24.0),
                    child: Row(
                      children: [
                        Text(
                          '${quizname}',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                child: Scrollbar(
                  controller: _icarus,
                  child: SingleChildScrollView(
                    controller: _icarus,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          for (int i = 0; i < quesset.length; i++)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Card(
                                      elevation: 0,
                                      color: kGlacier,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "${i + 1}. ${quesset[i]['questionText']}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (quesset[i]
                                                            ['questionType'] ==
                                                        'MCA')
                                                      Text(
                                                        "MCA",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    Text(
                                                      quesset[i]['questionMark'] >
                                                              1
                                                          ? "${quesset[i]['questionMark']} marks"
                                                          : "${quesset[i]['questionMark']} mark",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (quesset[i]['questionType'] ==
                                                    'FITB' ||
                                                quesset[i]['questionType'] ==
                                                    'NUM' ||
                                                quesset[i]['questionType'] ==
                                                    'SHORT')
                                              SizedBox(height: 24.0),
                                            if (quesset[i]['questionType'] ==
                                                    'FITB' ||
                                                quesset[i]['questionType'] ==
                                                    'NUM')
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.8,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Entered Answer: " +
                                                            pickedset[i],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      Text(
                                                        "Correct Answer: " +
                                                            quesset[i]['answers']
                                                                    [0]
                                                                ['answerText'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!(quesset[i]['questionType'] == 'FITB' ||
                                    quesset[i]['questionType'] == 'NUM' ||
                                    quesset[i]['questionType'] == 'SHORT'))
                                  for (int k = 0;
                                      k < (quesset[i]['answers'].length);
                                      k++)
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 16.0,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 32.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      300,
                                                  child: Card(
                                                    elevation: 2,
                                                    color: pickedset[i][k] == 1
                                                        ? kIgris
                                                        : kGlacier,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "${(quesset[i]['questionType'] == 'SCA') ? String.fromCharCode(k + 65) + '. ' : ''}${quesset[i]['answers'][k]['answerText']}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1
                                                                .copyWith(
                                                                    color: pickedset[i][k] ==
                                                                            1
                                                                        ? kGlacier
                                                                        : kMatte),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Card(
                                                  elevation: quesset[i]
                                                              ['answers'][k]
                                                          ['correct']
                                                      ? 2
                                                      : 0,
                                                  color: quesset[i]['answers']
                                                          [k]['correct']
                                                      ? kGlacier
                                                      : kFrost,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Icon(
                                                      Icons.done,
                                                      color: quesset[i]
                                                                  ['answers'][k]
                                                              ['correct']
                                                          ? kGreen
                                                          : kFrost,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                SizedBox(
                                  height: 64.0,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (showquiz) {
      return Padding(
        padding: EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: kMatte,
                    onPressed: () {
                      quizid = null;
                      quizname = null;
                      courseId = null;
                      setState(() {
                        showquiz = !showquiz;
                      });
                    }),
                Padding(
                  padding: EdgeInsets.only(left: 24.0),
                  child: Row(
                    children: [
                      Text(
                        '$courseId',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24.0),
                        child: Text(
                          '$quizname',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 200,
              child: Scrollbar(
                controller: _icarus,
                child: SingleChildScrollView(
                  controller: _icarus,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          color: kGlacier,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.assessment_outlined,
                                        color: kMatte,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        "Insights",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: kFrost,
                                  thickness: 1,
                                  endIndent: 16,
                                  indent: 16,
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Card(
                                      elevation: 0,
                                      color: kFrost,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Average",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "${scores.fold(0, (previous, current) => previous + current) / scores.length} marks",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 0,
                                      color: kFrost,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Median",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              " marks",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 0,
                                      color: kFrost,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Range",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "${scores[0]} - ${scores[scores.length - 1]} marks",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 0,
                                      color: kFrost,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Total Marks",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "${quiz['marks']} marks",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Center(
                                  child: ScoresChart(
                                    data: chart,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: 0,
                          color: kIgris,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Roll No.",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(color: kGlacier),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Name",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(color: kGlacier),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Marks",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(color: kGlacier),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          "No. of Submission made",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(color: kGlacier),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: kGlacier,
                                  thickness: 1,
                                  endIndent: 16,
                                  indent: 16,
                                ),
                                for (int i = 0; i < quiz['takers'].length; i++)
                                  TextButton(
                                    onPressed: () async {
                                      userId = quiz['takers'][i]['user']['id'];
                                      await getQuestions();
                                      showresult = true;
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "${quiz['takers'][i]['user']['user']['username']}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: kGlacier),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  "${quiz['takers'][i]['user']['user']['firstName']} ${quiz['takers'][i]['user']['user']['lastName']}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: kGlacier),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "${quiz['takers'][i]['marks'] != null ? quiz['takers'][i]['marks'] : 'N/A'}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: kGlacier),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  "${quiz['takers'][i]['timesTaken']} out of ${quiz['timesCanTake']}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: kGlacier),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: kQuiz,
                                            thickness: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                        Text("Results",
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
                      height: MediaQuery.of(context).size.height - 208,
                      child: quizset.isEmpty
                          ? GridView.builder(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 32.0),
                              itemCount: 8,
                              gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount:
                                    (MediaQuery.of(context).size.width) ~/ 314,
                                childAspectRatio: 1.729,
                              ),
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
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  color: kQuiz,
                                                  height: 24,
                                                  width: 108,
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Container(
                                                  color: kQuiz,
                                                  height: 16,
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
                                                  width: 48,
                                                ),
                                                Container(
                                                  color: kQuiz,
                                                  height: 14,
                                                  width: 72,
                                                ),
                                              ],
                                            ),
                                          ],
                                        )));
                              })
                          : GridView.builder(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 32.0),
                              itemCount: quizset.length,
                              gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount:
                                    (MediaQuery.of(context).size.width) ~/ 314,
                                childAspectRatio: 1.729,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return TextButton(
                                  onPressed: () {
                                    quiz = quizset[index];

                                    scores = [];
                                    for (int j = 0;
                                        j < quiz['takers'].length;
                                        j++) {
                                      if (quiz['takers'][j]['timesTaken'] > 0)
                                        scores.add(quiz['takers'][j]['marks']);
                                    }

                                    if (scores.isNotEmpty) {
                                      quizid = int.parse(quizset[index]['id']);
                                      quizname = quizset[index]['quizName'];
                                      courseId =
                                          quizset[index]['course']['courseId'];
                                      scores.sort();
                                      scoresseries = Map();
                                      chart = [];
                                      scores.forEach((element) {
                                        if (!scoresseries
                                            .containsKey(element)) {
                                          scoresseries[element] = 1;
                                        } else {
                                          scoresseries[element] += 1;
                                        }
                                      });
                                      for (var k in scoresseries.keys) {
                                        chart.add(ScoresSeries(
                                            scores: k,
                                            responses:
                                                scoresseries[k].toDouble()));
                                      }
                                      showquiz = true;
                                      setState(() {});
                                    } else {
                                      quizid = -1;
                                      quizname = 'Error 404';
                                      courseId = 'Error 404';
                                      quiz = null;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              duration: Duration(seconds: 5),
                                              elevation: 2,
                                              backgroundColor: kMatte,
                                              content: Text(
                                                'The quiz does not have any valid submissions, so, no results can be displayed.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    .copyWith(color: kFrost),
                                              )));
                                    }
                                  },
                                  style:
                                      TextButton.styleFrom(shadowColor: kMatte),
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
    return Card(
      color: kIgris,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${quizset[index]['quizName']}',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: kGlacier),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${quizset[index]['course']['courseId']}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
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

class ScoresSeries {
  final double scores, responses;
  final charts.Color barColor = charts.ColorUtil.fromDartColor(kIgris);
  ScoresSeries({@required this.scores, @required this.responses});
}

class ScoresChart extends StatelessWidget {
  final List<ScoresSeries> data;

  ScoresChart({@required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<ScoresSeries, String>> series = [
      charts.Series(
          id: "Subscribers",
          data: data,
          domainFn: (ScoresSeries series, _) => series.scores.toString(),
          measureFn: (ScoresSeries series, _) => series.responses,
          colorFn: (ScoresSeries series, _) => series.barColor)
    ];
    return Container(
      height: 400,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Total Marks Distribution",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: charts.BarChart(series, animate: true),
          ),
          Text(
            "Marks Scored",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
