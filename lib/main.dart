import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marikinanavigator_app/app/app.dart';
import 'package:marikinanavigator_app/bootstrap.dart';

void main() {
  bootstrap(() => const App());
  Text('Build: ${DateTime.now()}', style: TextStyle(color: Colors.red));
}
