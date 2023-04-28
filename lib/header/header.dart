//hacer widget header
import 'dart:html';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:prueba/autenticacion.dart';
import 'package:prueba/login/login.dart';
import 'package:prueba/sliderImagenesHeader/dataFrame.dart';
import 'package:prueba/ventanas/coffeeUI/allCoffees.dart';
import 'package:prueba/ventanas/coffeeUI/coffeeSavedUI.dart';
import 'package:prueba/ventanas/dataUI.dart';
import 'package:prueba/ventanas/feedbackUI/AllfeedbackUI.dart';
import 'package:prueba/ventanas/feedbackUI/myFeedbackUI.dart';
import 'package:prueba/ventanas/feedbackUI/savedFeedbackUI.dart';
import 'package:prueba/ventanas/eventosUI/allEvents.dart';
import 'package:prueba/ventanas/eventosUI/myEventsUI.dart';
import 'package:prueba/ventanas/eventosUI/eventsSavedUI.dart';
import 'package:prueba/ventanas/shoppingUI/shoppingCartUI.dart';

import 'package:prueba/ventanas/visionUI.dart';

import 'package:prueba/ventanas/coffeeUI/myCoffeeUI.dart';

class Header extends StatefulWidget {
  final double ancho_pantalla;
  final bool usuarioLogueado;

  Header(this.ancho_pantalla, this.usuarioLogueado);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  void initState() {
    super.initState();
  }

  var openLogin = false;
  var openLogin2 = false;
  var openDataVision = false;
  var horario = false;
  var usuarioLogeado = false;

  //Colores
  var colorScaffold = Color(0xffffebdcac);
  var colorNaranja = Color.fromARGB(255, 255, 79, 52);
  var colorMorado = Color.fromARGB(0xff, 0x52, 0x01, 0x9b);

  //BOTONES DE NAVEGACION
  var hoverMenuNavBar = [false, false, false, false, false, false, false];
  var hoverMenuSideBar = false;
  var sideBar = false;
  var sideBar2 = false;
  var sideBar3 = false;

  var openVision = false;
  var openVision2 = false;

  var openData = false;
  var openData2 = false;

  var openAllCoffees = false;
  var openAllCoffees2 = false;
  var coffeeUI = '';

  var openAllEvents = false;
  var openAllEvents2 = false;
  var eventsUI = "";

  var openAllfeedback = false;
  var openAllfeedback2 = false;

  var openMyCoffees = false;
  var openMyCoffees2 = false;

  var openMyFeedback = false;
  var openMyFeedback2 = false;

  var openMyEvents = false;
  var openMyEvents2 = false;

  var openSavedCoffees = false;
  var openSavedCoffees2 = false;

  var openSavedFeedback = false;
  var openSavedFeedback2 = false;

  var openSavedEvents = false;
  var openSavedEvents2 = false;

  var openFeedback = false;
  var openFeedback2 = false;
  var feedbackUI = '';

  var openShoppingCart = false;
  var openShoppingCart2 = false;
  var shoppingUI = "";

  var mostrarMenuCafeteria = false;
  var mostrarMenuCafeteria2 = false;
  var mostrarMenuResena = false;
  var mostrarMenuResena2 = false;
  var mostrarMenuServicio = false;
  var mostrarMenuServicio2 = false;
  var mostrarMenuEvento = false;
  var mostrarMenuEvento2 = false;
  var mostrarMenuCuenta = false;
  var mostrarMenuCuenta2 = false;

  var mostrarVisionAI = false;

  List<dynamic> activarSubMenuBtnSSB = ['', false, false];

  var hoverSideBar = false;
  var hoverSubSideBar = false;

  String dispositivo = '';
  Widget logoMenu() {
    return (Container(
      alignment: Alignment.center,
      child: Image(
        image: AssetImage('assets/logo.png'),
        fit: BoxFit.fill,
      ),
    ));
  }

  Widget btnIndexMenu() {
    return (GestureDetector(
      onTap: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => dataFrame(
                        imagenes: [
                          Image(
                            image: AssetImage('assets/MUJER.jpg'),
                            fit: BoxFit.cover,
                          ),
                          Image(
                            image: AssetImage('assets/hombre2.png'),
                            fit: BoxFit.cover,
                          ),
                        ],
                        usuario: true,
                      )));
        });
      },
      child: Container(
          child: Text(
        'COFFEEMONDO',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Impact',
            fontSize: 22,
            fontWeight: FontWeight.bold),
      )),
    ));
  }

  Widget btnLoginMenu() {
    return (GestureDetector(
      onTap: () {
        setState(() {
          openLogin = !openLogin;
        });
      },
      child: Container(
          child: Text(
        'INGRESO',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Impact',
            fontSize: 22,
            fontWeight: FontWeight.bold),
      )),
    ));
  }

  Future<void> cerrarSesion() async {
    await Auth().signOut();
    print('Usuario ha cerrado sesion');
  }

  Widget btnRegistroMenu() {
    return (GestureDetector(
      onTap: () {
        widget.usuarioLogueado ? cerrarSesion() : print('registrando...');
      },
      child: Container(
          child: Text(
        widget.usuarioLogueado ? 'CERRAR SESION' : 'REGISTRO',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Impact',
            fontSize: 22,
            fontWeight: FontWeight.bold),
      )),
    ));
  }

  Widget btnCredenciales() {
    return (GestureDetector(
      onTap: () {},
      child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.height * 0.03,
          color: colorNaranja,
          child: Center(
            child: Text(
              'INICIAR SESION',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Impact',
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )),
    ));
  }

  Widget DataVision() {
    return (Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.5,
              color: colorNaranja,
              child: Center(
                child: Text(
                  'DATOS DE VISION',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Impact',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
                color: colorMorado,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                    child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    child: Text(
                      'Abrir Data Studio',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )))
          ],
        ),
      ),
    ));
  }

  Future<void> signOut() async {
    await Auth().signOut();
    print('Ha cerrado sesion');
  }

  void abrirLogin() {
    setState(() {
      openLogin = !openLogin;
      Future.delayed(Duration(milliseconds: 500), () {
        openLogin2 = !openLogin2;
      });
    });
  }

  void abrirSideBar() {
    setState(() {
      sideBar = !sideBar;
    });
    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        sideBar2 = !sideBar2;
      });
    });
    Future.delayed(Duration(milliseconds: 1300), () {
      setState(() {
        sideBar3 = !sideBar3;
      });
    });
  }

  void abrirSubMenu(String menu) {
    setState(() {
      if (menu == 'Cafeterias') {
        mostrarMenuCafeteria = true;
        cerrarSubMenu('Reseñas');
        cerrarSubMenu('Servicios');
        cerrarSubMenu('Eventos');
        Future.delayed(Duration(milliseconds: 500), () {
          mostrarMenuCafeteria2 = true;
        });
      } else if (menu == 'Reseñas') {
        mostrarMenuResena = true;
        cerrarSubMenu('Cafeterias');
        cerrarSubMenu('Servicios');
        cerrarSubMenu('Eventos');
        Future.delayed(Duration(milliseconds: 500), () {
          mostrarMenuResena2 = true;
        });
      } else if (menu == 'Servicios') {
        mostrarMenuServicio = true;
        cerrarSubMenu('Cafeterias');
        cerrarSubMenu('Reseñas');
        cerrarSubMenu('Eventos');
        cerrarSubMenu('Mi cuenta');
        Future.delayed(Duration(milliseconds: 500), () {
          mostrarMenuServicio2 = true;
        });
      } else if (menu == 'Eventos') {
        mostrarMenuEvento = true;
        cerrarSubMenu('Cafeterias');
        cerrarSubMenu('Reseñas');
        cerrarSubMenu('Servicios');
        cerrarSubMenu('Mi cuenta');
        Future.delayed(Duration(milliseconds: 500), () {
          mostrarMenuEvento2 = true;
        });
      } else if (menu == 'Carrito') {
        openShoppingCart = true;
        cerrarSubMenu('Cafeterias');
        cerrarSubMenu('Reseñas');
        cerrarSubMenu('Servicios');
        cerrarSubMenu('Mi cuenta');
        Future.delayed(Duration(milliseconds: 500), () {
          openShoppingCart2 = true;
        });
      } else if (menu == 'Mi cuenta') {
        mostrarMenuCuenta = true;
        cerrarSubMenu('Cafeterias');
        cerrarSubMenu('Reseñas');
        cerrarSubMenu('Servicios');
        cerrarSubMenu('Eventos');
        Future.delayed(Duration(milliseconds: 500), () {
          mostrarMenuCuenta2 = true;
        });
      }
    });
  }

  void cerrarSubMenu(String menu) {
    setState(() {
      if (menu == 'Cafeterias') {
        mostrarMenuCafeteria2 = false;
        Future.delayed(Duration(milliseconds: 100), () {
          mostrarMenuCafeteria = false;
        });
      } else if (menu == 'Reseñas') {
        mostrarMenuResena2 = false;
        Future.delayed(Duration(milliseconds: 100), () {
          mostrarMenuResena = false;
        });
      } else if (menu == 'Servicios') {
        mostrarMenuServicio2 = false;
        Future.delayed(Duration(milliseconds: 100), () {
          mostrarMenuServicio = false;
        });
      } else if (menu == 'Eventos') {
        mostrarMenuEvento2 = false;
        Future.delayed(Duration(milliseconds: 100), () {
          mostrarMenuEvento = false;
        });
      } else if (menu == 'Mi cuenta') {
        mostrarMenuCuenta2 = false;
        Future.delayed(Duration(milliseconds: 100), () {
          mostrarMenuCuenta = false;
        });
      } else if (menu == 'Todos') {
        mostrarMenuCafeteria2 = false;
        mostrarMenuResena2 = false;
        mostrarMenuServicio2 = false;
        mostrarMenuEvento2 = false;
        mostrarMenuCuenta2 = false;
        Future.delayed(Duration(milliseconds: 100), () {
          mostrarMenuCafeteria = false;
          mostrarMenuResena = false;
          mostrarMenuServicio = false;
          mostrarMenuEvento = false;
          mostrarMenuCuenta = false;
        });
      }
    });
  }

/*   void cerrarSideBar() {
    setState(() {
      sideBar3 = !sideBar3;
    });
    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        sideBar2 = !sideBar2;
      });
    });
    Future.delayed(Duration(milliseconds: 1300), () {
      setState(() {
        sideBar = !sideBar;
      });
    });
  } */

  void cerrarModuloCafeteria(String modulo) {
    setState(() {
      if (modulo == 'Cafeterias') {
        openAllCoffees = false;
        openAllCoffees2 = false;
        openMyCoffees = false;
        openMyCoffees2 = false;
        openSavedCoffees = false;
        openSavedCoffees2 = false;
      }
    });
  }

  void cerrarModuloEventos(String modulo) {
    setState(() {
      if (modulo == 'Eventos') {
        openAllEvents = false;
        openAllEvents2 = false;
        openMyEvents = false;
        openMyEvents2 = false;
        openSavedEvents = false;
        openSavedEvents2 = false;
      }
    });
  }

  void cerrarModuloCarrito(String modulo) {
    setState(() {
      if (modulo == 'Carrito') {
        openShoppingCart = false;
        openShoppingCart2 = false;
      }
    });
  }

  void mostrarVision() {
    setState(() {
      openVision = true;
      openLogin2 = false;
      openLogin = false;
      cerrarModuloCafeteria('Cafeterias');
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openVision2 = true;
    });
  }

  void cerrarVision() {
    setState(() {
      openVision2 = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openVision = false;
    });
  }

  void mostrarData() {
    cerrarModuloCafeteria('Cafeterias');
    setState(() {
      openData = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openData2 = true;
    });
  }

  void cerrarData() {
    setState(() {
      openData2 = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openData = false;
    });
  }

  void mostrarLogin() {
    setState(() {
      openLogin = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openLogin2 = true;
    });
  }

  void cerrarLogin() {
    setState(() {
      openLogin2 = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      openLogin = false;
    });
  }

  void disparadorBtnSideBar(String menu, bool value) {
    setState(() {
      hoverSideBar = value;
      value
          ? abrirSubMenu(menu)
          : !hoverSubSideBar
              ? Future.delayed(
                  Duration(milliseconds: 200),
                  () {
                    if (!hoverSubSideBar && !hoverSideBar) {
                      cerrarSubMenu(menu);
                    }
                  },
                )
              : null;
    });
  }

  Widget btnSideBar(String menu, IconData icono) {
    return (Container(
        width: 130,
        //color: Colors.white,
        child: InkWell(
          onHover: (value) => {
            print(value),
            dispositivo == 'PC' ? disparadorBtnSideBar(menu, value) : null
          },
          onTap: () {
            if (menu == 'Cafeterias') {
              dispositivo != 'PC'
                  ? mostrarMenuCafeteria
                      ? cerrarSubMenu(menu)
                      : abrirSubMenu(menu)
                  : cerrarSubMenu(menu);
            } else if (menu == 'Reseñas') {
              dispositivo != 'PC'
                  ? mostrarMenuResena
                      ? cerrarSubMenu(menu)
                      : abrirSubMenu(menu)
                  : cerrarSubMenu(menu);
            } else if (menu == 'Servicios') {
              dispositivo != 'PC'
                  ? mostrarMenuServicio
                      ? cerrarSubMenu(menu)
                      : abrirSubMenu(menu)
                  : cerrarSubMenu(menu);
            } else if (menu == 'Eventos') {
              dispositivo != 'PC'
                  ? mostrarMenuEvento
                      ? cerrarSubMenu(menu)
                      : abrirSubMenu(menu)
                  : cerrarSubMenu(menu);
            } else if (menu == 'Carrito') {
              dispositivo != 'PC' ? openShoppingCart : abrirCarritoUI(menu);
            } else if (menu == 'Mi cuenta') {
              dispositivo != 'PC'
                  ? mostrarMenuCuenta
                      ? cerrarSubMenu(menu)
                      : abrirSubMenu(menu)
                  : cerrarSubMenu(menu);
            } else if ((menu == 'Cerrar sesion')) {
              cerrarSesion();
            } else if (menu == 'Iniciar sesion') {
              openLogin2 ? cerrarLogin() : abrirLogin();
            }
          },
          child: Container(
            decoration: BoxDecoration(
                //color: colorMorado,
                ),
            child: Column(
              children: [
                FilledButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent)),
                  onPressed: () {
                    if (menu == 'Cafeterias') {
                      dispositivo != 'PC'
                          ? mostrarMenuCafeteria
                              ? cerrarSubMenu(menu)
                              : abrirSubMenu(menu)
                          : cerrarSubMenu(menu);
                    } else if (menu == 'Reseñas') {
                      dispositivo != 'PC'
                          ? mostrarMenuResena
                              ? cerrarSubMenu(menu)
                              : abrirSubMenu(menu)
                          : cerrarSubMenu(menu);
                    } else if (menu == 'Servicios') {
                      dispositivo != 'PC'
                          ? mostrarMenuServicio
                              ? cerrarSubMenu(menu)
                              : abrirSubMenu(menu)
                          : cerrarSubMenu(menu);
                    } else if (menu == 'Eventos') {
                      dispositivo != 'PC'
                          ? mostrarMenuEvento
                              ? cerrarSubMenu(menu)
                              : abrirSubMenu(menu)
                          : cerrarSubMenu(menu);
                    } else if (menu == 'Mi cuenta') {
                      dispositivo != 'PC'
                          ? mostrarMenuCuenta
                              ? cerrarSubMenu(menu)
                              : abrirSubMenu(menu)
                          : cerrarSubMenu(menu);
                    } else if (menu == 'Carrito') {
                      dispositivo != 'PC'
                          ? openShoppingCart
                          : abrirCarritoUI(menu);
                    } else if ((menu == 'Cerrar sesion')) {
                      cerrarSesion();
                    } else if (menu == 'Iniciar sesion') {
                      openLogin2 ? cerrarLogin() : abrirLogin();
                    }
                  },
                  child: Icon(icono, color: colorMorado),
                ),
                Text(menu,
                    style: TextStyle(
                        color: colorMorado,
                        fontFamily: 'Impact',
                        fontSize: dispositivo == 'PC' ? 18 : 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )));
  }

  Widget menuSideBar() {
    return Container(
        //color: Colors.white,
        width: 130,
        margin: EdgeInsets.only(top: 60),
        child: Column(
          children: [
            btnSideBar('Cafeterias', Icons.coffee_sharp),
            SizedBox(
              height: 30,
            ),
            btnSideBar('Reseñas', Icons.feedback),
            SizedBox(
              height: 30,
            ),
            btnSideBar('Eventos', Icons.event),
            SizedBox(
              height: 30,
            ),
            btnSideBar('Carrito', Icons.shopping_cart),
            usuarioLogeado
                ? SizedBox(
                    height: 30,
                  )
                : Container(),
            usuarioLogeado
                ? btnSideBar('Servicios', Icons.graphic_eq)
                : Container(),
            SizedBox(
              height: 30,
            ),
            usuarioLogeado
                ? btnSideBar('Mi cuenta', Icons.manage_accounts)
                : btnSideBar('Iniciar sesion', Icons.login),
            SizedBox(
              height: 30,
            ),
            usuarioLogeado
                ? btnSideBar('Cerrar sesion', Icons.logout)
                : btnSideBar('Registrarme', Icons.account_circle),
          ],
        ));
  }

  Widget containerSideBar() {
    return (AnimatedContainer(
      curve: Curves.easeInOutCubic,
      duration: Duration(milliseconds: 500),
      width: (sideBar)
          ? (dispositivo == 'PC')
              ? 120
              : 70
          : (dispositivo == 'PC')
              ? sideBar
                  ? sideBar2
                      ? 120
                      : 0
                  : 50
              : 40,
      height: (dispositivo == 'PC')
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          color: colorNaranja,
          border: Border(
            right: mostrarMenuCafeteria
                ? BorderSide(color: colorMorado, width: 1.0)
                : BorderSide.none,
          )),
      child: Column(
        children: [
          GestureDetector(
            child: logoMenu(),
            onTap: () {
              setState(
                () {
                  if (sideBar2) {
                    cerrarSubMenu('Todos');
                    Future.delayed(Duration(milliseconds: 350), () {
                      /*  cerrarSideBar(); */
                    });
                  } else {
                    abrirSideBar();
                  }
                },
              );
            },
          ),
          sideBar2 ? menuSideBar() : Container()
        ],
      ),
    ));
  }

  void disparadorBtnSubSideBar(String menu, bool tieneSubMenu) {
    if (tieneSubMenu) {
      setState(() {
        activarSubMenuBtnSSB[0] = menu;
        activarSubMenuBtnSSB[1] = true;
        Future.delayed(Duration(milliseconds: 350), () {
          activarSubMenuBtnSSB[2] = true;
        });
      });
    } else {
      if (menu == 'Data Studio') {
        mostrarData();
        cerrarVision();
      } else if (menu == 'Vision AI') {
        print('Vision AI');
        mostrarVision();
        cerrarData();
      } else if (menu == 'Crear cafeteria') {}
    }
  }

  void abrirCoffeeUI(String menu) {
    print(menu);
    if (menu == 'Todas las cafeterias') {
      setState(() {
        openAllCoffees = true;
        openMyCoffees2 = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          openMyCoffees = false;
          openAllCoffees2 = true;
        });
      });
    } else if (menu == 'Mis cafeterias') {
      setState(() {
        openMyCoffees = true;
        openAllCoffees2 = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          openAllCoffees = false;
          openMyCoffees2 = true;
        });
      });
    } else if (menu == 'Cafeterias guardadas') {
      setState(() {
        openSavedCoffees = true;
        openAllCoffees2 = false;
        openMyCoffees2 = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          openAllCoffees = false;
          openMyCoffees = false;
          openSavedCoffees2 = true;
        });
      });
    }
  }

  void abrirEventosUI(String menu) {
    print(menu);
    if (menu == 'Todos los eventos') {
      setState(() {
        openAllEvents = true;
        openMyEvents2 = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          openMyEvents = false;
          openAllEvents2 = true;
        });
      });
    } else if (menu == 'Mis eventos') {
      setState(() {
        openMyEvents = true;
        openAllEvents2 = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          openAllEvents = false;
          openMyEvents2 = true;
        });
      });
    } else if (menu == 'Eventos guardados') {
      setState(() {
        openSavedEvents = true;
        openAllEvents2 = false;
        openMyEvents2 = false;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          openAllEvents = false;
          openMyEvents = false;
          openSavedEvents2 = true;
        });
      });
    }
  }

  void abrirCarritoUI(String menu) {
    print(menu);
    if (menu == 'Carrito') {
      setState(() {
        openShoppingCart = true;
      });
    }
  }

  void cerrarModuloResenas(String menu) {
    if (menu == 'Todas las reseñas') {
      setState(() {
        openMyFeedback = false;
        openMyFeedback2 = false;
        openSavedFeedback = false;
        openSavedFeedback2 = false;
      });
    } else if (menu == 'Mis reseñas') {
      setState(() {
        openAllfeedback = false;
        openAllfeedback2 = false;
        openSavedFeedback = false;
        openSavedFeedback2 = false;
      });
    } else if (menu == 'Reseñas guardadas') {
      setState(() {
        openAllfeedback = false;
        openAllfeedback2 = false;
        openMyFeedback = false;
        openMyFeedback2 = false;
      });
    }
  }

  void abrirFeedbackUI(String menu) {
    if (menu == 'Todas las reseñas') {
      if (openAllfeedback) {
        setState(() {
          openAllfeedback = false;
        });
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            openAllfeedback2 = false;
          });
        });
      }
      cerrarModuloResenas(menu);
      cerrarModuloCafeteria('Cafeterias');
      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          feedbackUI = menu;
          openAllfeedback = true;
        });
      });
      Future.delayed(Duration(milliseconds: 900), () {
        setState(() {
          openAllfeedback2 = true;
        });
      });
    } else if (menu == 'Mis reseñas') {
      if (openMyFeedback) {
        setState(() {
          openMyFeedback = false;
        });
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            openMyFeedback2 = false;
          });
        });
      }
      cerrarModuloResenas(menu);
      cerrarModuloCafeteria('Cafeterias');
      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          feedbackUI = menu;
          openMyFeedback = true;
        });
      });
      Future.delayed(Duration(milliseconds: 900), () {
        setState(() {
          openMyFeedback2 = true;
        });
      });
    } else if (menu == 'Reseñas guardadas') {
      if (openSavedFeedback) {
        setState(() {
          openSavedFeedback = false;
        });
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            openSavedFeedback2 = false;
          });
        });
      }
      cerrarModuloResenas(menu);
      cerrarModuloCafeteria('Cafeterias');
      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          feedbackUI = menu;
          openSavedFeedback = true;
        });
      });
      Future.delayed(Duration(milliseconds: 900), () {
        setState(() {
          openSavedFeedback2 = true;
        });
      });
    }
  }

  void disparadorCerrarSidebar() {
    cerrarData();
    cerrarLogin();
    cerrarVision();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        activarSubMenuBtnSSB[2] = !activarSubMenuBtnSSB[2];
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        activarSubMenuBtnSSB[1] = !activarSubMenuBtnSSB[1];
      });
    });
    Future.delayed(Duration(milliseconds: 900), () {
      setState(() {
        mostrarMenuCafeteria = false;
        mostrarMenuResena = false;
        mostrarMenuEvento = false;
        mostrarMenuServicio = false;
      });
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        mostrarMenuCafeteria2 = false;
        mostrarMenuResena2 = false;
        mostrarMenuEvento2 = false;
        mostrarMenuServicio2 = false;
      });
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        sideBar2 = !sideBar2;
      });
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        sideBar = !sideBar;
      });
    });
  }

  Widget btnSubSubSideBar(String menu) {
    return (Container(
      width: (dispositivo == 'PC') ? 190 : 130,
      height: (dispositivo == 'PC') ? 40 : 30,
      child: ElevatedButton(
        onPressed: () {
          if (menu.contains('cafeterias') || menu.contains('Cafeterias')) {
            disparadorCerrarSidebar();
            abrirCoffeeUI(menu);
          }
          if (menu.contains('reseñas') || menu.contains('Reseñas')) {
            disparadorCerrarSidebar();
            abrirFeedbackUI(menu);
          }
          if (menu.contains('eventos') || menu.contains('Eventos')) {
            disparadorCerrarSidebar();
            abrirEventosUI(menu);
          }
        },
        child: Text(menu,
            style: TextStyle(
                color: colorMorado,
                fontFamily: 'Impact',
                fontSize: dispositivo == 'PC' ? 16 : 10,
                fontWeight: FontWeight.bold)),
        style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(colorNaranja),
            backgroundColor: MaterialStateProperty.all(colorNaranja),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)))),
      ),
    ));
  }

  Widget btnSubSideBar(String btnText, bool tieneSubMenu) {
    String ucFirst(String str) {
      if (str == null || str.isEmpty) {
        return "";
      } else {
        return str.substring(0, 1).toUpperCase() + str.substring(1);
      }
    }

    return AnimatedContainer(
      curve: Curves.easeInOutCubic,
      duration: Duration(milliseconds: 300),
      decoration: activarSubMenuBtnSSB[1] && activarSubMenuBtnSSB[0] == btnText
          ? BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.all(Radius.circular(20)))
          : null,
      width: (dispositivo == 'PC') ? 210 : 140,
      height: activarSubMenuBtnSSB[1] && activarSubMenuBtnSSB[0] == btnText
          ? dispositivo == 'PC'
              ? 200
              : 150
          : dispositivo == 'PC'
              ? 56
              : 36,
      child: (activarSubMenuBtnSSB[2] && activarSubMenuBtnSSB[0] == btnText)
          ? Column(
              children: [
                InkWell(
                  onTap: () {
                    activarSubMenuBtnSSB[2] = false;
                    Future.delayed(Duration(milliseconds: 250), () {
                      activarSubMenuBtnSSB[1] = false;
                    });
                  },
                  child: Container(
                    width: (dispositivo == 'PC') ? 190 : 100,
                    height: (dispositivo == 'PC') ? 56 : 36,
                    decoration: BoxDecoration(
                        color: colorMorado,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(btnText,
                              style: TextStyle(
                                  color: colorNaranja,
                                  fontFamily: 'Impact',
                                  fontSize: dispositivo == 'PC' ? 18 : 10,
                                  fontWeight: FontWeight.bold)),
                          Icon(
                            Icons.arrow_drop_up,
                            color: colorNaranja,
                            size: dispositivo == 'PC' ? 26 : 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      btnSubSubSideBar(
                          'Mis ${btnText.split(' ')[1].toLowerCase()}'),
                      btnSubSubSideBar(
                          '${ucFirst(btnText.split(' ')[1])} ${btnText.split(' ')[1] == 'eventos' ? 'guardados' : 'guardadas'}'),
                      btnSubSubSideBar(
                          '${btnText.split(' ')[1] == 'eventos' ? 'Todos' : 'Todas'} ${btnText.split(' ')[1].toLowerCase() == 'eventos' ? 'los' : 'las'} ${btnText.split(' ')[1].toLowerCase()}'),
                    ],
                  ),
                )
              ],
            )
          : ElevatedButton(
              onPressed: () {
                disparadorBtnSubSideBar(btnText, tieneSubMenu);
              },
              child: tieneSubMenu
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(btnText,
                            style: TextStyle(
                                color: colorNaranja,
                                fontFamily: 'Impact',
                                fontSize: dispositivo == 'PC' ? 18 : 10,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.arrow_drop_down,
                          color: colorNaranja,
                          size: dispositivo == 'PC' ? 26 : 20,
                        )
                      ],
                    )
                  : Text(btnText,
                      style: TextStyle(
                          color: colorNaranja,
                          fontFamily: 'Impact',
                          fontSize: dispositivo == 'PC' ? 18 : 10,
                          fontWeight: FontWeight.bold)),
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(colorMorado),
                  backgroundColor: MaterialStateProperty.all(colorMorado),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
            ),
    );
  }

  Widget menuSubSideBar(String menu) {
    double altoEspaciador = dispositivo == 'PC' ? 30 : 10;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 50),
        child: menu == 'Cafeterias'
            ? Column(
                children: [
                  btnSubSideBar('Ver cafeterias', true),
                  SizedBox(
                    height: altoEspaciador,
                  ),
                  btnSubSideBar('Crear cafeteria', false)
                ],
              )
            : menu == 'Reseñas'
                ? Column(
                    children: [
                      btnSubSideBar('Ver reseñas', true),
                      SizedBox(
                        height: altoEspaciador,
                      ),
                      btnSubSideBar('Crear reseña', false)
                    ],
                  )
                : menu == 'Servicios'
                    ? Column(
                        children: [
                          btnSubSideBar('Vision AI', false),
                          SizedBox(
                            height: altoEspaciador,
                          ),
                          btnSubSideBar('Data Studio', false)
                        ],
                      )
                    : menu == 'Eventos'
                        ? Column(
                            children: [
                              btnSubSideBar('Ver eventos', true),
                              SizedBox(
                                height: altoEspaciador,
                              ),
                              btnSubSideBar('Crear evento', false)
                            ],
                          )
                        : menu == 'Mi cuenta'
                            ? Column(
                                children: [
                                  btnSubSideBar('Mi perfil', true),
                                  SizedBox(
                                    height: altoEspaciador,
                                  ),
                                  btnSubSideBar('Mis entradas', false),
                                  SizedBox(
                                    height: altoEspaciador,
                                  ),
                                  btnSubSideBar('Mis ajustes', false)
                                ],
                              )
                            : Container());
  }

  Widget containerSubSideBar() {
    return (AnimatedContainer(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 300),
      width: (mostrarMenuCafeteria ||
              mostrarMenuResena ||
              mostrarMenuServicio ||
              mostrarMenuEvento ||
              mostrarMenuCuenta)
          ? (dispositivo == 'PC')
              ? 220
              : 150
          : 0,
      height: (dispositivo == 'PC')
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(3, 3), // changes position of shadow
          ),
        ],
        color: colorNaranja,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: mostrarMenuCafeteria2
          ? menuSubSideBar('Cafeterias')
          : mostrarMenuResena2
              ? menuSubSideBar('Reseñas')
              : mostrarMenuServicio2
                  ? menuSubSideBar('Servicios')
                  : mostrarMenuEvento2
                      ? menuSubSideBar('Eventos')
                      : mostrarMenuCuenta2
                          ? menuSubSideBar('Mi cuenta')
                          : Container(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (widget.ancho_pantalla > 1315) {
        dispositivo = 'PC';
      } else {
        dispositivo = 'MOVIL';
      }
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          usuarioLogeado = true;
        });
      } else {
        setState(() {
          usuarioLogeado = false;
        });
      }
    });

    return (Stack(
      children: [
        openMyCoffees
            ? AnimatedOpacity(
                opacity: openMyCoffees2 ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: myCoffeesUI(
                  tipoUI: coffeeUI,
                ),
              )
            : openAllCoffees
                ? AnimatedOpacity(
                    opacity: openAllCoffees2 ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: allCoffeesUI(
                      tipoUI: coffeeUI,
                    ),
                  )
                : openSavedCoffees
                    ? AnimatedOpacity(
                        opacity: openSavedCoffees2 ? 1 : 0,
                        duration: Duration(milliseconds: 500),
                        child: coffeeSavedUI(
                          tipoUI: coffeeUI,
                        ),
                      )
                    : openMyFeedback
                        ? AnimatedOpacity(
                            opacity: openMyFeedback2 ? 1 : 0,
                            duration: Duration(milliseconds: 500),
                            child: myResenasUI(
                              tipoUI: feedbackUI,
                            ),
                          )
                        : openSavedFeedback
                            ? AnimatedOpacity(
                                opacity: openSavedFeedback2 ? 1 : 0,
                                duration: Duration(milliseconds: 500),
                                child: savedResenasUI(
                                  tipoUI: feedbackUI,
                                ),
                              )
                            : openAllfeedback
                                ? AnimatedOpacity(
                                    opacity: openAllfeedback2 ? 1 : 0,
                                    duration: Duration(milliseconds: 500),
                                    child: AllResenasUI(
                                      tipoUI: feedbackUI,
                                    ),
                                  )
                                : openLogin
                                    ? AnimatedOpacity(
                                        opacity: openLogin2 ? 1 : 0,
                                        duration: Duration(milliseconds: 500),
                                        child: Login(),
                                      )
                                    : openVision
                                        ? AnimatedOpacity(
                                            opacity: openVision2 ? 1 : 0,
                                            duration:
                                                Duration(milliseconds: 500),
                                            child: VisionUI(),
                                          )
                                        : openData
                                            ? AnimatedOpacity(
                                                opacity: openData2 ? 1 : 0,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                child: DataUI(),
                                              )
                                            : openMyEvents
                                                ? AnimatedOpacity(
                                                    opacity:
                                                        openMyEvents2 ? 1 : 0,
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    child: myEventsUI(
                                                      tipoUI: eventsUI,
                                                    ),
                                                  )
                                                : openAllEvents
                                                    ? AnimatedOpacity(
                                                        opacity: openAllEvents2
                                                            ? 1
                                                            : 0,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        child: EventosUI(
                                                          tipoUI: eventsUI,
                                                        ),
                                                      )
                                                    : openSavedEvents
                                                        ? AnimatedOpacity(
                                                            opacity:
                                                                openSavedEvents2
                                                                    ? 1
                                                                    : 0,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            child:
                                                                eventsSavedUI(
                                                              tipoUI: eventsUI,
                                                            ),
                                                          )
                                                        : openShoppingCart
                                                            ? AnimatedOpacity(
                                                                opacity:
                                                                    openShoppingCart2
                                                                        ? 1
                                                                        : 0,
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        500),
                                                                child:
                                                                    ShoppingUI(
                                                                  tipoUI:
                                                                      shoppingUI,
                                                                ),
                                                              )
                                                            : Row(
                                                                children: [
                                                                  containerSideBar(),
                                                                  InkWell(
                                                                    mouseCursor:
                                                                        MouseCursor
                                                                            .defer,
                                                                    onTap:
                                                                        () {},
                                                                    child:
                                                                        containerSubSideBar(),
                                                                    onHover:
                                                                        (value) {
                                                                      print(
                                                                          value);
                                                                      setState(
                                                                          () {
                                                                        hoverSubSideBar =
                                                                            value;
                                                                      });
                                                                      if (!hoverSubSideBar &&
                                                                          dispositivo ==
                                                                              'PC') {
                                                                        setState(
                                                                            () {
                                                                          mostrarMenuCafeteria2 =
                                                                              false;
                                                                          mostrarMenuResena2 =
                                                                              false;
                                                                          mostrarMenuServicio2 =
                                                                              false;
                                                                          mostrarMenuEvento2 =
                                                                              false;
                                                                          mostrarMenuCuenta2 =
                                                                              false;
                                                                        });
                                                                        Future.delayed(
                                                                            Duration(milliseconds: 300),
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            mostrarMenuCafeteria =
                                                                                false;
                                                                            mostrarMenuResena =
                                                                                false;
                                                                            mostrarMenuServicio =
                                                                                false;
                                                                            mostrarMenuEvento =
                                                                                false;
                                                                            mostrarMenuCuenta =
                                                                                false;
                                                                          });
                                                                        });
                                                                      }
                                                                    },
                                                                  )
                                                                ],
                                                              ),
      ],
    ));
  }
}
