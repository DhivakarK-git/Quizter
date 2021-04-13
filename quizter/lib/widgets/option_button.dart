import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String number;
  final Function op;
  final Color color;
  OptionButton(this.number, this.op, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: op,
        style: ElevatedButton.styleFrom(
            primary: color, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: Center(
          child: Text(number,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
