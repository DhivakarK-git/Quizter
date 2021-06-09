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
import 'dart:math';
import 'package:quizter/widgets/option_button.dart';
import 'package:quizter/widgets/ques_button.dart';

class QuizScreen extends StatefulWidget {
  final String quizname, accesscode;
  final int quizId;
  final Function goBackPlus;
  QuizScreen(this.quizId, this.quizname, this.accesscode, this.goBackPlus);
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  final _formPublish = GlobalKey<FormState>();
  var _formQuiz = [GlobalKey<FormState>()];
  final _formMarks = GlobalKey<FormState>();
  var superques = [],
      quesset = [],
      current = [],
      option = [],
      feedback = [],
      optset = [],
      marks = [],
      courses = ['------'],
      classes = [],
      teaches = [],
      colors = [],
      students = [],
      studentsCopy = [],
      assignedto = [];
  DateTime starttime, endtime, publishtime;
  bool proceed = false,
      publish = false,
      direction = true,
      shuffle = false,
      linear = true,
      nemail = false;
  int index = 0,
      userId = -1,
      f = 0,
      nq,
      posmark = 0,
      negmark = 0,
      noofoptions = 0,
      duration = 15,
      noofs = 1;
  String answer = "",
      feed = "",
      question = "",
      ans = "",
      dropdownValue = 'Single Correct Answer',
      course = '';
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String parseDate(String dt) {
    return (dt.substring(8, 10) + dt.substring(4, 8) + dt.substring(0, 4));
  }

  String parseTime(String t) {
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

  Future<void> _setQuiz() async {
    final QueryResult quiz = await _quiz.queryA(gq.getEQuiz(widget.quizId));
    var temp = quiz.data['me']['usert']['makesSet'][0]['quiz'];
    starttime = DateTime.parse(temp['startTime']);
    endtime = DateTime.parse(temp['endTime']);
    try {
      publishtime = DateTime.parse(temp['publishTime']);
    } catch (exception) {
      publishtime = null;
    }
    linear = temp['linear'];
    shuffle = temp['shuffle'];
    noofs = temp['timesCanTake'];
    duration = temp['duration'];
    temp = quiz.data['me']['usert']['makesSet'][0]['quiz']['questions'];
    for (int i = 0; i < temp.length; i++) {
      quesset.add(int.parse(temp[i]['id']));
      colors.add(0);
      marks.add(temp[i]['questionMark']);
      _formQuiz.add(GlobalKey<FormState>());
    }
    nq = temp.length;
  }

  Future<DateTime> _selectDate(BuildContext context, DateTime date) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.highContrastDark().copyWith(
            primary: kFrost,
            background: kMatte,
            surface: kMatte,
          )),
          child: child,
        );
      },
    );
    if (picked != null && picked != date)
      setState(() {
        date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          date.hour,
          date.minute,
        );
      });

    return date;
  }

  Future<TimeOfDay> _selectTime(BuildContext context, TimeOfDay time) async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.highContrastDark().copyWith(
            primary: kFrost,
            background: kMatte,
            surface: kMatte,
          )),
          child: child,
        );
      },
    );
    if (picked != null && picked != time)
      setState(() {
        time = picked;
      });
    return time;
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> getQuestions() async {
    final QueryResult quiz = await _quiz.queryA(gq.getFQuiz(widget.quizId));
    var temp = quiz.data['me']['usert']['makesSet'][0]['quiz']['questions'];
    for (int i = 0; i < temp.length; i++) {
      if (quesset[index] == int.parse(temp[i]['id'])) {
        question = temp[i]['questionText'];
        posmark = temp[i]['questionMark'];
        negmark = -1 * temp[i]['questionNMark'];
        String type = (temp[i]['questionType']).toString().toLowerCase();
        if (type == 'sca') {
          dropdownValue = 'Single Correct Answer';
        } else if (type == 'mca') {
          dropdownValue = 'Multiple Correct Answer';
        } else if (type == 'num') {
          dropdownValue = 'Numerical';
        } else if (type == 'fitb') {
          dropdownValue = 'Fill In The Blanks';
        } else if (type == 'short') {
          dropdownValue = 'Short Answer';
        }
        var answ = temp[i]['answers'];
        current = [];
        option = [];
        for (int j = 0; j < answ.length; j++) {
          noofoptions++;
          if (type == 'num' || type == 'fitb') {
            answer = answ[j]['answerText'];
            feed = answ[j]['feedback'];
            break;
          } else if (type == 'sca' || type == 'mca') {
            option.add(answ[j]['answerText']);
            feedback.add(answ[j]['feedback']);
            current.add(answ[j]['correct'] ? 1 : 0);
          }
        }
      }
    }
  }

  void getTeaches() async {
    final QueryResult quiz = await _quiz.queryA(gq.getteaches());
    var temp = quiz.data['me']['usert']['teachesSet'];
    for (int i = 0; i < temp.length; i++) {
      var bt = [];
      for (int j = 0; j < temp[i]['clas']['belongsSet'].length; j++) {
        bt.add([
          temp[i]['clas']['belongsSet'][j]['user']['user']['username'],
          temp[i]['clas']['belongsSet'][j]['user']['id']
        ]);
      }
      teaches.add(
          [temp[i]['course']['courseId'], temp[i]['clas']['className'], bt]);
      if (!courses.contains(temp[i]['course']['courseId']))
        courses.add(temp[i]['course']['courseId']);
      course = '------';
    }
  }

  Future<void> saveQuestions() async {
    String type;
    if (dropdownValue == 'Single Correct Answer') {
      type = 'sca';
    } else if (dropdownValue == 'Multiple Correct Answer') {
      type = 'mca';
    } else if (dropdownValue == 'Numerical') {
      type = 'num';
    } else if (dropdownValue == 'Fill In The Blanks') {
      type = 'fitb';
    } else if (dropdownValue == 'Short Answer') {
      type = 'short';
    }
    if (quesset[index] == -1) {
      final QueryResult quiz = await _quiz.queryA(gq.saveQuestion(
          quizId: widget.quizId,
          question: question,
          type: type,
          pmark: posmark,
          nmark: -1 * negmark));
      quesset[index] = int.parse(quiz.data['createQuestion']['question']['id']);
      marks[index] = posmark;
    } else {
      final QueryResult quiz = await _quiz.queryA(gq.updateQuestion(
          quesId: quesset[index],
          quizId: widget.quizId,
          question: question,
          type: type,
          pmark: posmark,
          nmark: -1 * negmark));
      marks[index] = posmark;
      var anss = quiz.data['updateQuestion']['question']['answers'];
      for (int i = 0; i < anss.length; i++) {
        final QueryResult answer = await _quiz.queryA(gq.deleteFAnswer(
          quesId: quesset[index],
          answer: anss[i]['answerText'],
        ));
      }
    }
    if (dropdownValue == 'Single Correct Answer' ||
        dropdownValue == 'Multiple Correct Answer') {
      for (int i = 0; i < option.length; i++) {
        final QueryResult answer = await _quiz.queryA(gq.saveFAnswer(
          quesId: quesset[index],
          answer: option[i],
          correct: current[i] == 1 ? true : false,
          feedback: feedback[i],
        ));
      }
    } else if (dropdownValue == 'Numerical' ||
        dropdownValue == 'Fill In The Blanks') {
      if (answer.isNotEmpty) {
        final QueryResult ans = await _quiz.queryA(gq.saveFAnswer(
          quesId: quesset[index],
          answer: answer,
          correct: true,
          feedback: feed == null || feed.isEmpty ? '' : feed,
        ));
      }
    }
    setState(() {});
  }

  String changedate(String dt) {
    dt = dt.substring(0, 10) + 'T' + dt.substring(11, 19);
    return dt;
  }

  Future<void> publishQuiz() async {
    if (_formPublish.currentState.validate() &&
        starttime != null &&
        endtime != null &&
        classes.isNotEmpty) {
      final QueryResult quiz = await _quiz.queryA(
        gq.updateTQuiz(
          quizname: widget.quizname,
          accesscode: widget.accesscode,
          start: changedate(starttime.toString()),
          end: changedate(endtime.toString()),
          publish: publishtime != null
              ? publishtime.toString().substring(0, 19)
              : "",
          linear: linear,
          shuffle: shuffle,
          duration: duration,
          times: noofs,
          marks: (marks.fold(
              0, (previousValue, element) => previousValue + element)),
          course: course,
        ),
      );
      if (quiz.data['updateQuiz']['ok'] == true) {
        final QueryResult takes =
            await _quiz.queryA(gq.takersList(widget.quizId));
        var temp = takes.data['me']['usert']['makesSet'][0]['quiz']['takers'];
        // for (int i = 0; i < temp.length; i++) {
        //   final QueryResult publish = await _quiz.queryA(gq.removeTakes(
        //       userId: int.parse(temp[i]['user']['id']), quizId: widget.quizId));
        // }
        final QueryResult cla = await _quiz.queryA(gq.classList());
        temp = cla.data['me']['usert']['teachesSet'];
        for (int i = 0; i < temp.length; i++) {
          if (assignedto.contains(temp[i]['clas']['className'])) {
            var tem = temp[i]['clas']['belongsSet'];
            for (int j = 0; j < tem.length; j++) {
              final QueryResult publish = await _quiz.queryA(gq.setTakes(
                  userId: int.parse(tem[j]['user']['id']),
                  quizId: widget.quizId,
                  nemail: nemail));
            }
          } else {
            var tem = temp[i]['clas']['belongsSet'];
            for (int j = 0; j < tem.length; j++) {
              if (assignedto.contains(tem[j]['user']['user']['username']))
                final QueryResult publish = await _quiz.queryA(gq.setTakes(
                    userId: int.parse(tem[j]['user']['id']),
                    quizId: widget.quizId,
                    nemail: nemail));
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 5),
            elevation: 4,
            backgroundColor: kMatte,
            content: Text(
              'The quiz has been successfully published.',
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
            )));
        widget.goBackPlus.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 5),
            elevation: 4,
            backgroundColor: kMatte,
            content: Text(
              'There seems to be an error from our end. However, Please do check the details and try once again later.',
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
            )));
      }
    } else if (starttime == null || endtime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          elevation: 4,
          backgroundColor: kMatte,
          content: Text(
            'Please do set date and time for start, end and publish time.',
            style:
                Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
          )));
    } else if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          elevation: 4,
          backgroundColor: kMatte,
          content: Text(
            'Please do select a course to apply the quiz to.',
            style:
                Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
          )));
    } else if (publishtime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          elevation: 4,
          backgroundColor: kMatte,
          content: Text(
            'Since Publish Time was not set, the quiz scores and feedback will not be released to the students.',
            style:
                Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
          )));
    }
  }

  Widget swaper() {
    String access = '';
    if (!proceed && !publish) {
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
                        icon: Icon(Icons.arrow_back),
                        onPressed: widget.goBackPlus),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.height * 0.8,
                        child: Text(
                          '${widget.quizname}',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
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
                                      "Important Pointors regarding the changes made to a quiz",
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                    Container(
                                      child: Text(
                                        '''

• Check the questions thoroughly and give correct answers for the questions asked.

• Make sure to have a good internet connection, for uploading the questions.

• Do not refresh the page while uploading questions on a quiz.

• Do not unnecessarily refresh the page during a quiz.

• Do not use navigation options from the chrome browser.

• Choose the quiz as linear access or nonlinear access, purely a choice of opinion of the faculty conducting the quiz. 

• For quizzes faculty can choose to award negative marks for incorrect answer and the standard marking scheme is as follows:
      +1 for correct answer and -0.25 for incorrect answer
      (Note: Faculty can also give their own marking scheme)

• For multiple correct answers, MCA must be mentioned on the top of the question.

• Time limit should be set for every quiz, so as to assess students’ time management capability.

• Faculty can decide the date and time to set the feedback visible for a particular quiz.

• Faculty can correct the key of quiz if any unforeseen errors are found and alter the outcome of the quiz.

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
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await _setQuiz();
                              if (quesset.isEmpty) {
                                quesset = [-1];
                                nq = 1;
                                marks = [0];
                                colors = [0];
                                _formQuiz = [GlobalKey<FormState>()];
                              }
                            } catch (e) {
                              quesset = [-1];
                              nq = 1;
                              marks = [0];
                              colors = [0];
                              _formQuiz = [GlobalKey<FormState>()];
                            }
                            await getQuestions();
                            setState(() {
                              proceed = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(primary: kQuiz),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                            child: Text(
                              'EDIT',
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
    } else if (publish) {
      return Container(
        key: ValueKey<int>(-1),
        margin: EdgeInsets.fromLTRB(56.0, 24.0, 56.0, 32.0),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formPublish,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(36, 0, 0, 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Tooltip(
                        message: "Quiz Title",
                        child: Text(
                          "${widget.quizname}",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Wrap(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.width > 1268
                                ? 3.9
                                : 2),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Access Code:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${widget.accesscode}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.width > 1268
                                ? 3.9
                                : 2),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Total Marks:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${marks.fold(0, (previous, current) => previous + current)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Wrap(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Tooltip(
                                                message: "Click to clear time",
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      starttime = null;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Start Time:',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${starttime == null ? 'Enter Time' : parseTime(starttime.toString())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  starttime = starttime == null
                                                      ? DateTime.now()
                                                      : starttime;
                                                  TimeOfDay inter =
                                                      await _selectTime(
                                                          context,
                                                          TimeOfDay
                                                              .fromDateTime(
                                                                  starttime));
                                                  starttime = DateTime(
                                                    starttime.year,
                                                    starttime.month,
                                                    starttime.day,
                                                    inter.hour,
                                                    inter.minute,
                                                  );
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.schedule,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${starttime == null ? 'Enter Date' : parseDate(starttime.toString())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  starttime = starttime == null
                                                      ? DateTime.now()
                                                      : starttime;
                                                  DateTime inter =
                                                      await _selectDate(
                                                          context, starttime);
                                                  starttime = DateTime(
                                                    inter.year,
                                                    inter.month,
                                                    inter.day,
                                                    starttime.hour,
                                                    starttime.minute,
                                                  );
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.calendar_today,
                                                  ),
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
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Tooltip(
                                                message: "Click to clear time",
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      endtime = null;
                                                    });
                                                  },
                                                  child: Text(
                                                    'End Time:',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${endtime == null ? 'Enter Time' : parseTime(endtime.toString())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  endtime = endtime == null
                                                      ? DateTime.now()
                                                      : endtime;
                                                  TimeOfDay inter =
                                                      await _selectTime(
                                                          context,
                                                          TimeOfDay
                                                              .fromDateTime(
                                                                  endtime));
                                                  endtime = DateTime(
                                                    endtime.year,
                                                    endtime.month,
                                                    endtime.day,
                                                    inter.hour,
                                                    inter.minute,
                                                  );
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.schedule,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${endtime == null ? 'Enter Date' : parseDate(endtime.toString())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  endtime = endtime == null
                                                      ? DateTime.now()
                                                      : endtime;
                                                  DateTime inter =
                                                      await _selectDate(
                                                          context, endtime);
                                                  endtime = DateTime(
                                                    inter.year,
                                                    inter.month,
                                                    inter.day,
                                                    endtime.hour,
                                                    endtime.minute,
                                                  );
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.calendar_today,
                                                  ),
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
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.75,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Tooltip(
                                                message: "Click to clear time",
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      publishtime = null;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Publish Time:',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${publishtime == null ? 'Enter Time' : parseTime(publishtime.toString())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  publishtime =
                                                      publishtime == null
                                                          ? DateTime.now()
                                                          : publishtime;
                                                  TimeOfDay inter =
                                                      await _selectTime(
                                                          context,
                                                          TimeOfDay
                                                              .fromDateTime(
                                                                  publishtime));
                                                  publishtime = DateTime(
                                                    publishtime.year,
                                                    publishtime.month,
                                                    publishtime.day,
                                                    inter.hour,
                                                    inter.minute,
                                                  );
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.schedule,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${publishtime == null ? 'Enter Date' : parseDate(publishtime.toString())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  publishtime =
                                                      publishtime == null
                                                          ? DateTime.now()
                                                          : publishtime;
                                                  DateTime inter =
                                                      await _selectDate(
                                                          context, publishtime);
                                                  publishtime = DateTime(
                                                    inter.year,
                                                    inter.month,
                                                    inter.day,
                                                    publishtime.hour,
                                                    publishtime.minute,
                                                  );
                                                  setState(() {});
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.calendar_today,
                                                  ),
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (classes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        elevation: 2,
                        color: kGlacier,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Assigned To:',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Tooltip(
                                    message:
                                        "Please ensure that if individual students are selected, if you wish to select all students in a class; dont have the class selected as well.",
                                    child: Wrap(
                                      children: [
                                        for (int k = 0;
                                            k < assignedto.length;
                                            k++)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: InputChip(
                                              padding: EdgeInsets.all(2.0),
                                              label: Text('${assignedto[k]}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button),
                                              selected: false,
                                              onDeleted: () {
                                                if (assignedto[k]
                                                        .toString()
                                                        .length <
                                                    10)
                                                  setState(() {
                                                    classes.add(assignedto[k]
                                                        .toString());
                                                    students =
                                                        studentsCopy.toList();
                                                    assignedto.removeAt(k);
                                                    for (int l = 0;
                                                        l < assignedto.length;
                                                        l++) {
                                                      int m = 0;
                                                      while (
                                                          m < students.length) {
                                                        if (students[m][1] ==
                                                            assignedto[l])
                                                          students.removeAt(m);
                                                        else if (students[m]
                                                                [0] ==
                                                            assignedto[l])
                                                          students.removeAt(m);
                                                        else
                                                          m++;
                                                      }
                                                    }
                                                  });
                                                else
                                                  setState(() {
                                                    students =
                                                        studentsCopy.toList();
                                                    assignedto.removeAt(k);
                                                    for (int l = 0;
                                                        l < assignedto.length;
                                                        l++) {
                                                      int m = 0;
                                                      while (
                                                          m < students.length) {
                                                        if (students[m][1] ==
                                                            assignedto[l])
                                                          students.removeAt(m);
                                                        else if (students[m]
                                                                [0] ==
                                                            assignedto[l])
                                                          students.removeAt(m);
                                                        else
                                                          m++;
                                                      }
                                                    }
                                                  });
                                                students.sort((a, b) =>
                                                    a[0].compareTo(b[0]));
                                                classes.sort();
                                              },
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  if (classes.length > 1 && students.length > 0)
                                    Tooltip(
                                      message:
                                          "You can add classes or individual students",
                                      child: DropdownButton<String>(
                                        value: classes[0],
                                        onChanged: (String newValue) {
                                          if (classes.contains(newValue) &&
                                              newValue != '------') {
                                            classes.remove(newValue);
                                          }
                                          int k = 0;
                                          while (k < students.length) {
                                            if (students[k][1] == newValue)
                                              students.removeAt(k);
                                            else if (students[k][0] == newValue)
                                              students.removeAt(k);
                                            else {
                                              k++;
                                            }
                                          }
                                          setState(() {
                                            if (newValue != '------')
                                              assignedto.add(newValue);
                                          });
                                        },
                                        items: classes
                                                .map<DropdownMenuItem<String>>(
                                                    (value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button,
                                                ),
                                              );
                                            }).toList() +
                                            students
                                                .map<DropdownMenuItem<String>>(
                                                    (value) {
                                              return DropdownMenuItem<String>(
                                                value: value[0],
                                                child: Text(
                                                  value[0],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Wrap(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3.9,
                        child: Card(
                          elevation: 2,
                          color: kGlacier,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Course:',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    DropdownButton<String>(
                                      value: course,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          course = newValue;
                                          classes = ['------'];
                                          students = [];
                                          assignedto = [];
                                          for (int i = 0;
                                              i < teaches.length;
                                              i++) {
                                            if (teaches[i][0] == course) {
                                              classes.add(teaches[i][1]);
                                              for (int j = 0;
                                                  j < teaches[i][2].length;
                                                  j++) {
                                                students.add([
                                                  teaches[i][2][j][0],
                                                  classes.last
                                                ]);
                                              }
                                            }
                                          }
                                          students.sort(
                                              (a, b) => a[0].compareTo(b[0]));
                                          studentsCopy = students.toList();
                                          classes.sort();
                                        });
                                      },
                                      items: courses
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .button,
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Duration:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          cursorColor: kMatte,
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          decoration: InputDecoration(
                                            fillColor: kFrost,
                                            focusColor: kFrost,
                                            hintText: '$duration',
                                            suffixText: 'mins',
                                            suffixStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(color: kRed),
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                    color:
                                                        kMatte.withAlpha(189)),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: kMatte),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: kQuiz),
                                            ),
                                          ),
                                          validator: (value) {
                                            try {
                                              int x = int.parse(value);
                                              if (x < 1 || duration < 1) {
                                                return "+ve value";
                                              } else
                                                return null;
                                            } catch (e) {
                                              if (duration < 1)
                                                return "+ve value";
                                              else
                                                return null;
                                            }
                                          },
                                          onChanged: (value) {
                                            duration = int.parse(value);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.75,
                        child: Card(
                          elevation: 2,
                          color: kGlacier,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        'No. of Submissions Allowed:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        cursorColor: kMatte,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        decoration: InputDecoration(
                                          fillColor: kFrost,
                                          focusColor: kFrost,
                                          hintText: '$noofs',
                                          errorStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(color: kRed),
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                  color: kMatte.withAlpha(189)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMatte),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kQuiz),
                                          ),
                                        ),
                                        validator: (value) {
                                          try {
                                            int x = int.parse(value);
                                            if (x < 1 || noofs < 1) {
                                              return "+ve value";
                                            } else
                                              return null;
                                          } catch (e) {
                                            if (noofs < 1)
                                              return "+ve value";
                                            else
                                              return null;
                                          }
                                        },
                                        onChanged: (value) {
                                          noofs = int.parse(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Wrap(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Linear Access:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Expanded(
                                        child: Switch(
                                          value: linear,
                                          activeColor: kIgris,
                                          onChanged: (bool value) {
                                            setState(() {
                                              linear = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.9,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Shuffle:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Expanded(
                                        child: Switch(
                                          value: shuffle,
                                          activeColor: kIgris,
                                          onChanged: (bool value) {
                                            setState(() {
                                              shuffle = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.75,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Card(
                            elevation: 2,
                            color: kGlacier,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Email Notification:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Expanded(
                                        child: Switch(
                                          value: nemail,
                                          activeColor: kIgris,
                                          onChanged: (bool value) {
                                            setState(() {
                                              nemail = value;
                                            });
                                          },
                                        ),
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
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 24.0, horizontal: 36.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            primary: kMatte,
                            side: BorderSide(color: kMatte),
                          ),
                          onPressed: widget.goBackPlus,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 8.0),
                            child: Text("SAVE DRAFT",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: kMatte)),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await saveQuestions();
                          await publishQuiz();
                        },
                        style: ElevatedButton.styleFrom(primary: kQuiz),
                        child: Padding(
                          padding: EdgeInsets.all(
                            12,
                          ),
                          child: Text(
                            'PUBLISH',
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
          ),
        ),
      );
    } else {
      return Row(
        key: ValueKey<int>(1),
        children: [
          Expanded(
            flex: 5,
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
            flex: 2,
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
                    Expanded(
                      flex: 8,
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // SizedBox(width: 56.0),
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
                                color: kGlacier,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Marks",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                    Form(
                                      key: _formMarks,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  16,
                                              child: Tooltip(
                                                message: "Add Marks",
                                                child: TextFormField(
                                                  cursorColor: kMatte,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                  decoration: InputDecoration(
                                                    fillColor: kFrost,
                                                    focusColor: kFrost,
                                                    hintText:
                                                        posmark.toString(),
                                                    hintStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                    errorStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            .copyWith(
                                                                color: kMatte),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: kMatte),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: kGreen,
                                                          width: 3),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    try {
                                                      int x = int.parse(value);
                                                      if (x < 0 ||
                                                          posmark < 0) {
                                                        return "+ve value";
                                                      } else
                                                        return null;
                                                    } catch (e) {
                                                      if (posmark < 0)
                                                        return "+ve value";
                                                      else
                                                        return null;
                                                    }
                                                  },
                                                  onFieldSubmitted: (value) {
                                                    if (_formMarks.currentState
                                                        .validate())
                                                      setState(() {});
                                                  },
                                                  onChanged: (value) {
                                                    posmark = int.parse(value);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  16,
                                              child: Tooltip(
                                                message: "Negative Marking",
                                                child: TextFormField(
                                                  cursorColor: kMatte,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                  decoration: InputDecoration(
                                                    fillColor: kFrost,
                                                    focusColor: kFrost,
                                                    hintText:
                                                        negmark.toString(),
                                                    hintStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                    errorStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            .copyWith(
                                                                color: kMatte),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: kMatte),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: kRed,
                                                          width: 3),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    try {
                                                      int x = int.parse(value);
                                                      if (x < 0 ||
                                                          negmark < 0) {
                                                        return "+ve value";
                                                      } else
                                                        return null;
                                                    } catch (e) {
                                                      if (negmark < 0)
                                                        return "+ve value";
                                                      else
                                                        return null;
                                                    }
                                                  },
                                                  onFieldSubmitted: (value) {
                                                    if (_formMarks.currentState
                                                        .validate())
                                                      setState(() {});
                                                  },
                                                  onChanged: (value) {
                                                    negmark = int.parse(value);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
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
                                        for (int i = 0; i < nq; i++)
                                          OptionButton((i + 1).toString(),
                                              () async {
                                            answer = '';
                                            feed = '';
                                            current = [];
                                            option = [];
                                            feedback = [];
                                            question = '';
                                            noofoptions = 0;
                                            if (index > i)
                                              direction = false;
                                            else
                                              direction = true;
                                            if (i >= 0 && i < nq) index = i;
                                            dropdownValue =
                                                "Single Correct Answer";
                                            if (quesset[index] != -1)
                                              await getQuestions();
                                            setState(() {});
                                          },
                                              colors[i] == 1
                                                  ? kRed
                                                  : (quesset[i] == -1
                                                      ? kFrost
                                                      : kGreen)),
                                        QuesButton(
                                            Icon(
                                              Icons.add,
                                              color: kMatte,
                                            ), () {
                                          setState(() {
                                            quesset.add(-1);
                                            colors.add(0);
                                            marks.add(0);
                                            _formQuiz
                                                .add(GlobalKey<FormState>());
                                            nq++;
                                          });
                                        }, kGlacier, "Add Question"),
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
          child: Form(
            key: _formQuiz[index],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 24.0),
                  child: Row(
                    children: [
                      Text(
                        "${widget.quizname}",
                        style: Theme.of(context).textTheme.headline5,
                      ),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${index + 1}. ',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        cursorColor: kMatte,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        decoration: InputDecoration(
                                          fillColor: kFrost,
                                          focusColor: kFrost,
                                          hintText: question.isEmpty
                                              ? "Enter the Question"
                                              : question,
                                          errorStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(color: kRed),
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                  color: kMatte.withAlpha(189)),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kMatte),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: kQuiz),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (question.isEmpty) {
                                            return '*Required';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          question =
                                              value.replaceAll("\n", "</*n>");
                                        },
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: dropdownValue,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          dropdownValue = newValue;
                                        });
                                      },
                                      items: <String>[
                                        'Single Correct Answer',
                                        'Multiple Correct Answer',
                                        'Fill In The Blanks',
                                        'Short Answer',
                                        'Numerical'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .button,
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (dropdownValue == 'Numerical' ||
                        dropdownValue == 'Fill In The Blanks')
                      Column(
                        children: [
                          SizedBox(
                            height: 16.0,
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Card(
                                    elevation: 2,
                                    color: kGlacier,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            cursorColor: kMatte,
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(color: kMatte),
                                            decoration: InputDecoration(
                                              fillColor: kFrost,
                                              focusColor: kFrost,
                                              hintText: answer == null ||
                                                      answer.isEmpty
                                                  ? "Enter Correct Answer"
                                                  : answer,
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(color: kMatte),
                                              errorStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(color: kRed),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide:
                                                    BorderSide(color: kMatte),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide:
                                                    BorderSide(color: kQuiz),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              answer = value.replaceAll(
                                                  "\n", "</*n>");
                                            },
                                            validator: (value) {
                                              if (answer.isEmpty) {
                                                return '*Required';
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            cursorColor: kMatte,
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(color: kMatte),
                                            decoration: InputDecoration(
                                              fillColor: kFrost,
                                              focusColor: kFrost,
                                              hintText: feed == null ||
                                                      feed.isEmpty ||
                                                      feed == 'null'
                                                  ? "Feedback"
                                                  : feed,
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .copyWith(color: kMatte),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide:
                                                    BorderSide(color: kMatte),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide:
                                                    BorderSide(color: kQuiz),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              feed = (value.replaceAll(
                                                  "\n", "</*n>"));
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (dropdownValue == 'Single Correct Answer' ||
                        dropdownValue == 'Multiple Correct Answer')
                      Column(
                        children: [
                          SizedBox(
                            height: 16.0,
                          ),
                          for (int i = 0; i < noofoptions; i++)
                            Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 0, 0, 4),
                                        child: QuesButton(
                                            Icon(
                                              Icons.done,
                                              color: current[i] == 0
                                                  ? kMatte
                                                  : kGlacier,
                                            ), () {
                                          if (dropdownValue ==
                                              'Single Correct Answer') {
                                            if (current[i] == 0)
                                              for (int j = 0;
                                                  j < current.length;
                                                  j++) {
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
                                          if (dropdownValue ==
                                              'Multiple Correct Answer') {
                                            if (current[i] == 0) {
                                              current[i] = 1;
                                            } else {
                                              current[i] = 0;
                                            }
                                          }
                                          setState(() {});
                                        }, current[i] == 1 ? kIgris : kGlacier,
                                            "Correct"),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.85,
                                        child: Card(
                                          elevation: 2,
                                          color: current[i] == 1
                                              ? kIgris
                                              : kGlacier,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  cursorColor: current[i] == 1
                                                      ? kGlacier
                                                      : kMatte,
                                                  maxLines: null,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: current[i] == 1
                                                              ? kGlacier
                                                              : kMatte),
                                                  decoration: InputDecoration(
                                                    fillColor: kFrost,
                                                    focusColor: kFrost,
                                                    hintText: option[i]
                                                            .toString()
                                                            .isEmpty
                                                        ? "Enter your Option"
                                                        : option[i].toString(),
                                                    errorStyle:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            .copyWith(
                                                                color: kRed),
                                                    hintStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color:
                                                                current[i] == 1
                                                                    ? kGlacier
                                                                    : kMatte),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: current[i] == 1
                                                              ? kGlacier
                                                              : kMatte),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: current[i] == 1
                                                              ? kFrost
                                                              : kQuiz),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (option[i]
                                                        .toString()
                                                        .isEmpty) {
                                                      return '*Required';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    option[i] =
                                                        value.replaceAll(
                                                            "\n", "</*n>");
                                                  },
                                                ),
                                                TextFormField(
                                                  cursorColor: current[i] == 1
                                                      ? kGlacier
                                                      : kMatte,
                                                  maxLines: null,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: current[i] == 1
                                                              ? kGlacier
                                                              : kMatte),
                                                  decoration: InputDecoration(
                                                    fillColor: kFrost,
                                                    focusColor: kFrost,
                                                    hintText: feedback[i]
                                                                .toString()
                                                                .isEmpty ||
                                                            feedback[i]
                                                                    .toString() ==
                                                                'null'
                                                        ? "Feedback"
                                                        : feedback[i]
                                                            .toString(),
                                                    hintStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .copyWith(
                                                            color:
                                                                current[i] == 1
                                                                    ? kGlacier
                                                                    : kMatte),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: current[i] == 1
                                                              ? kGlacier
                                                              : kMatte),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: current[i] == 1
                                                              ? kFrost
                                                              : kQuiz),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    feedback[i] =
                                                        value.replaceAll(
                                                            "\n", "</*n>");
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                              ],
                            ),
                          SizedBox(
                            width: 16.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              QuesButton(Icon(Icons.add, color: kMatte), () {
                                setState(() {
                                  noofoptions++;
                                  option.add('');
                                  feedback.add('');
                                  current.add(0);
                                });
                              }, kGlacier, "Add Option"),
                              SizedBox(
                                width: 16.0,
                              ),
                              QuesButton(Icon(Icons.remove, color: kMatte), () {
                                setState(() {
                                  option.removeAt(noofoptions - 1);
                                  feedback.removeAt(noofoptions - 1);
                                  current.removeAt(noofoptions - 1);
                                  noofoptions--;
                                });
                              }, kGlacier, "Remove Option"),
                            ],
                          )
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
                              if (index != 0)
                                QuesButton(
                                    Icon(
                                      Icons.chevron_left,
                                      color: kMatte,
                                    ), () async {
                                  answer = '';
                                  feed = '';
                                  question = '';
                                  current = [];
                                  option = [];
                                  feedback = [];
                                  noofoptions = 0;
                                  if (index > 0) {
                                    index--;
                                    dropdownValue = "Single Correct Answer";
                                    if (quesset[index] != -1)
                                      await getQuestions();
                                  }
                                  setState(() {});
                                }, kGlacier, "Previous"),
                              if (index != 0)
                                SizedBox(
                                  width: 10.0,
                                ),
                              QuesButton(
                                  Icon(
                                    Icons.flag,
                                    color: kMatte,
                                  ), () {
                                setState(() {
                                  colors[index] = colors[index] == 1 ? 0 : 1;
                                });
                              }, colors[index] == 1 ? kRed : kGlacier, "Flag"),
                              SizedBox(
                                width: 10.0,
                              ),
                              if (index < (nq - 1))
                                QuesButton(
                                    Icon(
                                      Icons.chevron_right,
                                      color: kMatte,
                                    ), () async {
                                  answer = '';
                                  feed = '';
                                  current = [];
                                  option = [];
                                  feedback = [];
                                  noofoptions = 0;
                                  question = '';
                                  if (index < nq) {
                                    index++;
                                    dropdownValue = "Single Correct Answer";
                                    if (quesset[index] != -1)
                                      await getQuestions();
                                  }
                                  setState(() {});
                                }, kGlacier, "Next"),
                            ],
                          ),
                          Row(
                            children: [
                              QuesButton(
                                  Icon(
                                    Icons.content_copy,
                                    color: kMatte,
                                  ), () async {
                                await _getAllQuestions();
                                await _showImport();
                              }, kGlacier, "Duplicate"),
                              SizedBox(
                                width: 10.0,
                              ),
                              QuesButton(
                                  Icon(
                                    Icons.delete,
                                    color: kMatte,
                                  ), () async {
                                if (nq > 1) {
                                  if (quesset[index] != -1) {
                                    final QueryResult answer =
                                        await _quiz.queryA(gq.deleteQuestion(
                                      id: quesset[index],
                                    ));
                                  }
                                  quesset.removeAt(index);
                                  colors.removeAt(index);
                                  marks.removeAt(index);
                                  _formQuiz.removeAt(index);
                                  nq--;
                                  if (index > 0 || index < nq) {
                                    answer = '';
                                    feed = '';
                                    question = '';
                                    current = [];
                                    option = [];
                                    feedback = [];
                                    noofoptions = 0;
                                    if (index < nq) {
                                      dropdownValue = "Single Correct Answer";
                                      if (quesset[index] != -1)
                                        await getQuestions();
                                    } else {
                                      index--;
                                      dropdownValue = "Single Correct Answer";
                                      if (quesset[index] != -1)
                                        await getQuestions();
                                    }
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 5),
                                          elevation: 4,
                                          backgroundColor: kMatte,
                                          content: Text(
                                            'Please make sure that the quiz has atleast one question.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(color: kFrost),
                                          )));
                                }
                                setState(() {});
                              }, kRed, "Remove Question"),
                              SizedBox(
                                width: 10.0,
                              ),
                              QuesButton(
                                  Icon(
                                    Icons.save,
                                    color: kMatte,
                                  ), () async {
                                int sum = current.fold(0,
                                    (previous, current) => previous + current);
                                if (_formQuiz[index].currentState.validate() &&
                                    ((dropdownValue ==
                                                'Single Correct Answer' ||
                                            dropdownValue ==
                                                'Multiple Correct Answer')
                                        ? sum > 0 && current.length > 1
                                        : true) &&
                                    posmark > 0)
                                  await saveQuestions();
                                else if ((dropdownValue ==
                                            'Single Correct Answer' ||
                                        dropdownValue ==
                                            'Multiple Correct Answer') &&
                                    (current.length < 2 || sum < 1)) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 5),
                                          elevation: 4,
                                          backgroundColor: kMatte,
                                          content: Text(
                                            'Please do make sure that the given question has atleast two options with one selected.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(color: kFrost),
                                          )));
                                } else if (posmark < 1) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 5),
                                          elevation: 4,
                                          backgroundColor: kMatte,
                                          content: Text(
                                            'Please do make sure that the given question has some marks allotted to it.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(color: kFrost),
                                          )));
                                }
                              }, kGlacier, "Save"),
                              SizedBox(
                                width: 10.0,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  int sum = current.fold(
                                      0,
                                      (previous, current) =>
                                          previous + current);
                                  if (_formQuiz[index]
                                          .currentState
                                          .validate() &&
                                      ((dropdownValue ==
                                                  'Single Correct Answer' ||
                                              dropdownValue ==
                                                  'Multiple Correct Answer')
                                          ? sum > 0 && current.length > 1
                                          : true) &&
                                      posmark > 0) {
                                    await saveQuestions();
                                    await _showMyDialog();
                                  } else if ((dropdownValue ==
                                              'Single Correct Answer' ||
                                          dropdownValue ==
                                              'Multiple Correct Answer') &&
                                      (current.length < 2 || sum < 1)) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            duration: Duration(seconds: 5),
                                            elevation: 4,
                                            backgroundColor: kMatte,
                                            content: Text(
                                              'Please do make sure that the given question has atleast two options with one selected.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(color: kFrost),
                                            )));
                                  } else if (posmark < 1) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            duration: Duration(seconds: 5),
                                            elevation: 4,
                                            backgroundColor: kMatte,
                                            content: Text(
                                              'Please do make sure that the given question has some marks allotted to it.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(color: kFrost),
                                            )));
                                  }
                                },
                                style: ElevatedButton.styleFrom(primary: kQuiz),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    12,
                                  ),
                                  child: Text(
                                    'SAVE DRAFT',
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
      ),
    );
  }

  Future<void> _getAllQuestions() async {
    final QueryResult quiz = await _quiz.queryA(gq.listQuestions());
    var temp = quiz.data['me']['usert']['makesSet'][0]['quizzes'];
    for (int i = 0; i < temp.length; i++) {
      for (int j = 0; j < temp[i]['questions'].length; j++) {
        if (temp[i]['questions'][j] != null)
          superques.add(temp[i]['questions'][j]);
      }
    }
  }

  Future<void> _showImport() async {
    ScrollController _icarus = new ScrollController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 40.0, 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duplicate Question?',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  IconButton(
                      icon: Icon(Icons.close),
                      color: kMatte,
                      onPressed: () {
                        superques = [];
                        Navigator.of(context).pop();
                      })
                ]),
          ),
          backgroundColor: kFrost,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.width / 3.5,
              margin: EdgeInsets.fromLTRB(32.0, 0, 32.0, 32.0),
              child: Scrollbar(
                controller: _icarus,
                child: SingleChildScrollView(
                  controller: _icarus,
                  child: Column(
                    children: [
                      for (int i = 0; i < superques.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: TextButton(
                            onPressed: () async {
                              if (quesset[index] != -1) {
                                final QueryResult answer =
                                    await _quiz.queryA(gq.deleteQuestion(
                                  id: quesset[index],
                                ));
                              }
                              answer = '';
                              feed = '';
                              question = '';
                              current = [];
                              option = [];
                              feedback = [];
                              noofoptions = 0;
                              question = superques[i]['questionText'];
                              posmark = superques[i]['questionMark'];
                              negmark = -1 * superques[i]['questionNMark'];
                              String type = (superques[i]['questionType'])
                                  .toString()
                                  .toLowerCase();
                              if (type == 'sca') {
                                dropdownValue = 'Single Correct Answer';
                              } else if (type == 'mca') {
                                dropdownValue = 'Multiple Correct Answer';
                              } else if (type == 'num') {
                                dropdownValue = 'Numerical';
                              } else if (type == 'fitb') {
                                dropdownValue = 'Fill In The Blanks';
                              } else if (type == 'short') {
                                dropdownValue = 'Short Answer';
                              }
                              var answ = superques[i]['answers'];
                              current = [];
                              option = [];
                              for (int j = 0; j < answ.length; j++) {
                                noofoptions++;
                                if (type == 'num' || type == 'fitb') {
                                  answer = answ[j]['answerText'];
                                  feed = answ[j]['feedback'];
                                  break;
                                } else if (type == 'sca' || type == 'mca') {
                                  option.add(answ[j]['answerText']);
                                  feedback.add(answ[j]['feedback']);
                                  current.add(answ[j]['correct'] ? 1 : 0);
                                }
                              }
                              superques = [];
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                            child: Card(
                              elevation: 2,
                              color: kGlacier,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${superques[i]['questionText']}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
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
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Save quiz?',
            style:
                Theme.of(context).textTheme.headline5.copyWith(color: kGlacier),
          ),
          backgroundColor: kMatte,
          content: Text(
            'On saving all your current process will be saved and the quiz will be saved as a draft under unpublished quizzes. In case you would like to continue making questions, please use the navigation buttons on either side of the flag option. Also by using the navigation buttons, your current progress is not saved when you move to a different question.',
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
                setState(() {
                  publish = true;
                });
                Navigator.of(context).pop();
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
    getTeaches();
  }

  @override
  void dispose() {
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
