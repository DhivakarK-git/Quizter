import 'package:flutter/material.dart';
import 'package:quizter/constants.dart';

class RailNavigation extends StatelessWidget {
  final int index;
  final Function press;
  RailNavigation(this.index, this.press);
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
            onPressed: () {},
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
            onPressed: () {},
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
