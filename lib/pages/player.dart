import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dart:async';
import '../scoped_model/main.dart';
import '../models/player.dart';

class PlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        final Player player = model.showingPlayer;
        return Scaffold(
          appBar: AppBar(
            title: Text(player.firstName + ' ' + player.lastName),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FadeInImage(
                image: NetworkImage(player.image),
                height: 300.0,
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/background.jpg'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(player.position,
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.w800)),
                  SizedBox(
                    height: 10.0,
                  ),
                  FlatButton.icon(
                      color: player.userId == 'none' ? Colors.green : Colors.red,
                      textColor: Colors.white,
                      icon: player.userId == 'none'
                          ? Icon(Icons.person_add)
                          : Icon(Icons.person_outline),
                      label: player.userId == 'none'
                          ? Text('Add to team')
                          : Text('Remove from team'),
                      onPressed: () {
                        
                        model.togglePlayerChosenStatus(player).then((bool success) {
                          if (!success) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Can not choose this player!'),
                                    content: Text('Position is not available.'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  );
                                });
                          }
                        });
                      }),
                  SizedBox(
                    height: 10.0,
                  ),
                  Divider(),
                  Text(
                    'Height: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(player.height.toString() + ' cm'),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Year of birth: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(player.yearOfBirth.toString() + '.'),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Annual salary: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(player.salary.toString()),
                      Text(
                        ' EUR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
