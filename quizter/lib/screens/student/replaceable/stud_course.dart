import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:file_saver/file_saver.dart';

final nonHoverTransform = Matrix4.identity()..translate(0, 0, 0);
final hoverTransform = Matrix4.identity()..translate(0, -5, 0);

class StudCourse extends StatefulWidget {
  final String username, firstname, lastname;
  StudCourse(this.username, this.firstname, this.lastname);
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
    var stat;
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
                                      Icons.print,
                                    ),
                                    color: kGlacier,
                                    tooltip: 'print PDF',
                                    onPressed: () async {
                                      try {
                                        var data = await rootBundle
                                            .load("fonts/Roboto-Regular.ttf");
                                        var databold = await rootBundle
                                            .load("fonts/Roboto-Bold.ttf");
                                        final pdf = pw.Document();
                                        pdf.addPage(
                                          pw.MultiPage(
                                            pageFormat: PdfPageFormat.a4,
                                            build: (pw.Context context) {
                                              return [
                                                pw.Container(
                                                  child: pw.Column(children: [
                                                    pw.Center(
                                                      child: pw.Text(
                                                        "STUDENT REPORT",
                                                        style: pw.TextStyle(
                                                          font: pw.Font.ttf(
                                                              databold),
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    pw.Divider(
                                                      color: PdfColor.fromHex(
                                                          '#EDEDED'),
                                                      thickness: 1,
                                                    ),
                                                    pw.Row(children: [
                                                      pw.Expanded(
                                                        child: pw.Text(
                                                          "Course Code: ${classlist[0]}",
                                                          style: pw.TextStyle(
                                                            font: pw.Font.ttf(
                                                                data),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      pw.Expanded(
                                                        child: pw.Text(
                                                          "Course Name: ${classlist[1]}",
                                                          style: pw.TextStyle(
                                                            font: pw.Font.ttf(
                                                                data),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                    ]),
                                                    pw.Row(children: [
                                                      pw.Expanded(
                                                        child: pw.Text(
                                                          "Username: ${widget.username}",
                                                          style: pw.TextStyle(
                                                            font: pw.Font.ttf(
                                                                data),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      pw.Expanded(
                                                        child: pw.Text(
                                                          "Name: ${widget.firstname} ${widget.lastname}",
                                                          style: pw.TextStyle(
                                                            font: pw.Font.ttf(
                                                                data),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )
                                                    ]),
                                                    pw.Divider(
                                                      color: PdfColor.fromHex(
                                                          '#EDEDED'),
                                                      thickness: 1,
                                                    ),
                                                  ]),
                                                ),
                                                pw.Container(
                                                  color: PdfColor.fromHex(
                                                      '#5754E6'),
                                                  child: pw.Padding(
                                                    padding:
                                                        pw.EdgeInsets.symmetric(
                                                            vertical: 16),
                                                    child: pw.Column(
                                                      children: [
                                                        pw.Padding(
                                                          padding: pw.EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      24.0),
                                                          child: pw.Row(
                                                            mainAxisAlignment: pw
                                                                .MainAxisAlignment
                                                                .spaceBetween,
                                                            children: [
                                                              pw.Row(
                                                                children: [
                                                                  pw.Text(
                                                                    '${classlist[2]}',
                                                                    style: pw
                                                                        .TextStyle(
                                                                      font: pw.Font
                                                                          .ttf(
                                                                              databold),
                                                                      fontSize:
                                                                          8,
                                                                      color: PdfColor
                                                                          .fromHex(
                                                                              '#FFFFFF'),
                                                                    ),
                                                                  ),
                                                                  pw.Padding(
                                                                    padding: const pw
                                                                            .EdgeInsets.only(
                                                                        left:
                                                                            24.0),
                                                                    child:
                                                                        pw.Text(
                                                                      '${classlist[3]}',
                                                                      style: pw
                                                                          .TextStyle(
                                                                        font: pw.Font.ttf(
                                                                            databold),
                                                                        fontSize:
                                                                            8,
                                                                        color: PdfColor.fromHex(
                                                                            '#FFFFFF'),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        pw.Divider(
                                                          color:
                                                              PdfColor.fromHex(
                                                                  '#FFFFFF'),
                                                          thickness: 1,
                                                          endIndent: 16,
                                                          indent: 16,
                                                        ),
                                                        pw.Padding(
                                                          padding: pw.EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      16),
                                                          child: pw.Row(
                                                            mainAxisAlignment: pw
                                                                .MainAxisAlignment
                                                                .spaceBetween,
                                                            crossAxisAlignment: pw
                                                                .CrossAxisAlignment
                                                                .center,
                                                          ),
                                                        ),
                                                        for (int i = 0;
                                                            i <
                                                                classlist[4]
                                                                    .length;
                                                            i++)
                                                          pw.Padding(
                                                            padding: pw
                                                                    .EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16),
                                                            child: pw.Column(
                                                              crossAxisAlignment:
                                                                  pw.CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                pw.Column(
                                                                  children: [
                                                                    pw.Row(
                                                                      mainAxisAlignment: pw
                                                                          .MainAxisAlignment
                                                                          .spaceBetween,
                                                                      crossAxisAlignment: pw
                                                                          .CrossAxisAlignment
                                                                          .end,
                                                                      children: [
                                                                        pw.Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              pw.Text(
                                                                            "Quiz Name",
                                                                            style:
                                                                                pw.TextStyle(
                                                                              font: pw.Font.ttf(data),
                                                                              fontSize: 8,
                                                                              color: PdfColor.fromHex('#FFFFFF'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        pw.Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              pw.Text(
                                                                            "No. of Submissions Made",
                                                                            style:
                                                                                pw.TextStyle(
                                                                              font: pw.Font.ttf(data),
                                                                              fontSize: 8,
                                                                              color: PdfColor.fromHex('#FFFFFF'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        pw.Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              pw.Text(
                                                                            "Marks",
                                                                            style:
                                                                                pw.TextStyle(
                                                                              font: pw.Font.ttf(data),
                                                                              fontSize: 8,
                                                                              color: PdfColor.fromHex('#FFFFFF'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        pw.Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              pw.Text(
                                                                            "Total Marks",
                                                                            style:
                                                                                pw.TextStyle(
                                                                              font: pw.Font.ttf(data),
                                                                              fontSize: 8,
                                                                              color: PdfColor.fromHex('#FFFFFF'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        pw.Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              pw.Text(
                                                                            "Status",
                                                                            style:
                                                                                pw.TextStyle(
                                                                              font: pw.Font.ttf(data),
                                                                              fontSize: 8,
                                                                              color: PdfColor.fromHex('#FFFFFF'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                pw.Divider(
                                                                  color: PdfColor
                                                                      .fromHex(
                                                                          '#FFFFFF'),
                                                                  thickness: 1,
                                                                ),
                                                                for (int j = 0;
                                                                    j <
                                                                        (classlist[4][i]['user']['takesSet'][0]['quizzes'])
                                                                            .length;
                                                                    j++)
                                                                  if (classlist[4][i]['user']['takesSet'][0]['quizzes'][j]
                                                                              [
                                                                              'course']
                                                                          [
                                                                          'courseId'] ==
                                                                      classlist[
                                                                          0])
                                                                    pw.Column(
                                                                      children: [
                                                                        pw.Row(
                                                                          mainAxisAlignment: pw
                                                                              .MainAxisAlignment
                                                                              .spaceBetween,
                                                                          crossAxisAlignment: pw
                                                                              .CrossAxisAlignment
                                                                              .start,
                                                                          children: [
                                                                            pw.Expanded(
                                                                              flex: 4,
                                                                              child: pw.Text(
                                                                                "${classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['quizName']}",
                                                                                style: pw.TextStyle(
                                                                                  font: pw.Font.ttf(data),
                                                                                  fontSize: 8,
                                                                                  color: PdfColor.fromHex('#FFFFFF'),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw.Expanded(
                                                                              flex: 4,
                                                                              child: pw.Text(
                                                                                "${find(i, j)} out of ${classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['timesCanTake']}",
                                                                                style: pw.TextStyle(
                                                                                  font: pw.Font.ttf(data),
                                                                                  fontSize: 8,
                                                                                  color: PdfColor.fromHex('#FFFFFF'),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw.Expanded(
                                                                              flex: 2,
                                                                              child: pw.Text(
                                                                                "${findm(i, j)}",
                                                                                style: pw.TextStyle(
                                                                                  font: pw.Font.ttf(data),
                                                                                  fontSize: 8,
                                                                                  color: PdfColor.fromHex('#FFFFFF'),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw.Expanded(
                                                                              flex: 2,
                                                                              child: pw.Text(
                                                                                "${classlist[4][i]['user']['takesSet'][0]['quizzes'][j]['marks']}",
                                                                                style: pw.TextStyle(
                                                                                  font: pw.Font.ttf(data),
                                                                                  fontSize: 8,
                                                                                  color: PdfColor.fromHex('#FFFFFF'),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            pw.Expanded(
                                                                              flex: 4,
                                                                              child: pw.Text(
                                                                                "${findst(i, j)}",
                                                                                style: pw.TextStyle(
                                                                                  font: pw.Font.ttf(data),
                                                                                  fontSize: 10,
                                                                                  color: PdfColor.fromHex("${cler(i, j)}"),
                                                                                ),
                                                                              ),
                                                                            )
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
                                                )
                                              ];
                                            },
                                          ),
                                        );
                                        if (kIsWeb) {
                                          final output = 'Stud-${classlist[0]}';
                                          await FileSaver.instance.saveFile(
                                              output, await pdf.save(), 'pdf',
                                              mimeType: MimeType.PDF);
                                        } else {
                                          final output =
                                              await getTemporaryDirectory();

                                          final file = File(
                                              '${output.path}\\Stud-${classlist[0]}.pdf');
                                          await file
                                              .writeAsBytes(await pdf.save());

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  duration:
                                                      Duration(seconds: 10),
                                                  elevation: 2,
                                                  backgroundColor: kMatte,
                                                  content: SelectableText(
                                                    'The Report has been saved in ${output.path}\\Stud-${classlist[0]}.pdf',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color: kFrost),
                                                  )));
                                        }
                                      } catch (exception) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: Duration(seconds: 10),
                                                elevation: 2,
                                                backgroundColor: kMatte,
                                                content: SelectableText(
                                                  'There was some error in downloadinf the file. $exception',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2
                                                      .copyWith(color: kFrost),
                                                )));
                                      }
                                    },
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
                                              flex: 4,
                                              child: Text(
                                                "No. of Submissions Made",
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
                                            (classlist[4][i]['user']['takesSet']
                                                    [0]['quizzes'])
                                                .length;
                                        j++)
                                      if (classlist[4][i]['user']['takesSet'][0]
                                                  ['quizzes'][j]['course']
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
                                                )
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

  String findst(i, j) {
    DateTime st = DateTime.parse(changedate(classlist[4][i]['user']['takesSet']
            [0]['quizzes'][j]['startTime']
        .toString()
        .substring(0, 16)));
    DateTime et = DateTime.parse(changedate(classlist[4][i]['user']['takesSet']
            [0]['quizzes'][j]['endTime']
        .toString()
        .substring(0, 16)));
    var ppr = valTime(st.toString(), et.toString());
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

  String cler(i, j) {
    var x = findst(i, j);
    if (x == "Active" || x == "Submitted & Active" || x == "Submitted")
      return "#66DD66";

    if (x == "Expired") return "#1A1A1A";

    if (x == "Completed") return "#FFFFFF";

    if (x == "Upcoming") return "#EDEDED";

    return "#EDEDED";
  }

  Color clr(i, j) {
    var x = findst(i, j);
    if (x == "Active" || x == "Submitted & Active" || x == "Submitted")
      return kGreen;

    if (x == "Expired") return kMatte;

    if (x == "Completed") return kGlacier;

    if (x == "Upcoming") return kFrost;

    return kFrost;
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
      reverse: !showquiz,
    );
  }
}
