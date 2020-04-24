import 'package:agendei_cliente/screens/open_screen.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/models/user_model.dart';

import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    UserModel().signOut();

    Color hexToColor() => new Color.fromARGB(255, 15, 76, 129);
    var GlobalMaterialLocalizations;
    return ScopedModel<UserModel>(
      model: UserModel(),
      child: MaterialApp(
          color: Color.fromARGB(255, 15, 76, 129),
          title: 'Agendei',
          theme: new ThemeData(
            brightness: Brightness.light,
            primaryColor: hexToColor(),
            accentColor: hexToColor(),
            splashColor: hexToColor(),
          ),
//    ThemeData(
//            primarySwatch: Color('0x0F4C81'),
//            primaryColor: Colors.blueAccent,
//
//          ),
          debugShowCheckedModeBanner: false,
          home: OpenScreen()),
    );
  }
}
