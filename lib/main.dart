import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/all_players.dart';
import './pages/player.dart';
import './pages/home.dart';
import './scoped_model/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;
  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : HomePage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(builder: (BuildContext context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'player') {
            final String playerId = pathElements[2];

            _model.showingPlayer = _model.getPlayerById(playerId);
            
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => !_isAuthenticated ? AuthPage():PlayerPage(),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => !_isAuthenticated ? AuthPage():AllPlayersPage(_model));
        },
      ),
    );
  }
}
