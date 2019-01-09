import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_model/main.dart';

class MyPlayersPage extends StatefulWidget {
  final MainModel model;
  MyPlayersPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _MyPlayersPageState();
  }
}

class _MyPlayersPageState extends State<MyPlayersPage> {
  Widget _buildEmptyCard(MainModel model, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image(
              image: AssetImage('assets/ball.png'),
              height: 300.0,
              fit: BoxFit.cover,
              color: Color.fromRGBO(255, 255, 255, 0.3),
              colorBlendMode: BlendMode.modulate),
          SizedBox(
            height: 5.0,
          ),
          Text(
            model.teamPositions[index],
            style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.w900,
                color: Colors.black87),
          ),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
    );
  }

  Widget _buildFilledCard(MainModel model, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(model.myPlayers[index].image),
          SizedBox(height: 10.0,),
          Text(
              model.myPlayers[index].firstName + ' ' +
                  model.myPlayers[index].lastName,
              style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87)),
          SizedBox(
            height: 10.0,
          ),
          Text(model.myPlayers[index].position,
              style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black38)),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
    );
  }

  Widget _buildPlayerList(MainModel model) {
    Widget playerCard = Container(
      child: Center(
        child: Text('No selected players, please choose.'),
      ),
    );
    if (!model.isLoading) {
      playerCard = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (model.myPlayers[index] == null) {
                return;
              }
              Navigator.pushNamed<bool>(
                      context, '/player/' + model.myPlayers[index].id)
                  .then((bool value) {
                if (value) {
                  // model.deletePlayer();
                }
              });
            },
            child: model.myPlayers[index] == null
                ? _buildEmptyCard(model, index)
                : _buildFilledCard(model, index),
          );
        },
        itemCount: model.myPlayers.length,
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
      },
    );
  }
}
