import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import 'package:agendei_cliente/screens/home_screen.dart';

class PaymentTab extends StatefulWidget {
  @override
  _PaymentTabState createState() => _PaymentTabState();
}

class _PaymentTabState extends State<PaymentTab> {
  String uidUser;
  String cardNumber = "";
  String cardHolderName = "";
  String expiryDate = "";
  String cvv = "";
  String uidPayment;
  bool existPayment;
  bool showBack = false;
  bool canDelete = false;
  TextEditingController _cardNumber = TextEditingController();
  TextEditingController _cardHolderName = TextEditingController();
  TextEditingController _expiryDate = TextEditingController();
  TextEditingController _cvv = TextEditingController();
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
    getUidUser().then((result) {
      uidUser = result;
      getPayment();
    });
  }

  getUidUser() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) return null;
    return user.uid.toString();
  }

  getPayment() async {
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(uidUser)
        .collection('payments')
        .getDocuments();
    if (querySnapshot.documents.length == 0) {
      setState(() {
        existPayment = false;
        print(existPayment);
      });
    } else {
      if (querySnapshot.documents[0].data != null) {
        setState(() {
          uidPayment = expiryDate = querySnapshot.documents[0].documentID;
          existPayment = true;
          print(existPayment);
          _cardNumber.text = querySnapshot.documents[0].data['cardNumber'];
          _cardHolderName.text =
          querySnapshot.documents[0].data['cardHolderName'];
          _expiryDate.text = querySnapshot.documents[0].data['expiryDate'];
          _cvv.text = querySnapshot.documents[0].data['cvv'];
        });
      }
    }
  }

  void updatePayment() async {
    final Map<String, dynamic> userPayment = {
      'cardNumber': _cardNumber.text,
      'cardHolderName': _cardHolderName.text,
      'expiryDate': _expiryDate.text,
      'cvv': _cvv.text
    };
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(uidUser)
        .collection('payments')
        .getDocuments();
    if (querySnapshot.documents.length == 0) {
      Firestore.instance
          .collection('users')
          .document(uidUser)
          .collection('payments')
          .document()
          .setData(userPayment);
    } else {
      Firestore.instance
          .collection('users')
          .document(uidUser)
          .collection('payments')
          .document(uidPayment)
          .setData(userPayment);
    }
    setState(() {
      existPayment = true;
      showBack = false;
    });
  }

  void deletePayment() async {
    print('pagamento de uid apagado: ' + uidPayment);
    print('user: ' + uidUser);
    await Firestore.instance.collection('users').document(uidUser).collection(
        'payments').document(uidPayment).delete();
    setState(() {
      uidPayment = null;
      existPayment = false;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          CreditCard(
            cardNumber: _cardNumber.text,
            cardExpiry: _expiryDate.text,
            cardHolderName: _cardHolderName.text,
            cvv: _cvv.text,
            bankName: "Banco XXX",
            showBackSide: showBack,
            frontBackground: CardBackgrounds.black,
            backBackground: CardBackgrounds.white,
            showShadow: true,
          ),
          SizedBox(
            height: 40,
          ),
          Visibility(
            visible: existPayment == true ? false : true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    controller: _cardNumber,
                    decoration: InputDecoration(hintText: "Número do cartão"),
                    maxLength: 19,
                    onChanged: (value) {
                      setState(() {
                        _cardNumber.text = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    controller: _expiryDate,
                    decoration: InputDecoration(hintText: "Validade"),
                    maxLength: 5,
                    onChanged: (value) {
                      setState(() {
                        _expiryDate.text = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    controller: _cardHolderName,
                    decoration: InputDecoration(hintText: "Propriétário do cartão"),
                    onChanged: (value) {
                      setState(() {
                        _cardHolderName.text = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: TextFormField(
                    controller: _cvv,
                    decoration: InputDecoration(hintText: "CVV"),
                    maxLength: 3,
                    onChanged: (value) {
                      setState(() {
                        _cvv.text = value;
                      });
                    },
                    focusNode: _focusNode,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Visibility(
                visible: existPayment == true ? true : false,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      existPayment = false;
                      canDelete = true;
                    });
                  },
                  label: Text('Editar cartão'),
                  icon: Icon(Icons.edit),
                  backgroundColor: Color.fromARGB(255, 15, 76, 129),
                ),
              ),
              Visibility(
                visible: existPayment == true ? false : true,
                child: FloatingActionButton.extended(
                  heroTag: 'FloatingActionUpdatePayment',
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('atualizando dados de pagamento',
                        style: TextStyle(color: Colors.white),),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.orange,
                      elevation: 1.0,
                    ));
                    updatePayment();
                    setState(() {
                      canDelete = false;
                    });
                  },
                  label: Text('Atualizar'),
                  icon: Icon(Icons.save),
                  backgroundColor: Color.fromARGB(255, 15, 76, 129)
                ),
              ),
              Visibility(
                visible: canDelete == true ? true : false,
                child: FloatingActionButton.extended(
                  heroTag: 'FloatingActionDeletePayment',
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Cartao apagado com sucesso',
                        style: TextStyle(color: Colors.white),),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.orange,
                      elevation: 1.0,
                    ));
                    deletePayment();
                    setState(() {
                      existPayment = false;
                    });
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  label: Text('Apagar'),
                  icon: Icon(Icons.delete),
                  backgroundColor: Color.fromARGB(255, 15, 76, 129),
                ),
              ),
              Visibility(
                visible: canDelete == true ? false : (
                    existPayment = true ? true : false),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    print('entrou pagina historico');
                    _showToast(context);
                  },
                  label: Text('Histórico'),
                  icon: Icon(Icons.history),
                  backgroundColor: Color.fromARGB(255, 15, 76, 129),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        content: const Text(
          'Nenhuma transação registrada', style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
