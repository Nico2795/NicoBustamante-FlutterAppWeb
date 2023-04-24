//Crear ventana emergente con el formulario de inicio de sesion, bloquear y obscurecer el fondo
// Path: lib\login\login.dart
// Language: dart
// Framework: flutter

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba/autenticacion.dart';

import '../../firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_launcher_icons/abs/icon_generator.dart';
import 'package:video_player/video_player.dart';
import 'package:prueba/horizontalDraggable/horizontalDraggable.dart';
import 'package:flutter_launcher_icons/main.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  //funcion para iniciar sesion con google
  Future<bool> signInWithGoogle() async {
    try {
      setState(() {
        estadoInicioSesion = 'Comprobando datos...';
      });
      var resultado = await Auth().signInWithGoogle();
      if (resultado == null) return false;
      final uid = currentUser?.uid;
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!snapshot.exists) {
        // Crear un nuevo documento para el usuario
        Future.delayed(Duration(seconds: 3), () {
          FirebaseFirestore.instance.collection("users").doc(uid).set({
            "uid": uid,
            "email": currentUser?.email,
            "nombre": currentUser?.displayName,
            "foto": currentUser?.photoURL,
            "fecha": DateTime.now(),
          });
        });
      }

      print('Inicio de sesion con google satisfactorio.');
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  //comprobar que el usuario esta logead

  var usuarioLogeado = false;

  //Colores
  var colorScaffold = Color(0xffffebdcac);
  var colorNaranja = Color.fromARGB(255, 255, 79, 52);
  var colorMorado = Color.fromARGB(0xff, 0x52, 0x01, 0x9b);
  //Tamaños
  var ancho_items = 350.0;
  var ancho_login = 500.0;
  Offset _containerPosition = Offset.zero;
  //Controladores
  TextEditingController correoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  //variables login
  var tryLogin = false;
  var tryLogin2 = false;
  var tryLogin3 = false;
  var tryLoginGoogleMobile = false;
  var isLogin = false;
  var estadoInicioSesion = 'Iniciando sesion...';
  var mostrarErrorCorreo = false;
  var mostrarErrorCorreo1 = false;
  var mostrarErrorCorreo2 = false;
  var mensajeErrorCorreo = '';

  var mostrarErrorPassword = false;
  var mostrarErrorPassword1 = false;
  var mostrarErrorPassword2 = false;
  var mensajeErrorPassword = '';

  var mostrarRecuperarPassword = false;

  //variables slider
  var sliderLogo_x = 0.0;

  //variables register
  var showRegister = false;
  var showRegister2 = false;
  var correoExisteRegister = false;
  var correoExisteRegister2 = false;
  var checkPassword = false;
  var checkPassword2 = false;
  var sixChars = false;
  var numberPassw = false;
  var upperCasePassw = false;
  var checkConfirmPassword = false;
  var checkConfirmPassword2 = false;
  var passwordMatch = false;
  var mostrarPassword = false;
  var mostrarConfirmPassword = false;
  var SignInAvailable = false;
  var mostrarErrorCorreoR = false;
  var mostrarErrorCorreoR2 = false;
  var mensajeErrorCorreoR = '';

  Future<void> signInWithEmailAndPassword(String dispositivo) async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: correoController.text,
        password: passwordController.text,
      );
      tryLogin = false;

      print('Inicio de sesión satisfactorio en FIREBASE.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorLogin('email no encontrado', 'correo', dispositivo);
      } else if (e.code == 'wrong-password') {
        errorLogin('password incorrecta', 'contraseña', dispositivo);
      }
    } catch (e) {
      print(e);
    }
  }

  void errorLogin(String error, String campo, String dispositivo) {
    campo == 'correo'
        ? setState(() {
            mostrarErrorCorreo = true;

            if (error == 'email vacio') {
              mensajeErrorCorreo = dispositivo == 'web'
                  ? 'El campo de correo no puede estar vacio'
                  : 'Correo no puede estar vacio';
            } else if (error == 'email no encontrado') {
              mensajeErrorCorreo = dispositivo == 'web'
                  ? 'El correo introducido no existe'
                  : 'Correo no existe';
            }

            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                mostrarErrorCorreo1 = true;
              });
            });
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                mostrarErrorCorreo2 = true;
              });
            });
          })
        : setState(() {
            mostrarErrorPassword = true;

            if (error == 'passw vacio') {
              mensajeErrorPassword = dispositivo == 'web'
                  ? 'La contraseña no puede estar vacia'
                  : 'Contraseña no puede estar vacia';
            } else if (error == 'password incorrecta') {
              mensajeErrorPassword = dispositivo == 'web'
                  ? 'La contraseña introducida es incorrecta'
                  : 'Contraseña incorrecta';
            }
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                mostrarErrorPassword1 = true;
              });
            });
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                mostrarErrorPassword2 = true;
              });
            });
          });
  }

  Widget btnIniciarSesion(double fontSize, String dispositivo) {
    return (Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          if (correoController.text != '' &&
              correoController.text.contains('@') &&
              passwordController.text != '') {
            signInWithEmailAndPassword(dispositivo);
          } else {
            if (correoController.text.isEmpty) {
              errorLogin('email vacio', 'correo', dispositivo);
            }
            if (passwordController.text.isEmpty) {
              errorLogin('passw vacio', 'contraseña', dispositivo);
            }
          }
        },
        child: Text(
          "Iniciar Sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: colorNaranja,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ));
  }

  Widget btnIniciarSesionGoogle(double fontSize, String dispositivo) {
    return (Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            tryLogin = !tryLogin;
            tryLoginGoogleMobile = !tryLoginGoogleMobile;
          });
          if (dispositivo == 'web') {
          } else if (dispositivo == 'mobile') {
            Future.delayed(Duration(milliseconds: 1000), () {
              signInWithGoogle();
            });
          }
        },
        child: Text(
          "Iniciar Sesión con Google",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: colorMorado,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ));
  }

  Widget btnRegistro(double fontSize, String dispositivo) {
    return (Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (dispositivo == 'web') {
            setState(() {
              showRegister = !showRegister;
            });
            Future.delayed(Duration(milliseconds: 1500), () {
              setState(() {
                showRegister2 = !showRegister2;
              });
            });
          } else if (dispositivo == 'mobile') {
            setState(() {
              tryLogin = !tryLogin;
            });
            Future.delayed(Duration(milliseconds: 1500), () {
              setState(() {
                tryLogin2 = !tryLogin2;
              });
            });
          }
        },
        child: Text(
          "Soy nuevo",
          style: TextStyle(
            color: colorNaranja,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(0, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorNaranja, width: 2),
          ),
        ),
      ),
    ));
  }

  Widget btnsLogin(double fontSize, String dispositivo) {
    return (Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        btnIniciarSesion(fontSize, dispositivo),
        btnIniciarSesionGoogle(fontSize, dispositivo),
        btnRegistro(fontSize, dispositivo)
      ],
    ));
  }

  Widget tituloLogin(double fontSize) {
    return (Center(
      child: Text(
        "Adentrate en el fantastico mundo del café",
        style: TextStyle(
          color: colorNaranja,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }

  Future<bool> isEmailRegistered(String email, String contexto) async {
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  Widget textFieldCorreo(
      TextEditingController controller, double fontSize, String ventana) {
    return (TextField(
      onTap: () {
        comprobarPassword();
      },
      controller: controller,
      onChanged: (value) {
        if (ventana == 'register') {
          isEmailRegistered(value, ventana).then((value) {
            setState(() {
              mostrarErrorCorreoR = value;
              correoExisteRegister = value;
              mensajeErrorCorreoR = 'El correo introducido ya existe';
            });
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                mostrarErrorCorreoR2 = value;
              });
            });
          });
          if (controller.text.length > 0 && correoExisteRegister) {
            setState(() {
              mostrarErrorCorreoR2 = false;
            });
            Future.delayed(Duration(milliseconds: 400), () {
              setState(() {
                mostrarErrorCorreoR = false;
              });
            });
          }
        } else {
          if (controller.text.length > 0) {
            setState(() {
              mostrarErrorCorreo2 = false;
              mostrarErrorCorreo1 = false;
            });
            Future.delayed(Duration(milliseconds: 400), () {
              setState(() {
                mostrarErrorCorreo = false;
              });
            });
          }
        }
      },
      style: TextStyle(color: colorNaranja, fontSize: fontSize),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email, color: colorNaranja, size: 24),
        suffixIcon: Visibility(
            visible: (ventana == 'login') ? correoExisteRegister : false,
            child: Icon(Icons.check,
                color: Color.fromARGB(255, 84, 14, 148), size: 20)),
        hintText: "Correo",
        hintStyle: TextStyle(
          fontSize: fontSize,
          color: colorNaranja,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorNaranja, // Aquí puedes asignar el color que desees
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: colorNaranja,
              width: 2 // Aquí puedes asignar el color que desees
              ),
        ),
      ),
    ));
  }

  Widget textFieldPassword(
      TextEditingController controller, double fontSize, String ventana) {
    return TextField(
      onChanged: (value) {
        if (ventana == 'register') {
          if (value.length > 0) {
            setState(() {
              checkPassword = true;
            });
            if (value.contains(RegExp(r'[0-9]'))) {
              numberPassw = true;
            } else {
              numberPassw = false;
            }
            if (value.contains(RegExp(r'[A-Z]'))) {
              upperCasePassw = true;
            } else {
              upperCasePassw = false;
            }

            if (value.length > 5) {
              setState(() {
                sixChars = true;
              });
            } else {
              setState(() {
                sixChars = false;
              });
            }

            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                checkPassword2 = true;
              });
            });
          } else {
            setState(() {
              checkPassword2 = false;
            });
            Future.delayed(Duration(milliseconds: 500), () {
              setState(() {
                checkPassword = false;
              });
            });
          }

          print(checkPassword);
        } else {
          if (controller.text.length > 0) {
            setState(() {
              mostrarErrorPassword2 = false;
              mostrarErrorPassword1 = false;
            });
            Future.delayed(Duration(milliseconds: 400), () {
              setState(() {
                mostrarErrorPassword = false;
              });
            });
          }
        }
      },
      controller: controller,
      obscureText: !mostrarPassword ? true : false,
      style: TextStyle(color: colorNaranja, fontSize: fontSize),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(mostrarPassword
              ? Icons.remove_red_eye
              : Icons.remove_red_eye_outlined),
          color: colorNaranja,
          iconSize: 24,
          onPressed: () {
            setState(() {
              mostrarPassword = !mostrarPassword;
            });
          },
        ),
        prefixIcon: Icon(Icons.lock, color: colorNaranja, size: 24),
        hintText: "Contraseña",
        hintStyle: TextStyle(color: colorNaranja, fontSize: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorNaranja, // Aquí puedes asignar el color que desees
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: colorNaranja,
              width: 2 // Aquí puedes asignar el color que desees
              ),
        ),
      ),
    );
  }

  void comprobarPassword() {
    if (sixChars && numberPassw && upperCasePassw) {
      setState(() {
        checkPassword2 = false;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          checkPassword = false;
        });
      });
    }
  }

  Widget textFieldConfirmPassword(
      TextEditingController controller, double fontSize) {
    return TextField(
      onTap: () {
        comprobarPassword();
      },
      onChanged: (value) {
        setState(() {
          checkConfirmPassword = true;
          if (value == passwordController.text) {
            passwordMatch = true;
            Future.delayed(Duration(milliseconds: 2000), () {
              setState(() {
                checkConfirmPassword2 = false;
              });
            });
            Future.delayed(Duration(milliseconds: 2500), () {
              setState(() {
                checkConfirmPassword = false;
              });
            });
          } else {
            passwordMatch = false;
          }
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              checkConfirmPassword2 = true;
            });
          });
        });

        print(
            "passwords match $value ${passwordController.text} $passwordMatch");
      },
      controller: controller,
      style: TextStyle(color: colorNaranja, fontSize: fontSize),
      obscureText: !mostrarConfirmPassword ? true : false,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: colorNaranja, size: 24),
        suffixIcon: IconButton(
          icon: Icon(mostrarConfirmPassword
              ? Icons.remove_red_eye
              : Icons.remove_red_eye_outlined),
          color: colorNaranja,
          iconSize: 24,
          onPressed: () {
            setState(() {
              mostrarConfirmPassword = !mostrarConfirmPassword;
            });
          },
        ),
        hintText: "Confirmar contraseña",
        hintStyle: TextStyle(color: colorNaranja, fontSize: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: colorNaranja, // Aquí puedes asignar el color que desees
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: colorNaranja,
              width: 2 // Aquí puedes asignar el color que desees
              ),
        ),
      ),
    );
  }

  //hacer que sliderLogo se mueva de forma suave a la derecha al
  GlobalKey sliderKey = GlobalKey();

  double _getPosition(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final posWidget = renderBox.localToGlobal(Offset.zero).dx;
    print("POSITION of Red: $posWidget ");
    return posWidget;
  }

  Widget logo() {
    return (Container(
      width: 500,
      height: 700,
      child: Center(child: Image.asset("assets/logo.png")),
      decoration: BoxDecoration(
          color: colorNaranja,
          borderRadius: BorderRadius.all(Radius.circular(20))),
    ));
  }

  Widget sliderLogo() {
    return (Container(
      width: (tryLogin || showRegister) ? 1000 : 500,
      height: 700,
      decoration: BoxDecoration(
          //color: Colors.black,
          ),
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            left: tryLogin || showRegister ? 500 : 0,
            onEnd: () {
              if (tryLogin) {
                setState(() {
                  tryLogin2 = !tryLogin2;
                  Future.delayed(Duration(milliseconds: 1500), () {
                    signInWithGoogle();
                  });
                });
              }
            }, // here 90 is (200(above container)-110(container which is animating))
            child: InkWell(
                onTap: () {
                  setState(() {
                    tryLogin = !tryLogin;
                  });
                },
                child: logo()),
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          ),
        ],
      ),
    ));
  }

  Widget containerErrorLogin(String tipoError, String dispositivo) {
    return (AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: tipoError == 'correo'
          ? (mostrarErrorCorreo1 ? 50 : 0)
          : (mostrarErrorPassword1 ? 50 : 0),
      width: ancho_login,
      decoration: BoxDecoration(
          color: colorNaranja,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: mostrarErrorCorreo2 || mostrarErrorPassword2
          ? Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (tipoError == 'correo')
                        ? mensajeErrorCorreo
                        : mensajeErrorPassword,
                    style: TextStyle(
                        color: colorMorado, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.error,
                    color: colorMorado,
                  )
                ],
              ),
            )
          : Container(),
    ));
  }

  Widget vistaLogin(String dispositivo) {
    var fontSize = dispositivo == "web" ? 22.0 : 12.0;
    return (AnimatedOpacity(
      duration: Duration(milliseconds: 1000),
      opacity: tryLogin ? 0 : 1,
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //color: Colors.black,
            child: tituloLogin(fontSize),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            height: 50,
            child: textFieldCorreo(correoController, fontSize, 'login'),
          ),
          mostrarErrorCorreo
              ? containerErrorLogin('correo', dispositivo)
              : Container(),
          SizedBox(
            height: 20,
          ),
          Container(
              height: 50,
              child: textFieldPassword(passwordController, fontSize, 'login')),
          mostrarErrorPassword
              ? containerErrorLogin('contraseña', dispositivo)
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              textOlvidoContrasena(fontSize),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: btnsLogin(fontSize, dispositivo),
            //color: Colors.black,
            height: 200,
          )
        ],
      )),
    ));
  }

  Widget containerCargandoLogin() {
    return (Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          child: Text(estadoInicioSesion,
              style: TextStyle(
                  color: colorNaranja,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          margin: EdgeInsets.only(bottom: 20),
        ),
        CircularProgressIndicator(
          color: colorNaranja,
          strokeWidth: 5,
        ),
      ]),
    ));
  }

  Widget vistaCargando(String interfaz) {
    return (interfaz != 'web'
        ? Expanded(child: containerCargandoLogin())
        : containerCargandoLogin());
  }

  Widget tituloRegister(double fontSize) {
    return Container(
      child: (Text(
        "Unete a la comunidad N°1 de cafeterias en linea",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: colorNaranja,
            fontSize: fontSize,
            fontWeight: FontWeight.bold),
      )),
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        // Se utilizan los strings ingresados por el usuario para almacenar su email y contrasena en firebase auth
        email: correoController.text,
        password: passwordController.text,
      );
      print('Cuenta de usuario creada en FIREBASE satisfactoriamente.');
      // pushReplacement remplazará la pantalla actual en la pila de navegacion por la nueva pantalla,
      //lo que significa que el usuario no podra volver a la pantalla anterior al presionar el botón
      //"Atrás" en su dispositivo.
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Tu contrasena es muy debil.');
      } else if (e.code == 'email-already-in-use') {
        //error_register = 'El correo electronico ya esta en uso.';
        setState(() {
          //_visible_errormsj = true;
        });
        //print(error_register);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget btnRegister(double fontSize) {
    return (Container(
      height: 50,
      width: ancho_items,
      child: ElevatedButton(
        onPressed: () {
          print('Password Match $passwordMatch');
          print('6 chars $sixChars');
          print('uppercase $upperCasePassw');
          print('number $numberPassw');
          print(
              'Email valido ${correoController.text != '' && correoController.text.contains('@')}');
          print('Email existe ${correoExisteRegister2}}');
          print(
              'password completed ${passwordController.text != '' && passwordConfirmController.text != ''}');
          if (passwordMatch &&
              sixChars &&
              numberPassw &&
              upperCasePassw &&
              correoController.text != '' &&
              correoController.text.contains('@') &&
              !correoExisteRegister2 &&
              passwordController.text != '' &&
              passwordConfirmController.text != '') {
            createUserWithEmailAndPassword();
            print('Crear usuario');
          } else {
            if (correoExisteRegister2) {
              print('El correo ya existe');
            } else if (correoController.text == '') {
              print('El correo esta vacio');
              setState(() {
                mostrarErrorCorreoR = true;
                mensajeErrorCorreoR = 'El correo esta vacio';
              });
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  mostrarErrorCorreoR2 = true;
                });
              });
            } else if (!correoController.text.contains('@')) {
              print('El correo no es valido');
              setState(() {
                mostrarErrorCorreoR = true;
                mensajeErrorCorreoR = 'El correo no es valido';
              });
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() {
                  mostrarErrorCorreoR2 = true;
                });
              });
            } else if (passwordController.text == '' ||
                passwordConfirmController.text == '') {
              setState(() {
                checkPassword = true;
                Future.delayed(Duration(milliseconds: 500), () {
                  setState(() {
                    checkPassword2 = true;
                  });
                });
              });
            } else if (!passwordMatch) {
              print('Las contrasenas no coinciden');
            } else if (!sixChars) {
              print('La contrasena debe tener 6 caracteres');
            } else if (!upperCasePassw) {
              print('La contrasena debe tener al menos una mayuscula');
            } else if (!numberPassw) {
              print('La contrasena debe tener al menos un numero');
            }
          }
        },
        child: Text(
          "Crear cuenta",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: colorNaranja,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ));
  }

  Widget columnaErrorPassword(String tipo_error, double fontSize) {
    return (Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Debes ingresar 6 caracteres',
              style: TextStyle(color: colorNaranja, fontSize: fontSize),
            ),
            Icon(
              sixChars ? Icons.check_circle : Icons.cancel,
              color: colorNaranja,
              size: 18,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Se requiere almenos un numero',
              style: TextStyle(color: colorNaranja, fontSize: fontSize),
            ),
            Icon(
              numberPassw ? Icons.check_circle : Icons.cancel,
              color: colorNaranja,
              size: 18,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Se requiere almenos una mayuscula',
              style: TextStyle(color: colorNaranja, fontSize: fontSize),
            ),
            Icon(
              upperCasePassw ? Icons.check_circle : Icons.cancel,
              color: colorNaranja,
              size: 18,
            )
          ],
        )
      ],
    ));
  }

  Widget errorRegister(String tipo_error, double fontSize) {
    return (AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
          color: colorMorado, borderRadius: BorderRadius.circular(20)),
      height: (mostrarErrorCorreoR && tipo_error == 'email')
          ? 40
          : (checkPassword && tipo_error == 'password')
              ? 80
              : (checkConfirmPassword && tipo_error == 'confirm_password')
                  ? 40
                  : 0,
      child: Container(
        margin: EdgeInsets.all(10),
        child: tipo_error == 'password'
            ? checkPassword2
                ? columnaErrorPassword(tipo_error, fontSize)
                : Container()
            : tipo_error == 'email' && mostrarErrorCorreoR2
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mensajeErrorCorreoR,
                        style:
                            TextStyle(color: colorNaranja, fontSize: fontSize),
                      ),
                      Icon(
                        Icons.cancel,
                        color: colorNaranja,
                        size: 18,
                      )
                    ],
                  )
                : (tipo_error == 'confirm_password' && checkConfirmPassword)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Las contraseñas deben coincidir',
                            style: TextStyle(
                                color: colorNaranja, fontSize: fontSize),
                          ),
                          Icon(
                            passwordMatch ? Icons.check_circle : Icons.cancel,
                            color: colorNaranja,
                            size: 18,
                          )
                        ],
                      )
                    : Container(),
      ),
    ));
  }

  Widget textOlvidoContrasena(double fontSize) {
    return GestureDetector(
      onTap: () {
        setState(() {
          mostrarRecuperarPassword = !mostrarRecuperarPassword;
          sliderLogo_x = _getPosition(sliderKey);
        });
      },
      child: Container(
        child: Text(
          "¿Olvidaste tu contraseña?",
          textAlign: TextAlign.end,
          style: TextStyle(
            color: colorNaranja,
            fontSize: fontSize - 5,
            //fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget vistaRegister(String dispositivo) {
    var fontSize = dispositivo == "web" ? 22.0 : 12.0;
    return (AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: tryLogin ? 0 : 1,
      child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              tituloRegister(fontSize),
              Container(
                height: 50,
                child: textFieldCorreo(correoController, fontSize, 'register'),
              ),
              errorRegister('email', fontSize),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: 50,
                  child: textFieldPassword(
                      passwordController, fontSize, 'register')),
              errorRegister('password', fontSize),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: 50,
                  child: textFieldConfirmPassword(
                      passwordConfirmController, fontSize)),
              errorRegister('confirm_password', fontSize),
              SizedBox(
                height: 20,
              ),
              Container(
                child: btnRegister(fontSize),
              )
            ],
          )),
    ));
  }

  Widget loginWeb() {
    return (Dialog(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      child: Container(
        height: 700,
        width: 1000,
        decoration: BoxDecoration(
          color: colorScaffold,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            showRegister2
                ? Container(
                    child: vistaRegister('web'),
                    width: 500,
                    color: Colors.transparent,
                  )
                : Container(),
            tryLogin2 ? vistaCargando('login') : Container(),
            tryLogin2 || showRegister2 ? logo() : sliderLogo(),
            Container(
              child: (tryLogin || showRegister || mostrarRecuperarPassword)
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: vistaLogin('web'),
                    ),
              color: Colors.transparent,
              width: (tryLogin || showRegister || mostrarRecuperarPassword)
                  ? 0
                  : 500,
              //color: Colors.black,
            ),
          ],
        ),
      ),
    ));
  }

  Widget loginMobile() {
    if (tryLogin2) {
      setState(() {
        tryLogin = false;
      });
    }
    return (Dialog(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        child: Container(
          decoration: BoxDecoration(
              color: colorScaffold, borderRadius: BorderRadius.circular(40)),
          height: 650,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: tryLogin2
                ? vistaRegister('mobile')
                : tryLoginGoogleMobile
                    ? vistaCargando('mobile')
                    : vistaLogin('mobile'),
            margin: EdgeInsets.symmetric(horizontal: 10),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    final ancho_pantalla = MediaQuery.of(context).size.width;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        //print(user.uid);
        setState(() {
          usuarioLogeado = true;
        });
      }
    });
    //print(ancho_pantalla);
    return (usuarioLogeado)
        ? Container()
        : (ancho_pantalla > 1315)
            ? loginWeb()
            : loginMobile();
  }
}

class HorizontalDraggableWidget extends StatefulWidget {
  final Widget child;

  HorizontalDraggableWidget({required this.child});

  @override
  _HorizontalDraggableWidgetState createState() =>
      _HorizontalDraggableWidgetState();
}

class _HorizontalDraggableWidgetState extends State<HorizontalDraggableWidget> {
  double _xOffset = 0.0;
  double _startX = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        _startX = details.localPosition.dx;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _xOffset += details.localPosition.dx - _startX;
          _startX = details.localPosition.dx;
        });
      },
      child: Transform.translate(
        offset: Offset(
            (_xOffset > 0)
                ? (_xOffset < 390)
                    ? _xOffset
                    : 390
                : 0,
            0),
        child: widget.child,
      ),
    );
  }
}
