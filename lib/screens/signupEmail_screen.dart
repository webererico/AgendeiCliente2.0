import 'dart:io';
//import 'package:agendei_cliente/screens/phoneVerification_screen.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agendei_cliente/models/user_model.dart';
import 'package:agendei_cliente/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

//  final Color _cor1 = Color.fromARGB(255, 25, 25, 112);
//  final Color _cor2 = Color.fromARGB(255, 79, 79, 216);

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adressController = TextEditingController();
  final _passController = TextEditingController();
  final _rePassController = TextEditingController();
  File _image;

//  String _uploadedFileURL;
  String selectedGender;

  Future chooseFile() async {
    print('selecionando imagem');
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
        print('imagem selecionada');
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('imagem Selecionada'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Criar perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[],
      ),
      body: ScopedModelDescendant<UserModel>(builder: (context, child, model) {
        if (model.isLoading)
          return Center(
            child: CircularProgressIndicator(),
          );
        return Form(
          key: _formKey,
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
                        child: _image == null
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
                                backgroundImage: FileImage(_image),
//                                      NetworkImage(_uploadedFileURL),
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
                          decoration: InputDecoration(
                              hintText: "Nome",
                              labelStyle: TextStyle(color: Colors.white),
                              icon: Icon(Icons.person)),
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
                          decoration: InputDecoration(
                            hintText: "Sobrenome",
                            labelStyle: TextStyle(color: Colors.white),
                            icon: Icon(Icons.person_outline),
                          ),
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
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    hintText: "E-mail", icon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (text) {
                  if (text.isEmpty || !text.contains("@")) {
                    return "E-mail inválido";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                    hintText: "Telefone", icon: Icon(Icons.phone)),
                keyboardType: TextInputType.number,
                validator: (text) {
                  if (text.isEmpty || text.length < 9) {
                    return "Telefone inválido";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _adressController,
                decoration: InputDecoration(
                    hintText: "Endereço", icon: Icon(Icons.place)),
                keyboardType: TextInputType.text,
                validator: (text) {
                  if (text.isEmpty) {
                    return "Endereço inválido";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    Icons.assignment_ind,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
//                      style: _fieldStyle,
                    items:
                        <String>['Masculino', 'Feminino'].map((String value) {
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
                      'Genero                                               ',
//                        style: _fieldStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _passController,
                decoration:
                    InputDecoration(hintText: "Senha", icon: Icon(Icons.lock)),
                obscureText: true,
                validator: (text) {
                  if (text.isEmpty || text.length < 6) {
                    return "A senha deve conter no mínimo 6 dígitos";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _rePassController,
                decoration: InputDecoration(
                    hintText: "Repetir senha", icon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (text) {
                  if (text.isEmpty || text.length < 6) {
                    return "Senha inválida";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 32.0,
              ),
              FloatingActionButton.extended(
                  label: Text('Avançar'),
                  backgroundColor: Colors.blueAccent,
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if (_passController.text == _rePassController.text) {
                        if (_image == null) {
                          showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      'Você não escolheu uma imagem para perfil'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Voltar e escolher imagem'),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Map<String, dynamic> userData = {
                                          'name': _nameController.text +
                                              ' ' +
                                              _lastNameController.text,
                                          'email': _emailController.text,
                                          'adress': _adressController.text,
                                          'phone': _phoneController.text,
                                          'gender': selectedGender,
                                        };

                                        print(userData);
                                        model.signUp(
                                            image: _image,
                                            userData: userData,
                                            pass: _passController.text,
                                            onSuccess: _onSuccess,
                                            onFail: _onFail);
                                      },
                                      child: Text('Ignorar'),
                                    ),
                                  ],
                                );
                              });
                        } else {
                          Map<String, dynamic> userData = {
                            'name': _nameController.text +
                                ' ' +
                                _lastNameController.text,
                            'email': _emailController.text,
                            'adress': _adressController.text,
                            'phone': _phoneController.text,
                            'gender': selectedGender,
                          };

                          print(userData);
                          model.signUp(
                              image: _image,
                              userData: userData,
                              pass: _passController.text,
                              onSuccess: _onSuccess,
                              onFail: _onFail);
                        }
                      } else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('As senhas não são iguais'),
                          backgroundColor: Colors.black,
                          duration: Duration(seconds: 2),
                        ));
                      }
                    }
                  }),
            ],
          ),
        );
      }),
    );
  }

  void _onSuccess() async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Usuário criado com sucesso!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
//    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
//        MaterialPageRoute(
//          builder: (context) => PhoneVerificationScreen(
//            uidUser: user.uid,
//          ),
//        ),
      );
    });
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Este e-mail já possui conta ou é inválido'),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));
  }
}
