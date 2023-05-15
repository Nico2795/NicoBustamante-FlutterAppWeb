import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_network/image_network.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';

class eventsSavedUI extends StatefulWidget {
  final tipoUI;
  const eventsSavedUI({required this.tipoUI});

  @override
  _eventsSavedUIState createState() => _eventsSavedUIState();
}

class _eventsSavedUIState extends State<eventsSavedUI> {
  var colorScaffold = Color(0xffffebdcac);
  var colorNaranja = Color.fromARGB(255, 255, 79, 52);
  var colorMorado = Color.fromARGB(0xff, 0x52, 0x01, 0x9b);
  //Modulo VisionAI
  var mostrarControl = false;
  var mostrarControl2 = false;
  var mostrarData = false;
  var mostrarData2 = false;
  var mostrarDataStudio = false;
  var mostrarNombre = false;
  var mostrarNombre2 = false;
  var uidCamara = "";
  var pantalla = 0.0;
  var eventosGuardados = [];
  var eventosKeys = [];
  var listaEventos = [];

  var dispositivo = '';

  var btnEventoHovered = ['', false];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<dynamic>?> obtenerEventosGuardados() async {
    User? user = FirebaseAuth.instance.currentUser;
    firestore.collection('users').doc(user?.uid).get().then((value) {
      print(value.data()!['eventosGuardados']);
      setState(() {
        eventosGuardados = value.data()!['eventosGuardados'];
      });
    });
  }

  List<dynamic> listaEventosGuardados(String accion, String uidEvento) {
    var lista = eventosGuardados;
    print('UID Evento: ' + uidEvento);
    if (accion == 'agregar') {
      lista.add(uidEvento);
    } else {
      lista.remove(uidEvento);
    }
    print(lista);
    return lista;
  }

  Future<void> subirFavoritos(String uidEvento) async {
    try {
      // Importante: Este tipo de declaracion se utiliza para solamente actualizar la informacion solicitada y no manipular informacion adicional, como lo es la imagen y esto permite no borrar otros datos importantes
      User? user = FirebaseAuth.instance.currentUser;
      print(uidEvento);
      print(eventosGuardados);
      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(user?.uid);
      // Se actualiza la informacion del usuario actual mediante los controladores, que son los campos de informacion que el usuario debe rellenar

      docRef.update({
        'eventosGuardados': FieldValue.arrayUnion([uidEvento])
      });
      print('Ingreso de informacion exitoso.');
      obtenerEventosGuardados();
      // Una vez actualizada la informacion, se devuelve a InfoUser para mostrar su nueva informacion
    } catch (e) {
      print("Error al intentar ingresar informacion");
    }
  }

  Future<void> borrarFavoritos(String UidEvento) async {
    try {
      // Importante: Este tipo de declaracion se utiliza para solamente actualizar la informacion solicitada y no manipular informacion adicional, como lo es la imagen y esto permite no borrar otros datos importantes
      User? user = FirebaseAuth.instance.currentUser;
      print(UidEvento);
      print(eventosGuardados);
      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(user?.uid);
      // Se actualiza la informacion del usuario actual mediante los controladores, que son los campos de informacion que el usuario debe rellenar

      docRef.update({
        'eventosGuardados': FieldValue.arrayRemove([UidEvento])
      });
      print('Ingreso de informacion exitoso.');
      obtenerEventosGuardados();
      // Una vez actualizada la informacion, se devuelve a InfoUser para mostrar su nueva informacion
    } catch (e) {
      print("Error al intentar ingresar informacion");
    }
  }

  //Obtengo toda la informacion de la coleccion eventos
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('eventos');

  Future<List<Map<String, dynamic>>> getEventosData() async {
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot eventosQuerySnapshot = await _collectionRef.get();
    List<Map<String, dynamic>> eventosDataList = [];
    for (var doc in eventosQuerySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      eventosGuardados.contains(doc.id)
          ? eventosDataList.add({'data': data, 'uid': doc.id})
          : null;
    }
    setState(() {
      listaEventos = eventosDataList;
    });
    return eventosDataList;
  }

  Future<List<dynamic>> getEventosKeys() async {
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot eventosQuerySnapshot = await _collectionRef.get();
    var eventosKeyList = [];
    for (var doc in eventosQuerySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      widget.tipoUI == 'Mis eventos'
          ? (data['creador'] == user?.uid)
              ? {
                  eventosKeyList.add([data, doc.id])
                }
              : null
          : eventosKeyList.add([data, doc.id]);
    }
    setState(() {
      eventosKeys = eventosKeyList;
    });
    return eventosKeyList;
  }

  final CarouselController _controller = CarouselController();

  String nombreEventoActual = "";

  Future<void> _openMapsModal(String ubicacion) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$ubicacion";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw "Could not launch $googleMapsUrl";
    }
  }

  String generarTextoUbicacion(String texto) {
    if (texto.split(', ')[0].length > 20) {
      return texto.split(', ')[0];
    } else {
      return texto;
    }
  }

  Widget btnEvento(
      IconData icono, String tipo, String nombreEvento, String UidEvento) {
    return (InkWell(
      onHover: (value) {
        if (value) {
          setState(() {
            btnEventoHovered = [tipo, true];
          });
        } else {
          setState(() {
            btnEventoHovered = [tipo, false];
          });
        }
      },
      onTap: () {
        if (tipo == 'Guardar evento') {
          eventosGuardados.contains(UidEvento)
              ? borrarFavoritos(UidEvento)
              : subirFavoritos(UidEvento);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: (btnEventoHovered[0] == tipo &&
                  btnEventoHovered[1] == true &&
                  nombreEventoActual == nombreEvento)
              ? Color.fromARGB(255, 107, 0, 200)
              : colorMorado,
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(10),
          child: Icon(icono, color: colorNaranja, size: 26),
        ),
      ),
    ));
  }

  String obtenerKeyEvento(String nombreEvento) {
    String keyEvento = '';
    for (var evento in eventosKeys) {
      if (evento[0]['nombre'] == nombreEvento) {
        keyEvento = evento[1];
      }
    }
    return keyEvento;
  }

  Widget sliderImagenes() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (listaEventos.isNotEmpty && nombreEventoActual == "") {
        nombreEventoActual = listaEventos[0]["data"]["nombre"];
      }
    });
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getEventosData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        List<Map<String, dynamic>> eventosDataList = snapshot.data!;

        return Align(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: dispositivo == 'PC' ? 0.4 : 0.9,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    height: dispositivo == 'PC'
                        ? MediaQuery.of(context).size.height * 0.72
                        : MediaQuery.of(context).size.height * 0.85,
                    onPageChanged: (index, reason) => {
                      setState(() {
                        nombreEventoActual =
                            eventosDataList[index]["data"]["nombre"];
                      })
                    },
                  ),
                  carouselController: _controller,
                  items: eventosDataList.asMap().entries.map((entry) {
                    int index = entry.key;
                    String nombre = entry.value["data"]["nombre"];
                    String urlImagen = entry.value["data"]["imagen"];
                    String ubicacion = entry.value["data"]["ubicacion"];
                    String correo = entry.value["data"]["correo"];
                    String calificacion =
                        entry.value["data"]["calificacion"].toString();
                    String web = entry.value["data"]["web"];
                    String creador = entry.value["data"]["creador"];

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Card(
                        color: colorNaranja,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                            width: 500,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    ClipPath(
                                      clipper: ShapeBorderClipper(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                      child: ImageNetwork(
                                        image: urlImagen,
                                        height: 250,
                                        width: 500,
                                        fitWeb: BoxFitWeb.fill,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () {},
                                                label: Container(
                                                  margin: EdgeInsets.only(
                                                      right:
                                                          nombreEventoActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5,
                                                      top: nombreEventoActual ==
                                                              nombre
                                                          ? 10
                                                          : 5,
                                                      bottom:
                                                          nombreEventoActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5),
                                                  child: Text(
                                                    generarTextoUbicacion(
                                                        ubicacion),
                                                    style: TextStyle(
                                                        color: colorNaranja,
                                                        fontSize:
                                                            dispositivo == 'PC'
                                                                ? 18
                                                                : 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                icon: Container(
                                                  margin: EdgeInsets.only(
                                                      left:
                                                          nombreEventoActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5,
                                                      top: nombreEventoActual ==
                                                              nombre
                                                          ? 10
                                                          : 5,
                                                      bottom:
                                                          nombreEventoActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: colorNaranja,
                                                    size: dispositivo == 'PC'
                                                        ? 24
                                                        : 20,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(colorMorado),
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  )),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    RatingBar.builder(
                                      initialRating: double.parse(calificacion),
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemSize: dispositivo == 'PC' ? 40 : 30,
                                      itemCount: 5,
                                      ignoreGestures: true,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.coffee,
                                        color: colorMorado,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    ),
                                    nombreEventoActual == nombre
                                        ? Container(
                                            child: Text(
                                              '$calificacion/5',
                                              style: TextStyle(
                                                  color: colorMorado,
                                                  fontSize: dispositivo == 'PC'
                                                      ? 26
                                                      : 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.1,
                                          bottom: 10,
                                          right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          btnEvento(Icons.web, 'Web', nombre,
                                              entry.value["uid"]),
                                          btnEvento(Icons.map, 'Mapa', nombre,
                                              entry.value["uid"]),
                                          btnEvento(Icons.feedback, 'Reseñas',
                                              nombre, entry.value["uid"]),
                                          creador == user?.uid
                                              ? btnEvento(
                                                  Icons.settings,
                                                  'Configuracion',
                                                  nombre,
                                                  entry.value["uid"])
                                              : btnEvento(
                                                  eventosGuardados.contains(
                                                          entry.value["uid"])
                                                      ? Icons.favorite
                                                      : Icons.favorite_outline,
                                                  'Guardar evento',
                                                  nombre,
                                                  entry.value["uid"])
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget vistaEventData() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        mostrarDataStudio = true;
      });
    });
    return Container(
        width: MediaQuery.of(context).size.width,
        child: (eventosGuardados.isEmpty)
            ? Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 300),
                child: Text(
                  'Sin eventos guardados',
                  style: TextStyle(
                      color: colorMorado,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              )
            : sliderImagenes());
  }

  Widget vistaCoffeeMaker() {
    return (Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              'Cafeteras',
              style: TextStyle(
                  color: colorMorado,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ));
  }

  Widget vistaWeb() {
    return (Dialog(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutBack,
        height: MediaQuery.of(context).size.height - 120,
        width: 1280,
        decoration: BoxDecoration(
            color: colorScaffold,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Container(
            margin: EdgeInsets.only(
                top: 50,
                left: dispositivo == 'PC' ? 0 : 0,
                right: dispositivo == 'PC' ? 0 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: colorNaranja,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ]),
                    child: Stack(
                      children: [
                        Center(
                            child: Text(
                          'Eventos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOutBack,
                            width: mostrarData ? 250 : 80,
                            height: 70,
                            decoration: BoxDecoration(
                                color: colorMorado,
                                borderRadius: BorderRadius.circular(40)),
                            child: GestureDetector(
                              onTap: (() {
                                setState(() {
                                  mostrarData = !mostrarData;
                                  mostrarControl2 = false;
                                });
                                Future.delayed(
                                    Duration(
                                        milliseconds: mostrarData2 ? 50 : 550),
                                    () {
                                  setState(() {
                                    mostrarData2 = !mostrarData2;
                                    mostrarControl = false;
                                  });
                                });
                              }),
                              child: mostrarData2
                                  ? Center(
                                      child: Text(
                                        'Eventos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.confirmation_num_rounded,
                                      color: colorNaranja,
                                      size: 60,
                                    ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOutBack,
                            width: 250,
                            height: 70,
                            decoration: BoxDecoration(
                                color: colorMorado,
                                borderRadius: BorderRadius.circular(40)),
                            child: GestureDetector(
                                child: Center(
                              child: Text(
                                widget.tipoUI == 'Eventos guardados' &&
                                        eventosGuardados.isEmpty
                                    ? ''
                                    : nombreEventoActual,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                          ),
                        ),
                      ],
                    )),
                Container(
                    child: widget.tipoUI == 'Crear evento'
                        ? vistaCoffeeMaker()
                        : vistaEventData()),
              ],
            )),
      ),
    ));
  }

  Widget vistaMobile() {
    return (AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: colorScaffold),
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: colorMorado,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text(
                    'Eventos guardados',
                    style: TextStyle(
                        color: colorNaranja,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                ),
              ),
            ),
            eventosGuardados.isNotEmpty
                ? Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: sliderImagenes(),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(
                      child: Text(
                        'Sin eventos guardados',
                        style: TextStyle(
                            color: colorMorado,
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ancho_pantalla = MediaQuery.of(context).size.width;
    setState(() {
      pantalla = ancho_pantalla;
    });
    print(pantalla);
    setState(() {
      if (ancho_pantalla > 1130) {
        dispositivo = 'PC';
      } else {
        dispositivo = 'MOVIL';
      }
    });
    return (dispositivo == 'PC') ? vistaWeb() : vistaMobile();
  }

  @override
  void initState() {
    super.initState();

    obtenerEventosGuardados();
    getEventosKeys();
    getEventosData();
  }
}
