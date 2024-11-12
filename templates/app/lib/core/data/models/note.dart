import 'package:flutter/material.dart';

class Note{
  final String id;
  final String title;
  final String subTitle;
  final DateTime dateAdded;

  Note._({required this.id, required this.title, required this.subTitle, required this.dateAdded});

  factory Note({
    String? id,
    required String title,
    required String subTitle,
    DateTime? dateAdded,
  }) {
    return Note._(
      id: id ?? UniqueKey().toString(),
      title: title,
      subTitle: subTitle,
      dateAdded: DateTime.now(),
    );
  }
  
}