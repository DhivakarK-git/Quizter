import 'package:flutter/material.dart';
import 'package:quizter/widgets/on_hover.dart';

extension HoverExtensions on Widget {
  // Get a regerence to the body of the view

  Widget get moveUpOnHover {
    return TranslateOnHover(
      child: this,
    );
  }
}
