import 'package:flutter/material.dart';

class QuesButton extends StatelessWidget {
  final Icon icon;
  final Function op;
  final Color color;
  final String tool;
  QuesButton(this.icon, this.op, this.color, this.tool);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Tooltip(
        message: tool,
        child: ElevatedButton(
          onPressed: op,
          style: ElevatedButton.styleFrom(
              primary: color, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}
