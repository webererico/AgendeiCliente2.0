import 'package:agendei_cliente/screens/open_screen.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/models/user_model.dart';

import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: MaterialApp(
          title: 'Agendei',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.blueAccent,

          ),
          debugShowCheckedModeBanner: false,
          home: OpenScreen()),
    );
  }
}
