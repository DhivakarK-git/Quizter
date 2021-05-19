import 'package:flutter/material.dart';
import 'package:quizter/screens/failed_login_screen.dart';
import 'package:quizter/screens/forgot_login_screen.dart';
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
  String _recoverycode;

  LoginView() {
    _data = GraphQL().getClient();
  }

  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  Future<dynamic> checkemail(context, username) async {
    final QueryResult result =
        await _data.queryCharacter(gq.checkEmail(username: username));
    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
          elevation: 2,
          backgroundColor: kMatte,
          content: Text(
            'Please enter a valid Username',
            style:
                Theme.of(context).textTheme.bodyText2.copyWith(color: kFrost),
          )));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen(0)));
    } else {
      if (result.data['checkEmail']['ok'])
        _recoverycode = result.data['checkEmail']['accessCode'];
      return result.data['checkEmail']['ok'];
    }
  }

  Future<dynamic> getNotifications(context) async {
    AuthGraphQL ag = new AuthGraphQL();
    ag.setAuth(Provider.of<Token>(context, listen: false).getToken());
    GraphQueries gq = new GraphQueries();
    GraphQLClient _quiz = ag.getClient();
    final QueryResult result = await _quiz.queryCharacter(
      gq.getNotification(),
    );
    if (result.hasException) {
      return false;
    } else {
      return result.data['me']['usert']['notificationSet'];
    }
  }

  Future<bool> deleteNotification(
      context, String username, String notification) async {
    AuthGraphQL ag = new AuthGraphQL();
    ag.setAuth(Provider.of<Token>(context, listen: false).getToken());
    GraphQueries gq = new GraphQueries();
    GraphQLClient _quiz = ag.getClient();
    final QueryResult result = await _quiz.queryCharacter(
      gq.deleteNotification(username, notification),
    );
    if (result.hasException) {
      return false;
    } else {
      return result.data['deleteNotification']['ok'];
    }
  }

  Future<bool> validateSecCode(
      String secCode, String username, String password) async {
    if (secCode == _recoverycode) {
      final QueryResult result = await _data.queryCharacter(
          gq.changePassword(username: username, password: password));
      return result.data['changePassword']['ok'];
    }
    return false;
  }

  Future<bool> changePassword(
      String currpassword, String username, String password) async {
    final QueryResult result = await _data.queryCharacter(
      gq.validateUser(username: username, password: currpassword),
    );
    if (result.hasException) {
      return false;
    } else {
      final QueryResult result = await _data.queryCharacter(
          gq.changePassword(username: username, password: password));
      return result.data['changePassword']['ok'];
    }
  }

  void forgotScreen(context, username) => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => ForgotLoginScreen(0, username)));

  void failedScreen(context, time) => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => FailedLoginScreen(time)));

  void loginScreen(context) => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => LoginScreen(0)));

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
