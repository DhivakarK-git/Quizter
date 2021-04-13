import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quizter/constants.dart';
import 'package:quizter/graphql/authentication/token.dart';
import 'package:quizter/screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Token>(
      create: (context) => Token(),
      child: MaterialApp(
        title:
            'Quizter | A quizapp made Of the Students, By the Students, For the Students',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            highlightColor: kQuiz.withAlpha(108),
            textTheme: TextTheme(
              headline1: GoogleFonts.courierPrime(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  color: kMatte),
              headline2: GoogleFonts.robotoSlab(
                  fontSize: 56,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  color: kMatte),
              headline3: GoogleFonts.robotoSlab(
                  fontSize: 48, fontWeight: FontWeight.w400, color: kMatte),
              headline4: GoogleFonts.robotoSlab(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  color: kMatte),
              headline5: GoogleFonts.robotoSlab(
                  fontSize: 24, fontWeight: FontWeight.w400, color: kMatte),
              headline6: GoogleFonts.robotoSlab(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  color: kMatte),
              subtitle1: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15,
                  color: kMatte),
              subtitle2: GoogleFonts.robotoSlab(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: kMatte),
              bodyText1: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  color: kMatte),
              bodyText2: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  color: kMatte),
              button: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.25,
                  color: kMatte),
              caption: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.4,
                  color: kMatte),
              overline: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                  color: kMatte),
            )),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
