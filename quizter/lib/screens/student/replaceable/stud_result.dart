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
import 'package:quizter/screens/student/replaceable/stud_quiz.dart';

final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
final hoverTransform = Matrix4.identity()..translate(0, -5, 0);

class StudResult extends StatefulWidget {
  @override
  _StudResultState createState() => _StudResultState();
}

class _StudResultState extends State<StudResult> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var courseset = [],
      classlist = [],
      expanded = [],
      quesset = [],
      optset = [],
      pickedset = [],
      current,
      past,
      userId,
      result;
  bool showquiz = false, showresult = false;
  StudQuiz axxer = new StudQuiz();

  void getCourses() async {
    final QueryResult quiz = await _quiz.queryA(gq.resultlist());
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
          var temp = quiz.data['me']['usert']['belongsSet'];
          for (int i = 0; i < temp.length; i++) {
            var value = temp[i]['clas']['className'].toString(), val;
            try {
              switch (int.parse(value[0])) {
                case 1:
                  value = "CSE " + value[1];
                  val = "First Year";
                  break;
                case 2:
                  value = "CSE " + value[1];
                  val = "Second Year";
                  break;
                case 3:
                  value = "CSE " + value[1];
                  val = "Third Year";
                  break;
                case 4:
                  value = "CSE " + value[1];
                  val = "Fourth Year";
                  break;
              }

              for (int j = 0; j < temp[i]['clas']['teachesSet'].length; j++)
                courseset.add([
                  temp[i]['clas']['teachesSet'][j]['course']['courseId'],
                  temp[i]['clas']['teachesSet'][j]['course']['courseName'],
                  value,
                  val,
                  temp,
                ]);
            } catch (e) {}
          }
        });
      } catch (exception1) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> getOptions(int quesId) async {
    final QueryResult quiz = await _quiz
        .queryA(gq.getOptions(quizId: int.parse(result['id']), quesId: quesId));
    if (quiz.hasException) {
      print(quiz.exception);
    } else {
      optset = quiz.data['me']['usert']['takesSet'][0]['quiz']['question']
          ['options'];
      for (int i = 0; i < optset.length; i++)
        if (int.parse(optset[i]['user']['id']) == userId) {
          for (int j = 0; j < past.length; j++) {
            if (past[j] == int.parse(optset[i]['answer']['id'])) current[j] = 1;
          }
        }
    }
  }

  Future<String> getAnswerText(int quesId) async {
    try {
      final QueryResult quiz = await _quiz.queryA(
          gq.getOptions(quizId: int.parse(result['id']), quesId: quesId));
      optset = quiz.data['me']['usert']['takesSet'][0]['quiz']['question']
          ['options'];
      var iter = "";
      if (optset.isNotEmpty) {
        if (int.parse(optset[0]['user']['id']) == userId)
          iter = optset[0]['answer']['answerText'];
      }
      return iter;
    } catch (exception) {
      return "";
    }
  }

  Future<void> getQuestions() async {
    final QueryResult quiz =
        await _quiz.queryA(gq.getQuiz(int.parse(result['id'])));
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
      var temp = quiz.data['me']['usert']['takesSet'][0]['quiz'];
      userId = int.parse(quiz.data['me']['usert']['id']);
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
        print(pickedset);
      } else
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
                          '${result['quizName']}',
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
                      classlist = [];
                      setState(() {
                        showquiz = !showquiz;
                      });
                    }),
                Padding(
                  padding: EdgeInsets.only(left: 24.0),
                  child: Row(
                    children: [
                      Text(
                        '${classlist[0]}',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24.0),
                        child: Text(
                          '${classlist[1]}',
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
                    child: Card(
                      elevation: 0,
                      color: kIgris,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${classlist[2]}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(color: kGlacier),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 24.0),
                                        child: Text(
                                          '${classlist[3]}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .copyWith(color: kGlacier),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                    ),
                                    color: kGlacier,
                                    tooltip: 'Filter List',
                                    onPressed: () {},
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
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                            ),
                            for (int i = 0; i < classlist[4].length; i++)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                "Quiz Name",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(color: kGlacier),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Marks",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(color: kGlacier),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Total Marks",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(color: kGlacier),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                "Feedback",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(color: kGlacier),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                "Status",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .copyWith(color: kGlacier),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: kGlacier,
                                      thickness: 1,
                                    ),
                                    for (int j = 0;
                                        j <
                                            (classlist[4][i]['user']['takesSet'][0]['quizzes'])
                                                .length;
                                        j++)
                                      if (classlist[4][i]['user']['takesSet'][0]['quizzes']
                                                  [j]['course']['courseId'] ==
                                              classlist[0] &&
                                          (DateTime.parse(changedate(classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['endTime']))
                                                  .isBefore(DateTime.now()) ||
                                              find(i, j) ==
                                                  classlist[4][i]['user']
                                                          ['takesSet'][0]['quizzes']
                                                      [j]['timesCanTake']) &&
                                          DateTime.parse(changedate(classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['publishTime']))
                                              .isBefore(DateTime.now()))
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    "${classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['quizName']}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color: kGlacier),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "${findm(i, j)}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color: kGlacier),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "${classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['marks']}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color: kGlacier),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      result = classlist[4][i]
                                                                  ['user']
                                                              ['takesSet'][0]
                                                          ['quizzes'][j];
                                                      await getQuestions();
                                                      showresult = true;
                                                      setState(() {});
                                                    },
                                                    style: TextButton.styleFrom(
                                                        shadowColor: kMatte,
                                                        alignment: Alignment
                                                            .centerLeft),
                                                    child: Text(
                                                      "Yes",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1
                                                          .copyWith(
                                                              color: kFrost),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    "${findst(i, j)}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                          color: clr(i, j),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
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
                              tooltip: 'Filter Results',
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
                      child: courseset.isEmpty
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
                              //TODO: fix card overflow
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 32.0),
                              itemCount: courseset.length,
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
                                    classlist = courseset[index];
                                    expanded = List<int>.generate(
                                        classlist[4].length, (int index) => 0);
                                    showquiz = true;
                                    showresult = false;
                                    setState(() {});
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

  String find(i, j) {
    var user = classlist[4][i]['user']['id'];
    var temp = classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'];
    for (int k = 0; k < temp.length; k++)
      if (classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'][k]
              ['user']['id'] ==
          user)
        return classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'][k]
                ['timesTaken']
            .toString();
    return '0';
  }

  String changedate(String dt) {
    return DateTime.parse(dt)
        .add(const Duration(hours: 5, minutes: 30))
        .toString();
  }

  String findst(i, j) {
    DateTime st = DateTime.parse(changedate(classlist[4][i]['user']['takesSet']
            [0]['quizzes'][j]['startTime']
        .toString()
        .substring(0, 16)));
    DateTime et = DateTime.parse(changedate(classlist[4][i]['user']['takesSet']
            [0]['quizzes'][j]['endTime']
        .toString()
        .substring(0, 16)));
    var ppr = axxer.createState().valTime(st.toString(), et.toString());
    var check = int.parse(find(i, j));
    if (ppr) {
      if (check == 0) {
        return "Active";
      }
      if (check > 0 &&
          check <
              classlist[4][i]['user']['takesSet'][0]['quizzes'][j]
                  ['timesCanTake']) {
        return "Submitted & Active";
      }
      if (check ==
          classlist[4][i]['user']['takesSet'][0]['quizzes'][j]
              ['timesCanTake']) {
        return "Completed";
      }
    } else {
      if (check == 0) {
        DateTime p = DateTime.parse(DateTime.now().toString().substring(0, 16));
        if (st.isAfter(p)) {
          return "Upcoming";
        } else {
          return "Expired";
        }
      }
      if (check ==
          classlist[4][i]['user']['takesSet'][0]['quizzes'][j]
              ['timesCanTake']) {
        return "Completed";
      }
      if (check > 0) {
        return "Submitted";
      }
    }
    return "";
  }

  Color clr(i, j) {
    var x = findst(i, j);
    if (x == "Active" || x == "Submitted & Active" || x == "Submitted")
      return kGreen;

    if (x == "Expired") return kMatte;

    if (x == "Completed") return kGlacier;

    if (x == "Upcoming") return kFrost;
  }

  String findm(i, j) {
    var check = int.parse(find(i, j));
    if (check != 0) {
      var user = classlist[4][i]['user']['id'];
      var temp = classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'];
      for (int k = 0; k < temp.length; k++)
        if (classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'][k]
                ['user']['id'] ==
            user)
          return classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers']
                  [k]['marks']
              .toString();
      return '-';
    } else {
      return 'N/A';
    }
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${courseset[index][0]}',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: kGlacier),
                ),
                Text(
                  '${courseset[index][1]}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: kGlacier),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${courseset[index][2]}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: kGlacier),
                ),
                Text(
                  '${courseset[index][3]}',
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
    getCourses();
  }

  void refresh() {
    setState(() {
      courseset = [];
    });
    getCourses();
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
      reverse: showresult || !showquiz,
    );
  }
}
