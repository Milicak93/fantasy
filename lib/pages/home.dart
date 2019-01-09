import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_model/main.dart';

import './all_players.dart';
import './my_players.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Spartans Fantasy'),
              actions: <Widget>[
                FlatButton.icon(
                  textColor: Colors.white,
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Logout'),
                  onPressed: () {
                    model.logout();
                    // Navigator.of(context).pushReplacementNamed('/');
                  },
                )
              ],
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.create),
                    text: 'All Players',
                  ),
                  Tab(
                    icon: Icon(Icons.list),
                    text: 'My Players',
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[AllPlayersPage(model), MyPlayersPage(model)],
            )),
      );
    });
  }
}
