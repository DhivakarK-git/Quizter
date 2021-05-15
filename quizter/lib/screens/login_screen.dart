import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizter/views/login_view.dart';
import 'package:quizter/widgets/text_field.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  final int time;
  LoginScreen(this.time);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animation;
  Animation<Offset> _offsetAnimation;
  bool _isHidden = false;
  String _username = '', _password = '';
  LoginView login = new LoginView();
  int noofattempts = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
                Hero(
                  tag: 'matte',
                  child: Container(
                    height: MediaQuery.of(context).size.height / 3.5,
                    color: kMatte,
                  ),
                ),
                Container(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Container(
                            child: Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'Images/pizza.png',
                                height:
                                    MediaQuery.of(context).size.height - 108,
                                width: MediaQuery.of(context).size.width - 108,
                              ),
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome Back.",
                                        style: GoogleFonts.montserrat(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.024,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.20,
                                            textStyle: TextStyle(
                                              color: kGlacier,
                                            )),
                                      ),
                                      Text(
                                        " Sign in to continue.",
                                        style: GoogleFonts.montserrat(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.012,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: 0.25,
                                            textStyle: TextStyle(
                                              color: kGlacier,
                                            )),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025),
                                      Padding(
                                        padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.004,
                                        ),
                                        child: QuizterTextField(
                                          (value) {
                                            _username = value;
                                          },
                                          "Username",
                                          Icon(Icons.account_circle_outlined,
                                              color: kMatte),
                                          false,
                                          (_username) {
                                            if (_username.isEmpty) {
                                              return '*Required';
                                            } else {
                                              RegExp regex = new RegExp(
                                                  r'^[a-zA-Z0-9@\.]*$');
                                              if (!regex.hasMatch(_username))
                                                return 'Invalid username';
                                              else
                                                return null;
                                            }
                                          },
                                          TextInputAction.next,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.004,
                                        ),
                                        child: QuizterTextField(
                                          (value) {
                                            _password = value;
                                          },
                                          "Password",
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _isHidden = !_isHidden;
                                              });
                                            },
                                            child: Icon(
                                                _isHidden
                                                    ? Icons.visibility_outlined
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
                                              if (!regex.hasMatch(_password))
                                                return 'Invalid password';
                                              else
                                                return null;
                                            }
                                          },
                                          TextInputAction.done,
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025),
                                      Padding(
                                        padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.004,
                                        ),
                                        child: Flex(
                                          direction: isScreenWide
                                              ? Axis.vertical
                                              : Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                if (_username.isNotEmpty)
                                                  login.forgotScreen(context,
                                                      _username.toLowerCase());
                                                else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 5),
                                                          elevation: 2,
                                                          backgroundColor:
                                                              kMatte,
                                                          content: Text(
                                                            'Please enter your Username',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2
                                                                .copyWith(
                                                                    color:
                                                                        kFrost),
                                                          )));
                                                }
                                              },
                                              child: Text(
                                                "Forgot Password?",
                                                style: GoogleFonts.montserrat(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.012,
                                                  fontWeight: FontWeight.w300,
                                                  letterSpacing: 0.25,
                                                  textStyle: TextStyle(
                                                    color: kGlacier,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final snackBar = SnackBar(
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    duration:
                                                        Duration(seconds: 5),
                                                    action: SnackBarAction(
                                                      label: 'Forgot Password',
                                                      textColor: kQuiz,
                                                      disabledTextColor: kIgris,
                                                      onPressed: () {
                                                        if (_username
                                                            .isNotEmpty) {
                                                          login.forgotScreen(
                                                              context,
                                                              _username
                                                                  .toLowerCase());
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  elevation: 2,
                                                                  backgroundColor:
                                                                      kMatte,
                                                                  content: Text(
                                                                    'Please Enter A valid Username',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText2
                                                                        .copyWith(
                                                                            color:
                                                                                kFrost),
                                                                  )));
                                                        }
                                                      },
                                                    ),
                                                    elevation: 2,
                                                    backgroundColor: kMatte,
                                                    content: Text(
                                                      'Sorry, we couldn\'t find an account with that username or password. Please try again.',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                              color: kFrost),
                                                    ));
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  bool success =
                                                      await login.authenticate(
                                                          context: context,
                                                          username: _username
                                                              .toLowerCase(),
                                                          password: _password);
                                                  if (!success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                    if (noofattempts < 3)
                                                      noofattempts++;
                                                    else
                                                      login.failedScreen(
                                                          context, 2);
                                                  } else {
                                                    _username = '';
                                                    _password = '';
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  primary: kFrost),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.008,
                                                ),
                                                child: Text(
                                                  'Sign In',
                                                  style: GoogleFonts.montserrat(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.014,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      letterSpacing: 0.25,
                                                      textStyle: TextStyle(
                                                        color: kMatte,
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
