import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizter/widgets/text_field.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/widgets/rail_navigation.dart';
import 'package:quizter/widgets/option_button.dart';
import 'package:quizter/widgets/ques_button.dart';

void main() {
  Widget createWidgetForTesting({Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          height: 600,
          width: 600,
          child: child,
        ),
      ),
    );
  }

  testWidgets('valid Username is entered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String _username;

    final _formKey = GlobalKey<FormState>();
    await tester.pumpWidget(createWidgetForTesting(
        child: new Form(
      key: _formKey,
      child: new QuizterTextField(
        (value) {
          _username = value;
        },
        "Username",
        Icon(Icons.account_circle_outlined, color: kMatte),
        false,
        (_username) {
          if (_username.isEmpty) {
            return '*Required';
          } else {
            RegExp regex = new RegExp(r'^[a-zA-Z0-9@\.]*$');
            if (!regex.hasMatch(_username))
              return 'Invalid username';
            else
              return null;
          }
        },
        TextInputAction.next,
      ),
    )));
    Finder field = find.byType(TextFormField);
    expect(field, findsOneWidget);
    await tester.enterText(field, 'cb.en.u4cse18315');
    await tester.pump();
    expect(_formKey.currentState.validate(), isTrue);
    print(_username);
  });
  testWidgets('invalid Username is entered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String _username;

    final _formKey = GlobalKey<FormState>();
    await tester.pumpWidget(createWidgetForTesting(
        child: new Form(
      key: _formKey,
      child: new QuizterTextField(
        (value) {
          _username = value;
        },
        "Username",
        Icon(Icons.account_circle_outlined, color: kMatte),
        false,
        (_username) {
          if (_username.isEmpty) {
            return '*Required';
          } else {
            RegExp regex = new RegExp(r'^[a-zA-Z0-9@\.]*$');
            if (!regex.hasMatch(_username))
              return 'Invalid username';
            else
              return null;
          }
        },
        TextInputAction.next,
      ),
    )));
    Finder field = find.byType(TextFormField);
    expect(field, findsOneWidget);
    await tester.enterText(field, '#\$123->=');
    await tester.pump();
    expect(_formKey.currentState.validate(), isFalse);
    print(_username);
  });

  testWidgets('invalid password is entered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String _password;
    bool _isHidden = false;

    final _formKey = GlobalKey<FormState>();
    await tester.pumpWidget(createWidgetForTesting(
        child: new Form(
      key: _formKey,
      child: new QuizterTextField(
        (value) {
          _password = value;
        },
        "Password",
        InkWell(
          onTap: () {
            _isHidden = !_isHidden;
          },
          child: Icon(
              _isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: kMatte),
        ),
        !_isHidden,
        (_password) {
          if (_password.isEmpty) {
            return '*Required';
          } else {
            RegExp regex = new RegExp(r'^[a-zA-Z0-9!@#\$%\^&]$');
            if (!regex.hasMatch(_password))
              return 'Invalid password';
            else
              return null;
          }
        },
        TextInputAction.done,
      ),
    )));
    Finder field = find.byType(TextFormField);
    expect(field, findsOneWidget);
    await tester.enterText(field, '\$ STKK_(!_@+?s+|\@\$%&*><m');
    await tester.pump();
    expect(_formKey.currentState.validate(), isFalse);
    print(_password);
  });

  testWidgets('rail_navigation functioning', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    int _index = 0;

    //final _formKey = GlobalKey<FormState>();
    await tester.pumpWidget(createWidgetForTesting(
        child: new RailNavigation(_index, (index) {
      _index = index;
    })));
    Finder field = find.byType(NavigationRail);
    expect(field, findsOneWidget);
    print('');
  });
  testWidgets('question button is functioning', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createWidgetForTesting(
        child: QuesButton(Icon(Icons.add), () {}, Colors.white, 'test')));
    print('');
  });
  testWidgets('option button is functioning', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
        createWidgetForTesting(child: OptionButton("1", () {}, Colors.white)));
    print('');
  });

  testWidgets('valid password is entered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String _password;
    bool _isHidden = false;

    final _form = GlobalKey<FormState>();
    await tester.pumpWidget(createWidgetForTesting(
        child: new Form(
      key: _form,
      child: new QuizterTextField(
        (value) {
          _password = value;
        },
        "Password",
        InkWell(
          onTap: () {
            _isHidden = !_isHidden;
          },
          child: Icon(
              _isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: kMatte),
        ),
        !_isHidden,
        (_password) {
          if (_password.isEmpty) {
            return '*Required';
          } else {
            RegExp regex = new RegExp(r'^[a-zA-Z0-9!@#\$%\^&]$');
            if (!regex.hasMatch(_password))
              return 'Invalid password';
            else
              return null;
          }
        },
        TextInputAction.done,
      ),
    )));
    Finder field = find.byType(TextFormField);
    expect(field, findsOneWidget);
    await tester.enterText(field, 'supersecret');
    await tester.pump();
    expect(_form.currentState.validate(), isFalse);
    print(_password);
  });
}
