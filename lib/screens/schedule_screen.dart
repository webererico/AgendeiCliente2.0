import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/home_screen.dart';
import 'package:agendei_cliente/screens/login_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String uidCompany;

  ScheduleScreen(this.uidCompany, {Key key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  String uidUser;
  String selectedService;
  String selectedEmployee;
  bool favorite;
  List<DropdownMenuItem> employeeItems = [];
  DateTime selectedDate;
  String selectedTime;
  String selectedCalendar;
  int lastMinutes = 0;
  int lastHours = 0;

  bool agendar = false;
  int timeDurationService = 10;

  getUidUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) return null;
    return user.uid.toString();
  }

  @override
  void initState() {
    super.initState();
    getUidUser().then((result) {
      uidUser = result;
      print(uidUser);
    });
    checkFavorite();
  }

  verifyUser() {
    if (uidUser == null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text('Para realizar um agendamento é necessário estár logado'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Você pode criar uma conta em nosso aplicativo e ter acesso a diversos estabelecimentos com agendamentos online, além de acumular pontos e poder realizar pagamento online'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Voltar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  'Entrar',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          );
        },
      );
    } else {
      verifyClient();
      saveOrder();
    }
  }

  void verifyClient() async {
    final DocumentSnapshot _documentSnapshot = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('clients')
        .document(uidUser)
        .get();
    if (!_documentSnapshot.exists) {
      final Map<String, dynamic> _data = {'uidUser': uidUser};
      Firestore.instance
          .collection('companies')
          .document(widget.uidCompany)
          .collection('clientes')
          .document(uidUser)
          .setData(_data);
    }
  }

  void saveOrder() async {
    _showSnack(context, 'Verificando horários disponíveis...', Colors.orange);
    final Map<String, dynamic> scheduleData = {
      'uidClient': uidUser,
      'dateTime': Timestamp.fromDate(selectedDate).toDate(),
      'uidService': selectedService,
      'uidEmployee': selectedEmployee,
      'uidCalendar': selectedCalendar,
      'statusPayment': 'não pago',
      'statusSchedule': 'agendado'
    };
    final Map<String, dynamic> scheduleUserData = {
      'uidCompany': widget.uidCompany,
      'dateTime': Timestamp.fromDate(selectedDate).toDate(),
      'uidService': selectedService,
      'uidEmployee': selectedEmployee,
      'uidCalendar': selectedCalendar,
      'statusPayment': 'não pago',
      'statusSchedule': 'agendado'
    };
    print(scheduleUserData);
    final QuerySnapshot calendar = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .where('uidEmployee', isEqualTo: selectedEmployee)
        .where('uidService', isEqualTo: selectedService)
        .getDocuments();
    for (int i = 0; i < calendar.documents.length; i++) {
      print('salvando');
      final DocumentReference documentReference = await Firestore.instance
          .collection('companies')
          .document(widget.uidCompany)
          .collection('calendars')
          .document(calendar.documents[i].documentID)
          .collection('orders')
          .add(scheduleData);
      await Firestore.instance
          .collection('users')
          .document(uidUser)
          .collection('orders')
          .document(documentReference.documentID)
          .setData(scheduleUserData);
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agendamento realizado com sucesso!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Seu horário foi reservado com sucesso. Caso seja necessário remarcar ou cancelar, é possível fazer em até 3 dias úteis antes da data marcada por meio do menu agendamentos.'),
                Padding(padding: EdgeInsets.only(top: 20)),
                Text('Agradecemos por utilizar o Agendei :D'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnack(BuildContext context, String text, MaterialColor cor) {
    _scaffold.currentState.showSnackBar(
      SnackBar(
        content: Container(height: 60.0,child: Text(text)),
        backgroundColor: cor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future checkFavorite() async {
    final DocumentSnapshot snap = await Firestore.instance
        .collection('users')
        .document(uidUser)
        .collection('favorites')
        .document(widget.uidCompany)
        .get();
    if (snap.data == null) {
      setState(() {
        favorite = false;
      });
    } else {
      setState(() {
        favorite = true;
      });
    }
    setState(() {
      favorite;
    });
    print(favorite);
  }

  Future changeFavorite() async {
    final DocumentSnapshot snap = await Firestore.instance
        .collection('users')
        .document(uidUser)
        .collection('favorites')
        .document(widget.uidCompany)
        .get();
    if (snap.data == null) {
      print('nao era favorito, inserindo');
      Map<String, dynamic> data = {'uidCompany': widget.uidCompany};
      Firestore.instance
          .collection('users')
          .document(uidUser)
          .collection('favorites')
          .document(widget.uidCompany)
          .setData(data);
      setState(() {
        favorite = true;
      });
    } else {
      print('ja era favorito, removendo');
      Firestore.instance
          .collection('users')
          .document(uidUser)
          .collection('favorites')
          .document(widget.uidCompany)
          .delete();
      setState(() {
        favorite = false;
      });
    }
  }

  void getCalendars() async {
    final QuerySnapshot query = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .where('uidService', isEqualTo: selectedService)
        .getDocuments();

    List<DocumentSnapshot> calendarItems = [];
    for (int i = 0; i < query.documents.length; i++) {
      calendarItems.add(query.documents[i]);
    }
    print('calendarios com o servico encontrados: ' +
        calendarItems.length.toString());
    getEmployee(calendarItems);
  }

  void getEmployee(List<DocumentSnapshot> calendar) async {
    for (int i = 0; i < calendar.length; i++) {
      print(calendar[i].data['name']);
      final DocumentSnapshot employee = await Firestore.instance
          .collection('companies')
          .document(widget.uidCompany)
          .collection('employees')
          .document(calendar[i].data['uidEmployee'])
          .get();
      print('funcionario: ' + employee.data['fullName']);
      print(employeeItems);
      if (!employeeItems.contains(employee.documentID)) {
        employeeItems.add(DropdownMenuItem(
          child: Text(employee.data['fullName']),
          value: '${employee.documentID}',
        ));
        print(employeeItems.length);
      }
    }
    setState(() {
      employeeItems;
    });
  }

  showDataPicker() async {
    final DateTime data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    setState(() {
      selectedDate = data;
      print(selectedDate);
    });
  }

  findTimeDuration(String selectedService) async {
    final DocumentSnapshot service = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('services')
        .document(selectedService)
        .get();
    timeDurationService = int.parse(service.data['duration']);
    print('tempo Duracao servico: ' + timeDurationService.toString());
    setState(() {
      timeDurationService;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FutureBuilder(
            future: Firestore.instance
                .collection('companies')
                .document(widget.uidCompany)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return Text(snapshot.data['name'].toString());
            }),
        actions: <Widget>[
          IconButton(
              icon: favorite == false
                  ? Icon(Icons.favorite_border)
                  : Icon(Icons.favorite),
              onPressed: () {
                changeFavorite();
              }),
        ],
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
                      color: Colors.grey.withAlpha(850),
                      margin: EdgeInsets.all(10),
                      borderOnForeground: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.network(
                            snapshot.data['img'],
//                          fit: BoxFit.cover,
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
//                              Text(name[1], style: TextStyle(fontWeight: FontWeight.bold), ),
                            ],
                          )
                        ],
                      ),
                    );
//                      ],
//                    );
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Serviços:',
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('companies')
                          .document(widget.uidCompany)
                          .collection('services')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text('Carregando');
                        } else {
                          List<DropdownMenuItem> serviceItems = [];
                          for (int i = 0;
                              i < snapshot.data.documents.length;
                              i++) {
                            DocumentSnapshot service =
                                snapshot.data.documents[i];
                            serviceItems.add(DropdownMenuItem(
                              child: Text(service.data['name']),
                              value: '${service.documentID}',
                            ));
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.list,
                                size: 25.0,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              DropdownButton(
                                items: serviceItems,
                                onChanged: (serviceValue) {
                                  agendar = false;
                                  lastMinutes = 0;
                                  lastHours = 0;
                                  employeeItems.clear();
                                  selectedEmployee = null;
                                  selectedDate = null;
                                  selectedTime = null;
                                  setState(() {
                                    print(
                                        'servico selecionado: ' + serviceValue);
                                    selectedService = serviceValue;
                                  });
                                  findTimeDuration(selectedService);
                                  getCalendars();
                                },
                                value: selectedService,
                                isExpanded: false,
                                hint: new Text(
                                  'Escolha o serviço',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: selectedService == null ? false : true,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Funcionário:',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.list,
                            size: 25.0,
                            color: Colors.white,
                          ),
//                          SizedBox(
//                            width: 10.0,
//                          ),
                          DropdownButton(
                            items: employeeItems,
                            onChanged: (employeeValue) {
                              setState(() {
                                selectedEmployee = employeeValue;
                              });
                            },
                            value: selectedEmployee,
                            isExpanded: false,
                            hint: new Text(
                              'Escolha o funcionário',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: selectedEmployee == null ? false : true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Escolha a data:',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          showDataPicker();
                        },
                      ),
//                      Visibility(
//                        visible: selectedDate != null ? true : false,
//                          child: Text( selectedDate.day != null ? selectedDate.day.toString(): '' +'/'+selectedDate.month.toString()+'/'+selectedDate.year.toString())
//                      ),
                    ],
                  )),
              Visibility(
                visible: selectedDate != null ? true : false,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Escolha o horário:',
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                    SizedBox(
                      height: 100,
                      width: 400,
                      child: CupertinoTimerPicker(
                        minuteInterval: 5,
                        mode: CupertinoTimerPickerMode.hm,
                        onTimerDurationChanged: (value) {
                          if (lastHours != 0 || lastMinutes != 0) {
                            setState(() {
                              selectedDate = selectedDate.subtract(new Duration(
                                  hours: lastHours, minutes: lastMinutes));
                            });
                          }
                          setState(() {
                            lastMinutes =
                                (value.inMinutes - 60 * value.inHours);
                            lastHours = value.inHours;
                            print(selectedDate.hour);
                            selectedDate = selectedDate.add(new Duration(
                                hours: lastHours, minutes: lastMinutes));
                            print(selectedDate);
                            agendar = true;
                          });
                        },

//                              onTimerDurationChanged: (value) {
//                                setState(() {
//                                  selectedTime = value.toString();
//                                });
//                              },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Visibility(
                  visible: agendar == true ? true : false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton.extended(
                        backgroundColor: Colors.blueAccent,
                        label: Text('Agendar'),
                        icon: Icon(Icons.check),
                        elevation: 2.0,
                        onPressed: () {
                          verifyUser();
                        },
                      ),
                    ],
                  )),
            ],
          )),
    );

//    );
  }
}
