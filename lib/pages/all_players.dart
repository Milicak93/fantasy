import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_model/main.dart';

class AllPlayersPage extends StatefulWidget {
  final MainModel model;

  AllPlayersPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _AllPlayersPageState();
  }
}

class _AllPlayersPageState extends State<AllPlayersPage> {
  @override
  initState() {
    widget.model.fetchAllPlayers();
    super.initState();
  }

  Widget _buildPlayerList(MainModel model) {
    Widget playerCard = Center(
      child: Text('No players found, please try again.'),
    );
    if (model.players.length > 0 && !model.isLoading) {
      playerCard = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed<bool>(
                context, '/player/' + model.players[index].id),
            child: Card(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  FadeInImage(
                    image: NetworkImage(model.players[index].image),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/ball.png'),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                      model.players[index].firstName +
                          ' ' +
                          model.players[index].lastName,
                      style: TextStyle(
                          fontSize: 26.0, fontWeight: FontWeight.w900)),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    model.players[index].position,
                    style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 15.0,
                  )
                ],
              ),
            ),
          );
        },
        itemCount: model.players.length,
      );
    } else if (model.isLoading) {
      playerCard = Center(
        child: CircularProgressIndicator(),
      );
    }
    return playerCard;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return _buildPlayerList(model);
    });
  }
}
