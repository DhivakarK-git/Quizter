import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizter/views/login_view.dart';
import 'dart:async';

class FailedLoginScreen extends StatefulWidget {
  final int time;
  FailedLoginScreen(this.time);
  @override
  _FailedLoginScreenState createState() => _FailedLoginScreenState();
}

class _FailedLoginScreenState extends State<FailedLoginScreen>
    with SingleTickerProviderStateMixin {
  Timer _timer;
  int progress;
  LoginView login = new LoginView();

  @override
  void initState() {
    super.initState();
    startTimer();
    Timer(Duration(seconds: (widget.time * 60)),
        () async => login.loginScreen(context));
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void startTimer() {
    progress = widget.time * 60 * 20;
    const oneSec = const Duration(milliseconds: 50);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (progress <= 1) {
          setState(() {
            timer.cancel();
            return;
          });
        }
        setState(() {
          progress--;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: RichText(
            text: TextSpan(
              text: 'Qui',
              style: Theme.of(context).textTheme.headline1.copyWith(
                  color: kGlacier,
                  fontSize: MediaQuery.of(context).size.width * 0.020),
              children: <TextSpan>[
                TextSpan(text: 'z', style: TextStyle(color: kQuiz)),
                TextSpan(text: 'ter'),
              ],
            ),
          ),
          backgroundColor: kMatte,
        ),
        backgroundColor: kQuiz,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  color: kMatte,
                ),
                Container(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            child: Image.asset(
                              'Images/pizza.png',
                              height: MediaQuery.of(context).size.height - 108,
                              width: MediaQuery.of(context).size.width - 108,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Card(
                            color: kIgris,
                            elevation: 2.0,
                            margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.048,
                              top: kIsWeb ? 96 : 96,
                              bottom: MediaQuery.of(context).size.width * 0.024,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.028,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Too many failed login attempts. Please try again in",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.012,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.20,
                                        textStyle: TextStyle(
                                          color: kGlacier,
                                        )),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.015),
                                  Center(
                                    child: Text(
                                      '${((progress / 20) ~/ 60).toString().length == 2 ? ((progress / 20) ~/ 60) : '0' + ((progress / 20) ~/ 60).toString()} : ${(((progress / 20) % 60).truncate()).toString().length == 2 ? (((progress / 20) % 60).truncate()) : '0' + (((progress / 20) % 60).truncate()).toString()}',
                                      style:
                                          Theme.of(context).textTheme.headline2,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Minutes",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(color: kFrost),
                                      ),
                                      SizedBox(width: 36),
                                      Text(
                                        "Seconds",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(color: kFrost),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
