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
  DateTime startHour;
  DateTime endHour;
  List<DropdownMenuItem> employeeItems = [];
  DateTime selectedDate;
  DateTime selectedTime;
  bool time = false;
  String selectedCalendar;
  int lastMinutes = 0;
  int lastHours = 0;
  bool agendar = false;
  int timeDurationService = 0;
  bool ignore;

  getUidUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) return null;
    DocumentSnapshot documentSnapshot = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('favorites')
        .document(widget.uidCompany)
        .get();
    if (documentSnapshot.data == null) {
      setState(() {
        favorite = false;
      });
    } else {
      setState(() {
        favorite = true;
      });
    }
    return user.uid.toString();
  }

  @override
  void initState() {
    super.initState();
    getUidUser().then((result) {
      uidUser = result;
      print(uidUser);
    });
//    checkFavorite();
  }

  verifyUser() {
    print('verificando usuário...');
    if (uidUser == null) {
      print('usuário não logado');
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
      print('usuário logado');
      verifyOrderExist();
    }
  }

  void verifyOrderExist() async {
    print('verificando se horário dsiponível...');
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .document(selectedCalendar)
        .collection('orders')
        .where('dateTime', isEqualTo: selectedDate)
        .getDocuments();
    if (querySnapshot.documents.length > 0) {
      print('horário indisponível');
      _showSnack(
          context,
          'Este horário não está disponível, por favor, solicite outro',
          Colors.red);
    } else {
      print('horário disponível');
      verifyDate();
//      saveOrder();
    }
  }

  void verifyDate() async {
    print('validando data do agendamento ...');
    DocumentSnapshot documentSnapshot = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .document(selectedCalendar)
        .get();
    if (documentSnapshot.exists) {
      Timestamp calendarStart = documentSnapshot.data['startTime'];
      Timestamp calendarEnd = documentSnapshot.data['endTime'];
      DateTime start = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          calendarStart.toDate().hour,
          calendarStart.toDate().minute);
      DateTime end = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          calendarEnd.toDate().hour,
          calendarEnd.toDate().minute);
      if ((selectedDate.isAfter(start) ||
              selectedDate.isAtSameMomentAs(start)) &&
          selectedDate.isBefore(end)) {
        print('data valida');
        saveOrder();
      } else {
        print('data inválida');
        _scaffold.currentState.removeCurrentSnackBar();
        _showSnack(
            context,
            'Horário inválido. Informe um horário entre ${start.hour}:${start.minute} e ${end.hour}:${end.minute}.',
            Colors.orange);
      }
    }
  }

  void verifyClient() async {
    print('verificando se já é cliente...');
    final DocumentSnapshot _documentSnapshot = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('clients')
        .document(uidUser)
        .get();
    if (!_documentSnapshot.exists) {
      print('usuário nao é cliente...adicionando');
      final Map<String, dynamic> _data = {'uidUser': uidUser};
      Firestore.instance
          .collection('companies')
          .document(widget.uidCompany)
          .collection('clients')
          .document(uidUser)
          .setData(_data);
    } else {
      print('usuário já era cliente');
    }
  }

  void saveOrder() async {
    verifyClient();
    print('salvando ordem de servico...');
    _showSnack(context, 'Verificando horários disponíveis...', Colors.orange);
    Timestamp createdAt = Timestamp.fromDate(DateTime.now());
    final Map<String, dynamic> scheduleData = {
      'uidClient': uidUser,
      'dateTime': Timestamp.fromDate(selectedDate).toDate(),
      'uidService': selectedService,
      'uidEmployee': selectedEmployee,
      'uidCalendar': selectedCalendar,
      'statusPayment': 'não pago',
      'statusSchedule': 'agendado',
      'createdAt': createdAt
    };
    final Map<String, dynamic> scheduleUserData = {
      'uidCompany': widget.uidCompany,
      'dateTime': Timestamp.fromDate(selectedDate).toDate(),
      'uidService': selectedService,
      'uidEmployee': selectedEmployee,
      'uidCalendar': selectedCalendar,
      'statusPayment': 'não pago',
      'statusSchedule': 'agendado',
      'createdAt': createdAt
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
    print('ordem salva... agendamento realizado');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        _scaffold.currentState.removeCurrentSnackBar();
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
        content: Container(
            height: 80.0,
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            )),
        action: text ==
                'Este horário não está disponível, por favor, solicite outro'
            ? SnackBarAction(
                label: 'sugestão de horario',
                textColor: Colors.white,
                onPressed: () {
                  print('sugestao');
                })
            : SnackBarAction(
                onPressed: () {},
                label: ' ',
              ),
        backgroundColor: cor,
      ),
    );
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

  void getOrderCalendar(String uidService, String uidEmployee) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('calendars')
        .where(
          'uidService',
          isEqualTo: uidService,
        )
        .where('uidEmployee', isEqualTo: uidEmployee)
        .limit(1)
        .getDocuments();
    Timestamp _start = querySnapshot.documents[0].data['startTime'];
    Timestamp _end = querySnapshot.documents[0].data['endTime'];
    startHour = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, _start.toDate().hour, _start.toDate().minute);
    endHour = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        _end.toDate().hour, _end.toDate().minute);
    print('hora inicio calendario' + startHour.toIso8601String());
    print('hora termino calendario' + endHour.toIso8601String());
    setState(() {
      ignore = querySnapshot.documents[0].data['ignore'];
      selectedCalendar = querySnapshot.documents[0].documentID;
    });
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
      if (!employeeItems.contains(employee.documentID)) {
        setState(() {
          employeeItems.add(DropdownMenuItem(
            child: Text(employee.data['fullName']),
            value: '${employee.documentID}',
          ));
          print(employeeItems.length);
        });
      }
    }
    if (employeeItems.length == 1) {
      setState(() {
        selectedEmployee = employeeItems[0].value;
        findTimeDuration(selectedService);
      });
    }
  }

  showDataPicker() async {
    final DateTime data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    setState(() {
      selectedTime = null;
      selectedDate = data;
      print(selectedDate);
    });
    if (selectedDate != null) {
      getOrderCalendar(selectedService, selectedEmployee);
    }
  }

  double _kPickerSheetHeight = 300.0;

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                child: Text(
                  'cancelar',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                  textColor: Colors.blueAccent,
                  child: Text(
                    'confirmar',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
          Container(
            width: 140,
            height: 140,
            child: picker,
          )
        ],
      ),
    );
  }

  findTimeDuration(String selectedService) async {
    final DocumentSnapshot service = await Firestore.instance
        .collection('companies')
        .document(widget.uidCompany)
        .collection('services')
        .document(selectedService)
        .get();
    print('duracao: ' + service.data['duration'].toString());
    setState(() {
      timeDurationService = service.data['duration'];
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
                                    print('servico selecionado: ' + serviceValue);
                                    selectedService = serviceValue;
                                  });
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
              SizedBox(
                height: 40,
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
                                timeDurationService = 0;

                              });
                              findTimeDuration(selectedService);
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
              SizedBox(
                height: 40,
              ),
              Visibility(
                  visible: selectedEmployee == null ? false : true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Escolha a data:',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      selectedDate == null
                          ? Text('')
                          : Text(
                              selectedDate.day.toString() +
                                  '/' +
                                  selectedDate.month.toString() +
                                  '/' +
                                  selectedDate.year.toString(),
                              style: TextStyle(fontSize: 20.0),
                            ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          time = false;
                          showDataPicker();
                        },
                      ),
                    ],
                  )),
              SizedBox(
                height: 40,
              ),
              Visibility(
                visible: selectedDate != null ? true : false,
                child: Row(
                  children: <Widget>[
                    Text('Escolha o horário:',
                        style: TextStyle(color: Colors.black, fontSize: 22)),
                    SizedBox(
                      width: 10,
                    ),
                    selectedTime == null
                        ? Text('')
                        : Text(
                            selectedTime.hour.toString() +
                                ':' +
                                selectedTime.minute.toString(),
                            style: TextStyle(fontSize: 20.0),
                          ),
                    IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (BuildContext context) {
//                            int minute =
                              return _buildBottomPicker(
                                CupertinoDatePicker(
                                  minuteInterval: timeDurationService != 0
                                      ? timeDurationService
                                      : 5,
                                  use24hFormat: true,
                                  mode: CupertinoDatePickerMode.time,
                                  initialDateTime: DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      startHour.hour,
                                      startHour.minute),
                                  maximumDate: endHour,
                                  minimumDate: startHour,
                                  onDateTimeChanged: (value) {
                                    setState(() {
                                      selectedDate = value;
                                      selectedTime = value;
                                      time = true;
                                    });
                                    print(time);
                                    print('hora selecionada:' +
                                        selectedTime.toIso8601String());
                                  },
                                ),
                              );
                            },
                          );
                        })
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Visibility(
                  visible: selectedTime == null ? false : true,
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
