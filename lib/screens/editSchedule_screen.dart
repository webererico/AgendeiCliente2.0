import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditScheduleScreen extends StatefulWidget {
  final String uidCompany;
  final String uidOrder;
  final String calendar;
  final String uidUser;
  final DocumentSnapshot order;


  EditScheduleScreen(
      {this.uidCompany,
      this.uidOrder,
      this.calendar,
      this.uidUser,
      this.order,
      Key key})
      : super(key: key);

  @override
  _EditScheduleScreenState createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  String selectedService;
  String selectedEmployee;
  bool favorite;
  List<DropdownMenuItem> employeeItems = [];
  Timestamp selectedDateTime;
  DateTime date;
  DateTime time;
  int lastMinutes = 0;
  int lastHours =0 ;
  DateTime today = DateTime.now();
  int timeDurationService = 10;
  QuerySnapshot calendars;
  DocumentSnapshot orderCompany;

  getCalendar() async {
    calendars = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .where('uidEmployee', isEqualTo: widget.order.data['uidEmployee'])
        .where('uidService', isEqualTo: widget.order.data['uidService'])
        .getDocuments();
    if (calendars.documents.length == 1) {
      getOrder(calendars.documents[0]);
    }
  }

  getOrder(DocumentSnapshot calendar) async {
    orderCompany = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .document(calendar.documentID)
        .collection('orders')
        .document(widget.order.documentID)
        .get();
    setState(() {
      selectedService = orderCompany.data['uidService'];
      selectedEmployee = orderCompany.data['uidEmployee'];
      selectedDateTime = orderCompany.data['dateTime'];
      date = DateTime.parse(selectedDateTime.toDate().toString());
//      lastMinutes = date.minute;
//      lastHours = date.hour;
      print(selectedDateTime.toDate().toString());
      print(selectedEmployee);
      print(selectedService);
    });
  }

  showDataPicker() async {
    final DateTime data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    setState(() {
      selectedDateTime = Timestamp.fromDate(data);
      date = data;
      print(selectedDateTime);
    });
  }

   void deleteOrder() {
      Firestore.instance
          .collection('companies')
          .document(widget.uidCompany)
          .collection('calendars')
          .document(calendars.documents[0].documentID)
          .collection('orders')
          .document(widget.order.documentID)
          .delete();
      Firestore.instance
          .collection('users')
          .document(widget.uidUser)
          .collection('orders')
          .document(widget.order.documentID)
          .delete();
      print('agendamento apagado');
    }

  @override
  void initState() {
    super.initState();
    getCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder(
            future: Firestore.instance
                .collection('companies')
                .document(widget.uidCompany)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return Text(snapshot.data['name']);
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<DocumentSnapshot>(
                future: Firestore.instance
                    .collection('companies')
                    .document(widget.uidCompany)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  List<String> name =
                      snapshot.data['name'].toString().split(' ');
                  return Card(
                    elevation: 1.0,
                    color: Colors.grey.withAlpha(850),
                    margin: EdgeInsets.all(10),
                    borderOnForeground: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.network(
                          snapshot.data['img'],
                          width: 180,
                          height: 180,
                        ),
                        Padding(padding: EdgeInsets.only(left: 30)),
                        Column(
                          children: <Widget>[
                            Text(
                              name[0],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.orange,
                margin: EdgeInsets.all(15.0),
                elevation: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Serviço: ',
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: Firestore.instance
                          .collection('companies')
                          .document(widget.uidCompany)
                          .collection('services')
                          .document(widget.order.data['uidService'])
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text('Carregando');
                        } else {
                          return Text(snapshot.data['name'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Card(
                margin: EdgeInsets.all(15.0),
                elevation: 1.0,
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Funcionário:',
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                    FutureBuilder(
                        future: Firestore.instance
                            .collection('companies')
                            .document(widget.uidCompany)
                            .collection('employees')
                            .document(widget.order.data['uidEmployee'])
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          return Text(snapshot.data['fullName'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold));
                        }),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Alterar a data: ',
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                date != null ? Text(
                  date.day.toString() +
                      '/' +
                      date.month.toString() +
                      '/' +
                      date.year.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ): Text(''),
//                Text(selectedDate),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    showDataPicker();
                  },
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  'Alterar o horário: ',
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ),
                date != null ?
                Text(
                  date.hour.toString() + ':' + date.minute.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 22),
                ): Text(''),
                SizedBox(
                  height: 100,
                  width: 400,
                  child: CupertinoTimerPicker(
                    minuteInterval: 30,
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      if (lastHours != 0 || lastMinutes != 0) {
                        setState(() {
                          date = date.subtract(new Duration(
                              hours: lastHours, minutes: lastMinutes));
                        });
                      }
                      setState(() {
                        lastMinutes = (value.inMinutes - 60 * value.inHours);
                        lastHours = value.inHours;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: 'cancelSchedule',
                  backgroundColor: Colors.red,
                  label: Text('Cancelar serviço'),
                  icon: Icon(Icons.cancel),
                  elevation: 2.0,
                  onPressed: () {
                    print('calculando diferenca de dias');
                    DateTime orderDate = selectedDateTime.toDate();
                    Duration difference = orderDate.difference(today);
                    print('diferenca: '+difference.inDays.toString());
                    if(difference.inDays >3) {
                      print('diferenca maiior que 3 dias ... pode apagar');
                      deleteOrder();
                      Navigator.of(context).pop(context);
                    }else {
                      print('diferenca menor que 3 dias ... NAO pode apagar');
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                            Text('Não é possivel cancelar'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                      'Infelizmente, o prazo para cancelamento deste serviço por meio do Agendei já foi ultrapassado. Para cancelar entre em contato com o estabelecimento'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
                FloatingActionButton.extended(
                  heroTag: 'updateSchedule',
                  backgroundColor: Colors.orange,
                  label: Text('Atualizar'),
                  icon: Icon(Icons.check),
                  elevation: 2.0,
                  onPressed: () {
                    print('alterando agendamento');
                    _scaffold.currentState.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Verificando disponibilidade de horário',
                          style: TextStyle(color: Colors.orange),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
