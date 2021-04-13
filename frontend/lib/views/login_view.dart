import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quizter/graphql/graphql.dart';
import 'package:graphql/client.dart';
import 'package:quizter/graphql/graphqueries.dart';
import 'package:quizter/graphql/authentication/token.dart';
import 'package:quizter/graphql/authentication/auth_graphql.dart';
import 'package:provider/provider.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/screens/faculty/f_dash_screen.dart';
import 'package:quizter/screens/student/s_dash_screen.dart';
import 'package:quizter/screens/login_screen.dart';

class LoginView {
  final _url = 'http://127.0.0.1:8000/admin';
  GraphQLClient _data;
  GraphQueries gq = new GraphQueries();
  AuthGraphQL _ag;

  LoginView() {
    _data = GraphQL().getClient();
  }

  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  Future<bool> authenticate(
      {BuildContext context, String username, String password}) async {
    final QueryResult result = await _data.queryCharacter(
      gq.validateUser(username: username, password: password),
    );
    if (result.hasException) {
      return false;
    } else {
      String _token = result.data['tokenAuth']['token'];
      Provider.of<Token>(context, listen: false).changeToken(_token);
      _ag = new AuthGraphQL();
      _ag.setAuth(_token);
      GraphQLClient _auth = _ag.getClient();
      final QueryResult auth = await _auth.queryA(gq.getUser());
      if (result.hasException) {
        return false;
      } else {
        String type = (auth.data['me']['usert']['type']).toLowerCase();
        String username = auth.data['me']['username'],
            firstName = auth.data['me']['firstName'],
            lastName = auth.data['me']['lastName'];
        switch (type) {
          case 'student':
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SDashScreen(
                            username: username,
                            firstName: firstName,
                            lastName: lastName,
                          )));
            }
            return true;
          case 'faculty':
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FDashScreen(
                            username: username,
                            firstName: firstName,
                            lastName: lastName,
                          )));
            }
            return true;
          case 'admin':
            {
              _launchURL();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 5),
                  elevation: 2,
                  backgroundColor: kMatte,
                  content: Text(
                    'Redirecting to Django Admin.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: kFrost),
                  )));
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen(0)));
            }
            return true;
        }
      }
    }
    return false;
  }
}
