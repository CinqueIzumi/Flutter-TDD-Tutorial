import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

// An entity of the Number Trivia class
// This class is seperate from the data model, so if the method changes from xml -> json, this class does not have to be modified.
class NumberTrivia extends Equatable {
  final String text;
  final int number;

  NumberTrivia({@required this.text, @required this.number}) : super();

  @override
  // TODO: implement props
  List<Object> get props => [text, number];
}
