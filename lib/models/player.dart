import 'package:flutter/material.dart';

class Player {
  String id;
  String firstName;
  String lastName;
  String position;
  int yearOfBirth;
  int height;
  int salary;
  String image;
  int index;
  String userId;

  Player(
      {@required this.id,
      @required this.firstName,
      @required this.lastName,
      @required this.position,
      @required this.yearOfBirth,
      @required this.height,
      @required this.salary,
      @required this.image,
      @required this.index,
      @required this.userId,
      });
}
