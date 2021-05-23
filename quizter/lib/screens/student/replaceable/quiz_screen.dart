import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quizter/constants.dart';
import 'package:provider/provider.dart';
import 'package:quizter/graphql/authentication/token.dart';
import 'package:quizter/graphql/authentication/auth_graphql.dart';
import 'package:graphql/client.dart';
import 'package:quizter/graphql/graphqueries.dart';
import 'package:animations/animations.dart';
import 'dart:async';
import 'package:quizter/widgets/option_button.dart';
import 'package:quizter/widgets/ques_button.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final int id;
  final Function goBack, goBackPlus, submit;
  final String quizname, start;
  QuizScreen(this.id, this.quizname, this.start, this.goBack, this.goBackPlus,
      this.submit);
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var quesset = [], optset = [], current = [], past = [], colors = [];
  bool proceed = false,
      direction = true,
      side = false,
      linear = false,
      shuffle = false;
  int index = 0, userId = -1, f = 0;
  double _start = 1, _progress = 0;
  String answer = "", ans = "";
  Timer _timer;
  Animation<Color> vicari = AlwaysStoppedAnimation<Color>(kGreen);
  Future<void> getQuestions(String access) async {
    final QueryResult quiz = await _quiz.queryA(gq.getQuiz(widget.id));
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
        if (access == temp['accessCode']) {
          quesset = temp['questions'];
          linear = temp['linear'];
          shuffle = temp['shuffle'];
          if (shuffle) {
            var random = new Random();
            for (var i = quesset.length - 1; i > 0; i--) {
              var n = random.nextInt(i + 1);
              var temp = quesset[i];
              quesset[i] = quesset[n];
              quesset[n] = temp;
            }
          }
          colors = List<int>.generate(quesset.length, (int index) => 0);
          proceed = true;
          past = [];
          ans = (await getAnswerText(int.parse(quesset[index]['id'])))
              .replaceAll("</*n>", "\n");

          for (int i = 0; i < quesset[index]['answers'].length; i++)
            past.add(int.parse(quesset[index]['answers'][i]['id']));
          current = List<int>.generate(
              quesset[index]['answers'].length, (int index) => 0);
          await getOptions(int.parse(quesset[index]['id']));
          int dur = confirmTime(temp['duration'], temp['endTime']);
          startTimer(dur);
        } else
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
              elevation: 2,
              backgroundColor: kMatte,
              content: Text(
                'Sorry, we have trouble matching the access code with the one in our database. Please try again.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: kFrost),
              )));
      } else
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  int confirmTime(int duration, String end) {
    var start;
    try {
      start = DateTime.parse(widget.start.substring(0, 16))
          .add(Duration(minutes: duration));
    } catch (e) {
      start = DateTime.now().add(Duration(minutes: duration));
    }
    var a = DateTime.parse(end.substring(0, 16))
        .add(Duration(hours: 5, minutes: 30));
    var b = (DateTime.now()).add(Duration(minutes: duration));
    a = a.compareTo(b) <= 0 ? a : b;
    start = start.compareTo(a) <= 0 ? start : a;
    return (start.difference(DateTime.now()).inSeconds);
  }

  void startTimer(int start) {
    double _star = double.parse(start.toString());
    int i = 3;
    _progress = _star;
    const oneSec = const Duration(milliseconds: 50);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_progress <= 0.05) {
          setState(() {
            timer.cancel();
            widget.submit.call();
          });
        } else {
          setState(() {
            if (_start < 0.5) {
              vicari = AlwaysStoppedAnimation<Color>(kYellow);
            }
            if (_start < 0.25) {
              vicari = AlwaysStoppedAnimation<Color>(kRed);
            }
            _progress -= 0.05;
            _start = _progress / _star;
          });
          if (_start < 0.5) {
            if (i == 3) {
              i--;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 5),
                  backgroundColor: kMatte,
                  content: Text(
                    'You have ${(_progress ~/ 60).toString().length == 2 ? (_progress ~/ 60) : '0' + (_progress ~/ 60).toString()} mins and ${((_progress % 60).truncate()).toString().length == 2 ? ((_progress % 60).truncate()) : '0' + ((_progress % 60).truncate()).toString()} seconds left to complete the quiz.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: kFrost),
                  )));
            }
          }
          if (_start < 0.25) {
            if (i == 2) {
              i--;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 5),
                  backgroundColor: kMatte,
                  content: Text(
                    'You have ${(_progress ~/ 60).toString().length == 2 ? (_progress ~/ 60) : '0' + (_progress ~/ 60).toString()} mins and ${((_progress % 60).truncate()).toString().length == 2 ? ((_progress % 60).truncate()) : '0' + ((_progress % 60).truncate()).toString()} seconds left to complete the quiz.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: kFrost),
                  )));
            }
          }
          if (_start < 0.1) {
            if (i == 1) {
              i--;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 5),
                  backgroundColor: kMatte,
                  content: Text(
                    'You have ${(_progress ~/ 60).toString().length == 2 ? (_progress ~/ 60) : '0' + (_progress ~/ 60).toString()} mins and ${((_progress % 60).truncate()).toString().length == 2 ? ((_progress % 60).truncate()) : '0' + ((_progress % 60).truncate()).toString()} seconds left to complete the quiz.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: kFrost),
                  )));
            }
          }
        }
      },
    );
  }

  Future<void> getOptions(int quesId) async {
    final QueryResult quiz =
        await _quiz.queryA(gq.getOptions(quizId: widget.id, quesId: quesId));
    if (quiz.hasException) {
      print(quiz.exception);
    } else {
      optset = quiz.data['me']['usert']['takesSet'][0]['quiz']['question']
          ['options'];
      if (f == 0) {
        if (optset.isNotEmpty) {
          for (int i = 0; i < optset.length; i++)
            if (int.parse(optset[i]['user']['id']) == userId) {
              for (int j = 0; j < past.length; j++) {
                if (past[j] == int.parse(optset[i]['answer']['id']))
                  current[j] = 1;
              }
            }
        }
        past = current.map((element) => element).toList();
        setState(() {});
        f = 1;
      }
    }
  }

  Future<String> getAnswerText(int quesId) async {
    try {
      final QueryResult quiz =
          await _quiz.queryA(gq.getOptions(quizId: widget.id, quesId: quesId));
      optset = quiz.data['me']['usert']['takesSet'][0]['quiz']['question']
          ['options'];
      var iter = "Type your answer here ...";
      if (optset.isNotEmpty) {
        if (int.parse(optset[0]['user']['id']) == userId)
          iter = optset[0]['answer']['answerText'];
      }
      return iter;
    } catch (exception) {
      return "Type your answer here ...";
    }
  }

  Future<void> savequestion(
      int quesId, var past, var current, var quesset) async {
    f = 0;
    if (answer.isEmpty) {
      for (int i = 0; i < past.length; i++) {
        if (past[i] == 1 && current[i] == 0) {
          final QueryResult quiz = await _quiz.queryA(gq.deleteOption(
            userId: userId,
            answerId: int.parse(quesset[index]['answers'][i]['id']),
            quesId: quesId,
          ));
        } else if (past[i] == 0 && current[i] == 1) {
          final QueryResult quiz = await _quiz.queryA(gq.createOption(
            userId: userId,
            answerId: int.parse(quesset[index]['answers'][i]['id']),
            quesId: quesId,
          ));
        }
      }
    } else {
      var iter = await getAnswerText(quesId);
      if (iter == "Type your answer here ...") {
        final QueryResult quiz = await _quiz.queryA(gq.createAnswer(
          quesId: quesId,
          answerText: answer,
        ));
        print(quiz.context);
        if (quiz.data != null) {
          int i = int.parse(quiz.data['createAnswer']['answer']['id']);
          final QueryResult quz = await _quiz.queryA(
            gq.createOption(
              userId: userId,
              answerId: i,
              quesId: quesId,
            ),
          );
          answer = "";
        }
      } else {
        final QueryResult quiz = await _quiz
            .queryA(gq.getOptions(quizId: widget.id, quesId: quesId));
        var iter = quiz.data['me']['usert']['takesSet'][0]['quiz']['question']
            ['options'];
        if (iter.isNotEmpty) {
          if (int.parse(optset[0]['user']['id']) == userId)
            await _quiz.queryA(
              gq.updateAnswer(
                answerId: int.parse(iter[0]['answer']['id']),
                answerText: answer,
              ),
            );
        }
        answer = "";
      }
    }
  }

  Widget swaper() {
    String access;
    if (!proceed) {
      return Container(
        key: ValueKey<int>(-1),
        margin: EdgeInsets.fromLTRB(0, 24.0, 0, 32.0),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 24.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        color: kMatte,
                        onPressed: widget.goBack),
                    SizedBox(
                      width: 24.0,
                    ),
                    Text("${widget.quizname}",
                        style: Theme.of(context).textTheme.headline5),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 256,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Card(
                          elevation: 0,
                          color: kGlacier,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Important Instructions regarding the quiz",
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                    Container(
                                      child: Text(
                                        '''

• Read the questions thoroughly and answer them appropriately.

• Make sure you have good internet connection.

• No multiple tabs are allowed in the browser during the quiz.

• Do not unnecessarily refresh the page during a quiz.

• Do not use navigation options from the chrome browser.

• Don’t indulge in any kind of malpractices, as it may result in termination of your exam.

• For linear access based quizzes question navigator will be disabled.

• For non-linear quizzes question navigator will be enabled.

• For quizzes with negative marking the marking scheme is as follows:
      +x for correct answer and -y for incorrect answer,

• For multiple correct answers, MCA (More than one Correct answer) is mentioned on the top of marks alloted for the question the question.
  Also, the options for a MCA question will not have numbering or lettering to indicate the question.

• It is the students’ responsibility to complete the quiz within the given time frame.

• For MCQ based quizzes, if the given time limit is up then the quiz is auto submitted.

• For theory based quizzes quiz may or may not get auto submitted.

• When viewing the question navigator:

    </> Green indicates viewed and answered

    </> Yellow indicates viewed and flagged

    </> Red means indicates and not answered

    </> Purple indicates selection everywhere

•  All the best and do well.
    ''',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 36.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 256,
                            child: TextField(
                              cursorColor: kMatte,
                              style: Theme.of(context).textTheme.bodyText1,
                              decoration: InputDecoration(
                                hintText: "Access Code",
                                hintStyle:
                                    Theme.of(context).textTheme.bodyText1,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: kMatte,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kMatte),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: kQuiz),
                                ),
                              ),
                              onChanged: (value) {
                                access = value;
                              },
                              obscureText: true,
                            )),
                        SizedBox(
                          width: 32.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await getQuestions(access);
                          },
                          style: ElevatedButton.styleFrom(primary: kQuiz),
                          child: Padding(
                            padding: EdgeInsets.all(
                              12,
                            ),
                            child: Text(
                              'START',
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(color: kGlacier),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Row(
        key: ValueKey<int>(1),
        children: [
          Expanded(
            flex: !side ? 15 : 5,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 24.0, 0, 32.0),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PageTransitionSwitcher(
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    fillColor: Color(0x00000000),
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: displayQuestions(),
                reverse: !direction,
              ),
            ),
          ),
          Expanded(
            flex: side ? 2 : 1,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: kFrost,
                      ),
                    ),
                    if (!side)
                      RotatedBox(
                        quarterTurns: 3,
                        child: SizedBox(
                          height: 10,
                          child: LinearProgressIndicator(
                            valueColor: vicari,
                            value: _start,
                            backgroundColor: kFrost,
                          ),
                        ),
                      ),
                    Expanded(
                      flex: side ? 8 : 3,
                      child: Container(
                        child: Material(
                          elevation: 2.0,
                          child: Container(
                            color: kIgris,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 3.65),
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              side = !side;
                            });
                          },
                          child: side
                              ? Icon(Icons.chevron_right)
                              : Icon(Icons.chevron_left),
                          backgroundColor: kMatte,
                        ),
                      ],
                    ),
                    if (side)
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0,
                                MediaQuery.of(context).size.width * 0.02,
                                MediaQuery.of(context).size.width * 0.014,
                                MediaQuery.of(context).size.width * 0.02),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.1,
                              width: MediaQuery.of(context).size.width * 0.21,
                              child: Card(
                                elevation: 2,
                                color: kQuiz,
                                child: Center(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8),
                                                child: Text(
                                                  '${(_progress ~/ 60).toString().length == 2 ? (_progress ~/ 60) : '0' + (_progress ~/ 60).toString()} : ${((_progress % 60).truncate()).toString().length == 2 ? ((_progress % 60).truncate()) : '0' + ((_progress % 60).truncate()).toString()}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Minutes",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color: kFrost),
                                                  ),
                                                  SizedBox(width: 36),
                                                  Text(
                                                    "Seconds",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color: kFrost),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional.center,
                                          children: [
                                            SizedBox(
                                              height: 58.0,
                                              width: 58.0,
                                              child: CircleAvatar(
                                                backgroundColor: kIgris,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 64.0,
                                              width: 64.0,
                                              child: RotatedBox(
                                                quarterTurns: 2,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: _start,
                                                  valueColor: vicari,
                                                  strokeWidth: 6.0,
                                                ),
                                              ),
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
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0,
                                MediaQuery.of(context).size.width * 0.06,
                                MediaQuery.of(context).size.width * 0.014,
                                0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.21,
                              height: MediaQuery.of(context).size.height / 2.2,
                              child: Card(
                                elevation: 2,
                                color: kQuiz,
                                child: Container(
                                  margin: EdgeInsets.all(32),
                                  child: Scrollbar(
                                    child: SingleChildScrollView(
                                      child: Wrap(
                                        runAlignment: WrapAlignment.center,
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          for (int i = 0;
                                              i < quesset.length;
                                              i++)
                                            OptionButton(
                                              (i + 1).toString(),
                                              () async {
                                                if (!linear) {
                                                  int sum = current.fold(
                                                      0,
                                                      (previous, current) =>
                                                          previous + current);

                                                  if (colors[index] != 3 &&
                                                      sum > 0)
                                                    colors[index] = 1;
                                                  else if (colors[index] != 3 &&
                                                      answer.isNotEmpty)
                                                    colors[index] = 1;
                                                  else if (colors[index] != 3)
                                                    colors[index] = 2;
                                                  await savequestion(
                                                      int.parse(
                                                          quesset[index]['id']),
                                                      past,
                                                      current,
                                                      quesset);
                                                  direction = true;
                                                  if (index > i)
                                                    direction = false;
                                                  else if (index < i)
                                                    direction = true;
                                                  index = i;
                                                  if (!(quesset[index][
                                                              'questionType'] ==
                                                          'FITB' ||
                                                      quesset[index][
                                                              'questionType'] ==
                                                          'NUM' ||
                                                      quesset[index][
                                                              'questionType'] ==
                                                          'SHORT')) {
                                                    past = [];
                                                    for (int i = 0;
                                                        i <
                                                            quesset[index]
                                                                    ['answers']
                                                                .length;
                                                        i++)
                                                      past.add(int.parse(
                                                          quesset[index]
                                                                  ['answers'][i]
                                                              ['id']));
                                                    current =
                                                        List<int>.generate(
                                                            quesset[index]
                                                                    ['answers']
                                                                .length,
                                                            (int index) => 0);
                                                  } else
                                                    ans = (await getAnswerText(
                                                            int.parse(
                                                                quesset[index]
                                                                    ['id'])))
                                                        .replaceAll(
                                                            "</*n>", "\n");
                                                  ;
                                                  await getOptions(int.parse(
                                                      quesset[index]['id']));
                                                }
                                              },
                                              colors[i] == 0
                                                  ? kFrost
                                                  : (colors[i] == 1
                                                      ? kGreen
                                                      : colors[i] == 2
                                                          ? kYellow
                                                          : kRed),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Container displayQuestions() {
    ScrollController _scroll = new ScrollController();
    return Container(
      key: ValueKey<int>(index + 1),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scrollbar(
        controller: _scroll,
        child: SingleChildScrollView(
          controller: _scroll,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 24.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        color: kMatte,
                        onPressed: widget.goBack),
                    SizedBox(
                      width: 24.0,
                    ),
                    Text("${widget.quizname}",
                        style: Theme.of(context).textTheme.headline5),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Card(
                        elevation: 0,
                        color: kGlacier,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${index + 1}. ${quesset[index]['questionText']}",
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (quesset[index]['questionType'] ==
                                          'MCA')
                                        Text(
                                          "MCA",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      Text(
                                        quesset[index]['questionMark'] > 1
                                            ? "${quesset[index]['questionMark']} marks"
                                            : "${quesset[index]['questionMark']} mark",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (quesset[index]['questionType'] == 'FITB' ||
                                  quesset[index]['questionType'] == 'NUM' ||
                                  quesset[index]['questionType'] == 'SHORT')
                                SizedBox(height: 24.0),
                              if (quesset[index]['questionType'] == 'FITB' ||
                                  quesset[index]['questionType'] == 'NUM')
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: TextField(
                                      cursorColor: kMatte,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      decoration: InputDecoration(
                                        fillColor: kFrost,
                                        focusColor: kFrost,
                                        hintText: ans,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: kMatte),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: kQuiz),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        answer =
                                            value.replaceAll("\n", "</*n>");
                                      },
                                    ),
                                  ),
                                ),
                              if (quesset[index]['questionType'] == 'SHORT')
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.height - 40,
                                    child: TextField(
                                      cursorColor: kMatte,
                                      maxLines:
                                          MediaQuery.of(context).size.height ~/
                                              80,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      decoration: InputDecoration(
                                        fillColor: kFrost,
                                        focusColor: kFrost,
                                        hintText: ans,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: kMatte),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: kQuiz),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        answer =
                                            value.replaceAll("\n", "</*n>");
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!(quesset[index]['questionType'] == 'FITB' ||
                      quesset[index]['questionType'] == 'NUM' ||
                      quesset[index]['questionType'] == 'SHORT'))
                    for (int i = 0; i < (quesset[index]['answers'].length); i++)
                      Column(
                        children: [
                          SizedBox(
                            height: 16.0,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                            child: TextButton(
                              onPressed: () {
                                if (quesset[index]['questionType'] == 'SCA') {
                                  if (current[i] == 0)
                                    for (int j = 0; j < current.length; j++) {
                                      if (j == i) {
                                        current[j] = 1;
                                      } else {
                                        current[j] = 0;
                                      }
                                    }
                                  else {
                                    current[i] = 0;
                                  }
                                }
                                if (quesset[index]['questionType'] == 'MCA') {
                                  if (current[i] == 0) {
                                    current[i] = 1;
                                  } else {
                                    current[i] = 0;
                                  }
                                }
                                setState(() {});
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Card(
                                  elevation: 2,
                                  color: current[i] == 1 ? kIgris : kGlacier,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${(quesset[index]['questionType'] == 'SCA') ? String.fromCharCode(i + 65) + '. ' : ''}${quesset[index]['answers'][i]['answerText']}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                  color: current[i] == 1
                                                      ? kGlacier
                                                      : kMatte),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 36.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (index != 0 && !linear)
                              QuesButton(
                                  Icon(
                                    Icons.chevron_left,
                                    color: kMatte,
                                  ), () async {
                                if (index > 0) {
                                  int sum = current.fold(
                                      0,
                                      (previous, current) =>
                                          previous + current);

                                  if (colors[index] != 3 && sum > 0)
                                    colors[index] = 1;
                                  else if (colors[index] != 3 &&
                                      answer.isNotEmpty)
                                    colors[index] = 1;
                                  else if (colors[index] != 3)
                                    colors[index] = 2;
                                  await savequestion(
                                      int.parse(quesset[index]['id']),
                                      past,
                                      current,
                                      quesset);
                                  direction = false;
                                  index--;
                                  if (!(quesset[index]['questionType'] ==
                                          'FITB' ||
                                      quesset[index]['questionType'] == 'NUM' ||
                                      quesset[index]['questionType'] ==
                                          'SHORT')) {
                                    past = [];
                                    for (int i = 0;
                                        i < quesset[index]['answers'].length;
                                        i++)
                                      past.add(int.parse(
                                          quesset[index]['answers'][i]['id']));
                                    current = List<int>.generate(
                                        quesset[index]['answers'].length,
                                        (int index) => 0);
                                  } else
                                    ans = (await getAnswerText(
                                            int.parse(quesset[index]['id'])))
                                        .replaceAll("</*n>", "\n");
                                  await getOptions(
                                      int.parse(quesset[index]['id']));
                                }
                              }, kGlacier, "Previous"),
                            if (index != 0 && !linear)
                              SizedBox(
                                width: 10.0,
                              ),
                            QuesButton(
                                Icon(
                                  Icons.flag,
                                  color: kMatte,
                                ), () {
                              setState(() {
                                if (colors[index] != 3)
                                  colors[index] = 3;
                                else {
                                  colors[index] = 0;
                                  int sum = current.fold(
                                      0,
                                      (previous, current) =>
                                          previous + current);
                                  if (colors[index] != 3 && sum > 0)
                                    colors[index] = 1;
                                  else if (colors[index] != 3 &&
                                      answer.isNotEmpty)
                                    colors[index] = 1;
                                  else if (colors[index] != 3)
                                    colors[index] = 2;
                                }
                              });
                            }, colors[index] == 3 ? kRed : kGlacier, "Flag"),
                            if (index < quesset.length - 1)
                              SizedBox(
                                width: 10.0,
                              ),
                            if (index < quesset.length - 1)
                              QuesButton(
                                  Icon(
                                    Icons.chevron_right,
                                    color: kMatte,
                                  ), () async {
                                if (index < (quesset.length)) {
                                  int sum = current.fold(
                                      0,
                                      (previous, current) =>
                                          previous + current);
                                  if (colors[index] != 3 && sum > 0)
                                    colors[index] = 1;
                                  else if (colors[index] != 3 &&
                                      answer.isNotEmpty)
                                    colors[index] = 1;
                                  else if (colors[index] != 3)
                                    colors[index] = 2;
                                  await savequestion(
                                      int.parse(quesset[index]['id']),
                                      past,
                                      current,
                                      quesset);
                                  direction = true;
                                  index++;
                                  if (!(quesset[index]['questionType'] ==
                                          'FITB' ||
                                      quesset[index]['questionType'] == 'NUM' ||
                                      quesset[index]['questionType'] ==
                                          'SHORT')) {
                                    past = [];
                                    for (int i = 0;
                                        i < quesset[index]['answers'].length;
                                        i++)
                                      past.add(int.parse(
                                          quesset[index]['answers'][i]['id']));
                                    current = List<int>.generate(
                                        quesset[index]['answers'].length,
                                        (int index) => 0);
                                  } else
                                    ans = (await getAnswerText(
                                            int.parse(quesset[index]['id'])))
                                        .replaceAll("</*n>", "\n");
                                  await getOptions(
                                      int.parse(quesset[index]['id']));
                                }
                              }, kGlacier, "Next"),
                          ],
                        ),
                        Row(
                          children: [
                            QuesButton(
                                Icon(
                                  Icons.save,
                                  color: kMatte,
                                ), () async {
                              int sum = current.fold(
                                  0, (previous, current) => previous + current);
                              if (colors[index] != 3 && sum > 0)
                                colors[index] = 1;
                              else if (colors[index] != 3 && answer.isNotEmpty)
                                colors[index] = 1;
                              else if (colors[index] != 3) colors[index] = 2;
                              await savequestion(
                                  int.parse(quesset[index]['id']),
                                  past,
                                  current,
                                  quesset);
                            }, kGlacier, "Save"),
                            SizedBox(
                              width: 10.0,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await savequestion(
                                    int.parse(quesset[index]['id']),
                                    past,
                                    current,
                                    quesset);
                                _showMyDialog();
                              },
                              style: ElevatedButton.styleFrom(primary: kQuiz),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  12,
                                ),
                                child: Text(
                                  'SUBMIT',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(color: kGlacier),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Submit quiz?',
            style:
                Theme.of(context).textTheme.headline5.copyWith(color: kGlacier),
          ),
          backgroundColor: kMatte,
          content: Text(
            'On submitting all your current process will be saved and the quiz will be submitted for grading. In case you would like to continue answering questions, please use the navigation buttons on either side of the flag option. Also by using the navigation buttons, your current answers are saved when you move to a different question.',
            style:
                Theme.of(context).textTheme.bodyText1.copyWith(color: kFrost),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCEL',
                style: Theme.of(context).textTheme.button.copyWith(color: kRed),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(width: 20),
            TextButton(
              onPressed: () async {
                await _quiz.queryA(gq.calculate(userId, widget.id));
                widget.goBackPlus.call();
              },
              child: Text(
                'SUBMIT',
                style:
                    Theme.of(context).textTheme.button.copyWith(color: kQuiz),
                textAlign: TextAlign.end,
              ),
            ),
            SizedBox(width: 10),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    ag = new AuthGraphQL();
    ag.setAuth(Provider.of<Token>(context, listen: false).getToken());
    _quiz = ag.getClient();
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            fillColor: Color(0x00000000),
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: swaper(),
        reverse: !proceed,
      ),
    );
  }
}
