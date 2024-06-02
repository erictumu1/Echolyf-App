import 'package:flutter/material.dart';
import 'package:flutter_application_1/startscreen.dart';

void main() {
  return runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => Startscreen(),
    },
  ));
}
