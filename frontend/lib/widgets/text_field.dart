import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizterTextField extends StatelessWidget {
  final Function change, valid;
  final String fText;
  final icon;
  final bool obs;
  final TextInputAction doWhat;
  QuizterTextField(
      this.change, this.fText, this.icon, this.obs, this.valid, this.doWhat);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: kGlacier,
      style: GoogleFonts.montserrat(
        fontSize: MediaQuery.of(context).size.height * 0.028,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: kGlacier,
      ),
      validator: valid,
      decoration: InputDecoration(
        hintText: fText,
        hintStyle: GoogleFonts.montserrat(
          fontSize: MediaQuery.of(context).size.height * 0.028,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: kFrost,
        ),
        suffixIcon: icon,
        errorStyle: GoogleFonts.montserrat(
          fontSize: MediaQuery.of(context).size.height * 0.020,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
          color: kMatte,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kMatte),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kYellow, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kGlacier),
        ),
      ),
      onChanged: change,
      obscureText: obs,
      textInputAction: doWhat,
    );
  }
}
