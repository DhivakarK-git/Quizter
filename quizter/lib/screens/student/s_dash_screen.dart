import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/screens/login_screen.dart';
import 'package:quizter/screens/student/stud_router.dart';
import 'package:quizter/widgets/rail_navigation.dart';
import 'package:animations/animations.dart';

class SDashScreen extends StatefulWidget {
  final String username, firstName, lastName;
  SDashScreen(
      {@required this.username,
      @required this.firstName,
      @required this.lastName});
  @override
  _SDashScreenState createState() => _SDashScreenState();
}

class _SDashScreenState extends State<SDashScreen> {
  int _selectedIndex = 0;

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
                    Text(
                        "${widget.firstName != null ? widget.firstName : ''} ${widget.lastName != null ? widget.lastName : ''}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: kFrost)),
                    SizedBox(height: 8),
                    Text("${widget.username != null ? widget.username : ''}",
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
                          onPressed: () {},
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
              onPressed: () {},
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
                    child: RailNavigation(_selectedIndex, (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }),
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
                  child: StudRouter.getRoute(_selectedIndex),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
