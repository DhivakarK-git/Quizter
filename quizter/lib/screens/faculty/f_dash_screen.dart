import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/screens/login_screen.dart';
import 'package:quizter/screens/faculty/fac_router.dart';
import 'package:quizter/views/login_view.dart';
import 'package:quizter/widgets/rail_navigation.dart';
import 'package:animations/animations.dart';
import 'package:quizter/widgets/text_field.dart';

class FDashScreen extends StatefulWidget {
  final String username, firstName, lastName;
  FDashScreen(
      {@required this.username,
      @required this.firstName,
      @required this.lastName});
  @override
  _FDashScreenState createState() => _FDashScreenState();
}

class _FDashScreenState extends State<FDashScreen> {
  int _selectedIndex = 0;
  bool isScreenWide = false;
  String _secCode, _password, _password1;
  LoginView login = new LoginView();
  final _formKey = GlobalKey<FormState>();

  Future<void> _showMyNotifications(var notifications) async {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      barrierColor: kMatte.withAlpha(47),
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: 56, right: 1),
            child: SizedBox(
              width: 350,
              height: 224,
              child: Card(
                color: kGlacier,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = notifications.length - 1; i >= 0; i--)
                        SizedBox(
                          width: 340,
                          child: Card(
                            color: kFrost,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                    child: SizedBox(
                                      width: 280,
                                      child: Text(
                                        notifications[i]['Notification'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      login.deleteNotification(
                                          context,
                                          widget.username,
                                          notifications[i]['Notification']);
                                      notifications.removeAt(i);
                                      Navigator.of(context).pop();
                                      _showMyNotifications(notifications);
                                    },
                                    child: Icon(Icons.close, color: kMatte),
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _showChangePassword() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Password',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(color: kFrost),
                  ),
                  IconButton(
                      icon: Icon(Icons.close),
                      color: kFrost,
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]),
          ),
          backgroundColor: kIgris,
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 4),
                      child: QuizterTextField(
                        (value) {
                          _secCode = value;
                        },
                        "Current Password",
                        Icon(Icons.security, color: kMatte),
                        false,
                        (_secCode) {
                          if (_secCode.isEmpty) {
                            return '*Required';
                          } else {
                            RegExp regex =
                                new RegExp(r'^[a-zA-Z0-9!@#\$%\^&*]*$');
                            if (!regex.hasMatch(_secCode))
                              return 'Enter Valid Password';
                            else
                              return null;
                          }
                        },
                        TextInputAction.next,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 4),
                      child: QuizterTextField(
                        (value) {
                          _password = value;
                        },
                        "New Password",
                        Icon(Icons.visibility_off_outlined, color: kMatte),
                        true,
                        (_password) {
                          if (_password.isEmpty) {
                            return '*Required';
                          } else {
                            RegExp regex =
                                new RegExp(r'^[a-zA-Z0-9!@#\$%\^&*]*$');
                            if (!regex.hasMatch(_password))
                              return 'Invalid password';
                            else
                              return null;
                          }
                        },
                        TextInputAction.done,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 4),
                      child: QuizterTextField(
                        (value) {
                          _password1 = value;
                        },
                        "Confirm New Password",
                        Icon(Icons.visibility_off_outlined, color: kMatte),
                        true,
                        (_password1) {
                          if (_password1.isEmpty) {
                            return '*Required';
                          } else {
                            RegExp regex =
                                new RegExp(r'^[a-zA-Z0-9!@#\$%\^&*]*$');
                            if (!regex.hasMatch(_password1))
                              return 'Invalid password';
                            else
                              return null;
                          }
                        },
                        TextInputAction.done,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 4),
                        child: Flex(
                          direction:
                              isScreenWide ? Axis.vertical : Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final snackBar = SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 5),
                                    elevation: 2,
                                    backgroundColor: kMatte,
                                    content: Text(
                                      'Sorry, we couldn\'t match the password you\'ve entered. Please try again.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(color: kFrost),
                                    ));
                                if (_formKey.currentState.validate() &&
                                    _password == _password1) {
                                  if (!(await login.changePassword(
                                      _secCode, widget.username, _password))) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 5),
                                            elevation: 2,
                                            backgroundColor: kMatte,
                                            content: Text(
                                              'Your new password has been successfully updated',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(color: kFrost),
                                            )));
                                    Navigator.of(context).pop();
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 5),
                                          elevation: 2,
                                          backgroundColor: kMatte,
                                          content: Text(
                                            'Sorry, the passwords entered don\'t match. Please try again.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(color: kFrost),
                                          )));
                                }
                              },
                              style: ElevatedButton.styleFrom(primary: kFrost),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.012,
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.008,
                                ),
                                child: Text(
                                  'Update',
                                  style: GoogleFonts.montserrat(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.014,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.25,
                                      textStyle: TextStyle(
                                        color: kMatte,
                                      )),
                                ),
                              ),
                            )
                          ],
                        ))
                  ],
                ))
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      barrierColor: kMatte.withAlpha(47),
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: 56, right: 1),
            child: SizedBox(
              width: 330,
              height: 216,
              child: Card(
                color: kMatte,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 72.0,
                      color: kFrost,
                    ),
                    Text("${widget.firstName} ${widget.lastName}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: kFrost)),
                    SizedBox(height: 8),
                    Text("${widget.username}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: kFrost)),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            primary: kFrost,
                            side: BorderSide(color: kFrost),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showChangePassword();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 8.0),
                            child: Text("Change Password",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: kFrost)),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: kFrost),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(0)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 8.0),
                            child: Text("Sign Out",
                                style: Theme.of(context).textTheme.button),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
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
          elevation: 2,
          title: RichText(
            text: TextSpan(
              text: 'Qui',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  .copyWith(color: kGlacier),
              children: <TextSpan>[
                TextSpan(text: 'z', style: TextStyle(color: kQuiz)),
                TextSpan(text: 'ter'),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.circle_notifications),
              onPressed: () async {
                var notifications = await login.getNotifications(context);
                _showMyNotifications(notifications);
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                _showMyDialog();
              },
            ),
          ],
          backgroundColor: kMatte,
        ),
        backgroundColor: kFrost,
        body: Row(
          children: <Widget>[
            LayoutBuilder(builder: (context, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: RailNavigation2(
                        _selectedIndex == 4 ? 2 : _selectedIndex, (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }, (() {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    })),
                  ),
                ),
              );
            }),
            Expanded(
              flex: 4,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: PageTransitionSwitcher(
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) {
                    return FadeThroughTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      fillColor: Color(0x00000000),
                      child: child,
                    );
                  },
                  child: FacRouter.getRoute(_selectedIndex, () {
                    _selectedIndex = 2;
                    setState(() {});
                  },widget.username,widget.firstName,widget.lastName),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
