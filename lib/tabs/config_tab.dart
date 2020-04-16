import 'package:agendei_cliente/screens/bugReport_screen.dart';
import 'package:flutter/material.dart';


class ConfigTab extends StatefulWidget {
  @override
  _ConfigTabState createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width,
              child: FlatButton.icon(
                color: Colors.blueAccent,
                icon: Icon(Icons.bug_report, color: Colors.white,),
                label: Text('Reportar bug no app',
                  style: TextStyle(color: Colors.white),),
                onPressed: () {
                  print('botao reportar bug');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BugReportScreen()));
                },
              ),
          )

        ],
      ),
    );
  }
}
