import 'dart:convert';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import '../models/player.dart';
import '../models/user.dart';
import '../models/auth.dart';

mixin ConnectedModels on Model {
  List<Player> _players = [];
  List<Player> _myPlayers = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null
  ];
  List<String> _teamPositions = [
    'Center - Forward',
    'Center - Forward',
    'Goalkeeper',
    'Left - Winger',
    'Right - Winger',
    'Center - Mids',
    'Center - Mids',
    'Center - Back',
    'Center - Back',
    'Left - Back',
    'Right - Back'
  ];
  Player _showingPlayer;
  User _authenticatedUser;
  bool _isLoading = false;
}

mixin PlayerScreenModel on ConnectedModels {
  Player get showingPlayer {
    return _showingPlayer;
  }

  set showingPlayer(Player player) {
    _showingPlayer = player;
  }
}

mixin PlayersModel on ConnectedModels {
  List<Player> get players {
    return _players.where((Player player) => player.userId == 'none').toList();
    // return List.from(_players);
  }

  List<Player> get myPlayers {
    return _myPlayers;
  }

  List<String> get teamPositions {
    return _teamPositions;
  }

  int findPlayerSpot(Player player) {
    int i;
    for (i = 0; i < 11; i++) {
      if (_myPlayers[i] == null && _teamPositions[i] == player.position) {
        return i;
      }
    }
    return -1;
  }

  Player getPlayerById(String id) {
    if (id == null) {
      return null;
    }
    return _players.firstWhere((Player player) {
      return player.id == id;
    });
  }

  Future<Null> fetchAllPlayers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final http.Response response = await http.get(
          'https://fantasy-19efd.firebaseio.com/allplayers.json?auth=${_authenticatedUser.token}');
      final List<Player> fetchedPlayerList = [];
      final Map<String, dynamic> playerListData = json.decode(response.body);

      if (playerListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      print(playerListData);
      playerListData.forEach((String playerId, dynamic playerData) {
        final Player player = Player(
            id: playerId,
            firstName: playerData['firstName'],
            lastName: playerData['lastName'],
            position: playerData['position'],
            yearOfBirth: playerData['yearOfBirth'],
            height: playerData['height'],
            salary: playerData['salary'],
            image: playerData['link'],
            index: playerData['index'],
            userId: playerData['userId']);
        fetchedPlayerList.add(player);

        if (player.userId == _authenticatedUser.id && player.index != -1) {
          _myPlayers[player.index] = player;
        }
      });
      _players = fetchedPlayerList;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  Future<bool> togglePlayerChosenStatus(Player player) async {
    _isLoading = true;
    notifyListeners();

    int position = findPlayerSpot(player);
    if (position == -1 && player.userId == 'none') {
      return false;
    }

    if (player.userId != 'none') {
      position = -1;
    }

    final Map<String, dynamic> updatePlayer = {
      'firstName': player.firstName,
      'lastName': player.lastName,
      'position': player.position,
      'yearOfBirth': player.yearOfBirth,
      'height': player.height,
      'salary': player.salary,
      'link': player.image,
      'index': position,
      'userId': player.userId == 'none' ? _authenticatedUser.id : 'none'
    };

    try {
      final http.Response response = await http.put(
          'https://fantasy-19efd.firebaseio.com/allplayers/${player.id}.json?auth=${_authenticatedUser.token}',
          body: jsonEncode(updatePlayer));
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _isLoading = false;

      player.userId = player.userId == 'none' ? _authenticatedUser.id : 'none';
      if (player.userId == 'none') {
        _myPlayers[player.index] = null;
        player.index = -1;
      }else {
        player.index = position;
        _myPlayers[player.index] = player;
      }

      notifyListeners();
      return true;
    } catch (error) {
      print(error);
      notifyListeners();
      return false;
    }
  }

  bool get isLoading {
    return _isLoading;
  }
}

mixin UserModel on ConnectedModels {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyBiPk3Mfa7QA0ztr3T1m7cOevaN4qIEj1k',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyBiPk3Mfa7QA0ztr3T1m7cOevaN4qIEj1k',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    // print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          username: email,
          token: responseData['idToken']);

      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final expirationTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('token', responseData['idToken']);
      pref.setString('userEmail', email);
      pref.setString('userId', responseData['localId']);
      pref.setString('expirationTime', expirationTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    } else if (responseData['error']['message'] == 'OPERATION_NOT_ALLOWED') {
      message = 'This operation is not allowed';
    } else if (responseData['error']['message'] ==
        'TOO_MANY_ATTEMPTS_TRY_LATER') {
      message = 'Too many attempts! Please try again later.';
    }
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String token = pref.getString('token');
    final String expirationTime = pref.getString('expirationTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpirationTime = DateTime.parse(expirationTime);
      if (parsedExpirationTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }

      final String userEmail = pref.getString('userEmail');
      final String userId = pref.getString('userId');

      final int tokenDuration = parsedExpirationTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, username: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenDuration);
      notifyListeners();
    }
  }

  void logout() async {
    print('Logout');
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    // pref.remove('token');
    // pref.remove('userEmail');
    // pref.remove('userId');
    pref.clear();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
    });
  }
}
