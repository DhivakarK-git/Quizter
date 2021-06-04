import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';

class RailNavigation extends StatelessWidget {
  final int index;
  final Function press;
  RailNavigation(this.index, this.press);
  Future<void> _showHelp(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SimpleDialog(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Help',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            IconButton(
                icon: Icon(Icons.close),
                color: kMatte,
                alignment: Alignment.topRight,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ]),
          backgroundColor: kGlacier,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Text(
                "Designed and maintained by\nQuizter Team",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Text(
                "Contact Us",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
              child: Text(
                "+044-23456789\nquizterteam@gmail.com",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      backgroundColor: kGlacier,
      onDestinationSelected: press,
      unselectedLabelTextStyle: Theme.of(context).textTheme.button,
      selectedLabelTextStyle: Theme.of(context).textTheme.button,
      unselectedIconTheme: IconThemeData(color: kMatte, opacity: 90.0),
      selectedIconTheme: IconThemeData(color: kMatte),
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Course'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: Text('Quiz'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: Text('Result'),
        ),
      ],
      trailing: Column(
        children: [
          SizedBox(height: 16.0),
          IconButton(
            icon: Icon(Icons.help_center_outlined),
            color: kMatte,
            onPressed: () {
              _showHelp(context);
            },
          ),
          Text(
            "Help",
            style: Theme.of(context).textTheme.button,
          )
        ],
      ),
    );
  }
}

class RailNavigation2 extends StatelessWidget {
  final int index;
  final Function press, create;
  RailNavigation2(this.index, this.press, this.create);
  Future<void> _showHelp(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return SimpleDialog(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Help',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
            IconButton(
                icon: Icon(Icons.close),
                color: kMatte,
                alignment: Alignment.topRight,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ]),
          backgroundColor: kGlacier,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Text(
                "Designed and maintained by\nQuizter Team",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Text(
                "Contact Us",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
              child: Text(
                "+044-23456789\nquizterteam@gmail.com",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      backgroundColor: kGlacier,
      onDestinationSelected: press,
      unselectedLabelTextStyle: Theme.of(context).textTheme.button,
      selectedLabelTextStyle: Theme.of(context).textTheme.button,
      unselectedIconTheme: IconThemeData(color: kMatte, opacity: 90.0),
      selectedIconTheme: IconThemeData(color: kMatte),
      labelType: NavigationRailLabelType.all,
      leading: Column(
        children: [
          SizedBox(height: 8.0),
          FloatingActionButton(
            tooltip: "Add Quiz",
            onPressed: create,
            child: const Icon(
              Icons.edit,
            ),
            backgroundColor: kMatte,
          ),
          SizedBox(height: 4.0),
        ],
      ),
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Course'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: Text('Quiz'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: Text('Result'),
        ),
      ],
      trailing: Column(
        children: [
          SizedBox(height: 16.0),
          IconButton(
            icon: Icon(Icons.help_center_outlined),
            color: kMatte,
            onPressed: () {
              _showHelp(context);
            },
          ),
          Text(
            "Help",
            style: Theme.of(context).textTheme.button,
          )
        ],
      ),
    );
  }
}
