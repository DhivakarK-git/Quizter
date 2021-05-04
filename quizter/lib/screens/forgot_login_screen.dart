import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizter/screens/login_screen.dart';
import 'package:quizter/views/login_view.dart';
import 'package:quizter/widgets/text_field.dart';
import 'dart:async';

class ForgotLoginScreen extends StatefulWidget {
  final int time;
  final String username;
  ForgotLoginScreen(this.time, this.username);
  @override
  _ForgotLoginScreenState createState() => _ForgotLoginScreenState();
}

class _ForgotLoginScreenState extends State<ForgotLoginScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animation;
  Animation<Offset> _offsetAnimation;
  bool _isHidden = false, _isEmail;
  String _secCode, _password, _password1;
  LoginView login = new LoginView();
  final _formKey = GlobalKey<FormState>();

  void checkemail() async {
    _isEmail = await login.checkemail(context, widget.username);
    if (_isEmail)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
          elevation: 2,
          backgroundColor: kMatte,
          content: Text(
            'Please enter the Security code sent to your registered email.',
            style:
                Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
          )));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkemail();
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 314),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.169),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));
    Timer(Duration(milliseconds: widget.time), () async => animation.forward());
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isScreenWide = MediaQuery.of(context).size.width < 1080;
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
                          child: SlideTransition(
                            position: _offsetAnimation,
                            child: Card(
                              color: kIgris,
                              elevation: 2.0,
                              margin: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.048,
                                top: kIsWeb ? 96 : 96,
                                bottom:
                                    MediaQuery.of(context).size.width * 0.024,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.028,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: _isEmail == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Account Recovery.",
                                              style: GoogleFonts.montserrat(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.024,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.20,
                                                  textStyle: TextStyle(
                                                    color: kGlacier,
                                                  )),
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.015),
                                            Padding(
                                                padding: EdgeInsets.all(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.004,
                                                ),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor: kFrost,
                                                  ),
                                                )),
                                          ],
                                        )
                                      : _isEmail
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Account Recovery.",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.024,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.20,
                                                      textStyle: TextStyle(
                                                        color: kGlacier,
                                                      )),
                                                ),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.015),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.004,
                                                  ),
                                                  child: QuizterTextField(
                                                    (value) {
                                                      _secCode = value;
                                                    },
                                                    "Security Code",
                                                    Icon(Icons.security,
                                                        color: kMatte),
                                                    false,
                                                    (_secCode) {
                                                      if (_secCode.isEmpty) {
                                                        return '*Required';
                                                      } else {
                                                        RegExp regex = new RegExp(
                                                            r'^[a-zA-Z0-9@\.]*$');
                                                        if (!regex
                                                            .hasMatch(_secCode))
                                                          return 'Enter Valid Security Code';
                                                        else
                                                          return null;
                                                      }
                                                    },
                                                    TextInputAction.next,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.01,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.004,
                                                  ),
                                                  child: QuizterTextField(
                                                    (value) {
                                                      _password = value;
                                                    },
                                                    "New Password",
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _isHidden =
                                                              !_isHidden;
                                                        });
                                                      },
                                                      child: Icon(
                                                          _isHidden
                                                              ? Icons
                                                                  .visibility_outlined
                                                              : Icons
                                                                  .visibility_off_outlined,
                                                          color: kMatte),
                                                    ),
                                                    !_isHidden,
                                                    (_password) {
                                                      if (_password.isEmpty) {
                                                        return '*Required';
                                                      } else {
                                                        RegExp regex = new RegExp(
                                                            r'^[a-zA-Z0-9!@#\$%\^&*]*$');
                                                        if (!regex.hasMatch(
                                                            _password))
                                                          return 'Invalid password';
                                                        else
                                                          return null;
                                                      }
                                                    },
                                                    TextInputAction.done,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.01),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.004,
                                                  ),
                                                  child: QuizterTextField(
                                                    (value) {
                                                      _password1 = value;
                                                    },
                                                    "Confirm New Password",
                                                    Icon(
                                                        Icons
                                                            .visibility_off_outlined,
                                                        color: kMatte),
                                                    true,
                                                    (_password1) {
                                                      if (_password1.isEmpty) {
                                                        return '*Required';
                                                      } else {
                                                        RegExp regex = new RegExp(
                                                            r'^[a-zA-Z0-9!@#\$%\^&*]*$');
                                                        if (!regex.hasMatch(
                                                            _password1))
                                                          return 'Invalid password';
                                                        else
                                                          return null;
                                                      }
                                                    },
                                                    TextInputAction.done,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.01),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.004,
                                                  ),
                                                  child: Flex(
                                                    direction: isScreenWide
                                                        ? Axis.vertical
                                                        : Axis.horizontal,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          checkemail();
                                                        },
                                                        child: Text(
                                                          "Resend Email",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.012,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            letterSpacing: 0.25,
                                                            textStyle:
                                                                TextStyle(
                                                              color: kGlacier,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          final snackBar =
                                                              SnackBar(
                                                                  behavior: SnackBarBehavior
                                                                      .floating,
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  action:
                                                                      SnackBarAction(
                                                                    label:
                                                                        'Resend Email',
                                                                    textColor:
                                                                        kQuiz,
                                                                    disabledTextColor:
                                                                        kIgris,
                                                                    onPressed:
                                                                        () {
                                                                      checkemail();
                                                                    },
                                                                  ),
                                                                  elevation: 2,
                                                                  backgroundColor:
                                                                      kMatte,
                                                                  content: Text(
                                                                    'Sorry, we couldn\'t match the code you\'ve entered. Please try again.',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText2
                                                                        .copyWith(
                                                                            color:
                                                                                kFrost),
                                                                  ));
                                                          if (_formKey
                                                                  .currentState
                                                                  .validate() &&
                                                              _password ==
                                                                  _password1) {
                                                            if (!(await login
                                                                .validateSecCode(
                                                                    _secCode,
                                                                    widget
                                                                        .username,
                                                                    _password))) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      snackBar);
                                                            } else {
                                                              _secCode = '';
                                                              _password = '';
                                                              _password1 = '';
                                                              login.loginScreen(
                                                                  context);
                                                            }
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                primary:
                                                                    kFrost),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.012,
                                                            vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.008,
                                                          ),
                                                          child: Text(
                                                            'Save',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.014,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    letterSpacing:
                                                                        0.25,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color:
                                                                          kMatte,
                                                                    )),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Account Recovery.",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.024,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.20,
                                                      textStyle: TextStyle(
                                                        color: kGlacier,
                                                      )),
                                                ),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.015),
                                                Padding(
                                                    padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.004,
                                                    ),
                                                    child: Text(
                                                      "Your account is not associated with a valid email id. To recover your account, please contact the quizter team.",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.012,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.20,
                                                        textStyle: TextStyle(
                                                          color: kGlacier,
                                                        ),
                                                      ),
                                                    )),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.01),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.004,
                                                  ),
                                                  child: Flex(
                                                    direction: isScreenWide
                                                        ? Axis.vertical
                                                        : Axis.horizontal,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          checkemail();
                                                        },
                                                        child: Text(
                                                          "Resend Email",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.012,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            letterSpacing: 0.25,
                                                            textStyle:
                                                                TextStyle(
                                                              color: kGlacier,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator
                                                            .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        LoginScreen(
                                                                            0))),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                primary:
                                                                    kFrost),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.008,
                                                          ),
                                                          child: Text(
                                                            'Go Back',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.014,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    letterSpacing:
                                                                        0.25,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color:
                                                                          kMatte,
                                                                    )),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                ),
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
