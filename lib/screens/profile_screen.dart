import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String uidUser = '';
  File _image;
  String uploadedFileURL;
  String newUploaded;
  final _formkey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _oldEmailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _adressController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _rePassController = TextEditingController();
  TextEditingController _imgController = TextEditingController();
  String selectedGender;

//  List<DropdownMenuItem> serviceItems = ['Masculino', 'Feminino'];

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
      uploadFile();
    });
  }

  Future uploadFile() async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://loja-f7ade.appspot.com');
    StorageReference storageReference =
        _storage.ref().child('users/$uidUser/${DateTime.now()}.png');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    _showSnack(context, 'Carregando imagem', Colors.orange);
    await uploadTask.onComplete;

    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        uploadedFileURL = fileURL;
        newUploaded = fileURL;
      });
    });
  }

  getUID() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final snapshot =
        await Firestore.instance.collection('users').document(user.uid).get();
    final uidUser = user.uid.toString();
    _emailController.text = snapshot.data['email'];
    _oldEmailController.text = snapshot.data['email'];
    _adressController.text = snapshot.data['adress'];
    _phoneController.text = snapshot.data['phone'];
    _imgController.text = snapshot.data['img'];
    List<String> names = snapshot.data['name'].toString().split(' ');
    selectedGender = snapshot.data['gender'];

    _nameController.text = names[0];
    _lastNameController.text = names[1];
    for (int i = 2; i < names.length; i++) {
      _lastNameController.text = _lastNameController.text + ' ' + names[i];
    }
    return uidUser;
  }

  void updateDataUser(
      BuildContext context, Map<String, dynamic> userData) async {
    _showSnack(context, 'Atualizando dados', Colors.green);
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    _showSnack(context, 'Dados atualizados!', Colors.orange);
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .updateData(userData);
    print('salvou dados');
  }

  void saveEmail(BuildContext context, String email) async {
    _showSnack(context, 'Atualizando email', Colors.green);
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    _showSnack(context, 'Dados atualizados!', Colors.orange);
    user.updateEmail(email);
    print('salvou novo email');
  }

  void savePass(BuildContext context, String pass) async {
    _showSnack(context, 'Atualizando senha', Colors.green);
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    _showSnack(context, 'Dados atualizados!', Colors.orange);
    print(
        EmailAuthProvider.getCredential(email: 'email', password: 'password'));
    user.updatePassword(pass);
    print('salvou nova senha');
  }

  void _showSnack(BuildContext context, String text, MaterialColor cor) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: cor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    getUID().then((results) {
      setState(() {
        uidUser = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _fieldStyle = TextStyle(
      color: Colors.black,
      fontSize: 16.0,
    );
    InputDecoration _buildDecoration(String label, icone) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        icon: Icon(icone),
      );
    }

    if (uidUser == null) {
      return Container();
    } else {
      return Form(
        key: _formkey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.white24))),
                  child: Hero(
                      tag: 'newAvatar',
                      child: _imgController.text.toString() == null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.withAlpha(100),
                              child: IconButton(
                                icon: Icon(
                                  Icons.photo_camera,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  print('tirar foto');
                                  chooseFile();
                                },
                              ))
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.withAlpha(100),
                              backgroundImage: NetworkImage(newUploaded == null
                                  ? _imgController.text.toString()
                                  : newUploaded),
                              child: InkWell(
                                onTap: () {
                                  chooseFile();
                                },
                              ))),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  width: 200,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        style: _fieldStyle,
                        decoration: _buildDecoration('Nome', Icons.person),
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Nome inválido";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        style: _fieldStyle,
                        decoration:
                            _buildDecoration('Sobrenome', Icons.person_outline),
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Nome inválido";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TextFormField(
              style: _fieldStyle,
              decoration: _buildDecoration('Email', Icons.email),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            TextFormField(
              style: _fieldStyle,
              decoration: _buildDecoration('Endereço', Icons.place),
              controller: _adressController,
            ),
            TextFormField(
              style: _fieldStyle,
              decoration:
                  _buildDecoration('Telefone para contato', Icons.phone),
              keyboardType: TextInputType.number,
              controller: _phoneController,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  style: _fieldStyle,
                  items: <String>['Masculino', 'Feminino'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  value: selectedGender,
                  isExpanded: false,
                  hint: new Text(
                    'Genero                                                     ',
                    style: _fieldStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TextFormField(
              style: _fieldStyle,
              decoration: _buildDecoration('Nova senha', Icons.lock),
              obscureText: true,
              controller: _passController,
            ),
            TextFormField(
              style: _fieldStyle,
              decoration:
                  _buildDecoration('Confirmar senha', Icons.lock_outline),
              obscureText: true,
              controller: _rePassController,
            ),
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (_formkey.currentState.validate()) {
                    if (_passController.text != '' &&
                        _rePassController.text != '') {
                      if (_passController.text == _rePassController.text) {
                        print(_passController.text);
                        if (_passController.text.length > 6) {
                          savePass(context, _passController.text);
                        } else {
                          _showSnack(
                              context,
                              'A senha deve conter no mínimo 6 dígitos',
                              Colors.red);
                        }
                      } else {
                        _showSnack(
                            context, 'As senhas não são iguais', Colors.red);
                      }
                    }
                    _emailController.text =
                        _emailController.text.replaceAll(' ', '');
                    if (_oldEmailController.text != _emailController.text) {
                      saveEmail(
                          context, _emailController.text.replaceAll(' ', ''));
                    }
                    Map<String, dynamic> userData = {
                      'name':
                          _nameController.text + ' ' + _lastNameController.text,
                      'email': _emailController.text != _oldEmailController.text
                          ? _emailController.text
                          : _oldEmailController.text,
                      'adress': _adressController.text,
                      'img': newUploaded == null
                          ? _imgController.text
                          : newUploaded,
                      'phone': _phoneController.text,
                      'gender': selectedGender
                    };
                    updateDataUser(context, userData);
                    new Future.delayed(new Duration(seconds: 4), () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomeScreen()));
                    });
                  }
                },
                label: Text('Atualizar'),
                icon: Icon(Icons.save),
                backgroundColor: Colors.blueAccent,
              ),
            )
          ],
        ),
      );
    }
  }
}
