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

final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
final hoverTransform = Matrix4.identity()..translate(0, -5, 0);

class StudCourse extends StatefulWidget {
  @override
  _StudCourseState createState() => _StudCourseState();
}

class _StudCourseState extends State<StudCourse> {
  AuthGraphQL ag;
  GraphQueries gq = new GraphQueries();
  GraphQLClient _quiz;
  var courseset = [], classlist = [], expanded = [];
  bool showquiz = false;

  void getCourses() async {
    final QueryResult quiz = await _quiz.queryA(gq.courselist());
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

  Widget swap() {
    ScrollController _icarus = new ScrollController();
    if (showquiz) {
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
                                    if (true)
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
                                                      .copyWith(
                                                          color: kGlacier),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  "No. of Submissions Made",
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
                                                  "Marks",
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
                                                  "Total Marks",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          color: kGlacier),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    Divider(
                                      color: kQuiz,
                                      thickness: 1,
                                    ),
                                    if (true)
                                      for (int j = 0;
                                          j <
                                              (classlist[4][i]['user']
                                                          ['takesSet'][0]
                                                      ['quizzes'])
                                                  .length;
                                          j++)
                                        if (classlist[4][i]['user']['takesSet']
                                                    [0]['quizzes'][j]['course']
                                                ['courseId'] ==
                                            classlist[0])
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
                                                    flex: 4,
                                                    child: Text(
                                                      "${find(i, j)} out of ${classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['timesCanTake']}",
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
                        Text("Courses",
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
                              tooltip: 'Filter Courses',
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
                              //TODO: fix card overflow
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
  String findm(i, j) {
    var check=int.parse(find(i,j));
    if(check !=0){
    var user = classlist[4][i]['user']['id'];
    var temp = classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'];
    for (int k = 0; k < temp.length; k++)
      if (classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'][k]
              ['user']['id'] ==
          user)
        return classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['takers'][k]
                ['marks']
            .toString();
    return '-';
    }
    else{
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
      reverse: !showquiz,
    );
  }
}
