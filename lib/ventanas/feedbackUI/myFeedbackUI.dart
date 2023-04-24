import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:webviewx/webviewx.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_network/image_network.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';

class myResenasUI extends StatefulWidget {
  final tipoUI;
  const myResenasUI({required this.tipoUI});

  @override
  _myResenasUIState createState() => _myResenasUIState();
}

class _myResenasUIState extends State<myResenasUI> {
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
  var resenasGuardadas = [];
  var resenasKeys = [];
  var listaResenas = [];

  var dispositivo = '';

  var btnResenaHovered = ['', false];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<dynamic>?> obtenerResenasGuardadas() async {
    User? user = FirebaseAuth.instance.currentUser;
    firestore.collection('users').doc(user?.uid).get().then((value) {
      setState(() {
        resenasGuardadas = value.data()!['reseñasGuardadas'];
      });
    });
  }

  List<dynamic> listaResenasGuardadas(String accion, String uidResena) {
    var lista = resenasGuardadas;
    print('UID Reseña: ' + uidResena);
    if (accion == 'agregar') {
      lista.add(uidResena);
    } else {
      lista.remove(uidResena);
    }

    return lista;
  }

  Future<void> subirFavoritos(String uidResena) async {
    try {
      // Importante: Este tipo de declaracion se utiliza para solamente actualizar la informacion solicitada y no manipular informacion adicional, como lo es la imagen y esto permite no borrar otros datos importantes
      User? user = FirebaseAuth.instance.currentUser;
      print(uidResena);
      print(resenasGuardadas);
      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(user?.uid);

      docRef.update({
        'reseñasGuardadas': FieldValue.arrayUnion([uidResena])
      });
      print('Ingreso de informacion exitoso.');
      obtenerResenasGuardadas();
      // Una vez actualizada la informacion, se devuelve a InfoUser para mostrar su nueva informacion
    } catch (e) {
      print("Error al intentar ingresar informacion");
    }
  }

  Future<void> borrarFavoritos(String uidResena) async {
    try {
      // Importante: Este tipo de declaracion se utiliza para solamente actualizar la informacion solicitada y no manipular informacion adicional, como lo es la imagen y esto permite no borrar otros datos importantes
      User? user = FirebaseAuth.instance.currentUser;
      print(uidResena);
      print(resenasGuardadas);
      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(user?.uid);
      // Se actualiza la informacion del usuario actual mediante los controladores, que son los campos de informacion que el usuario debe rellenar

      docRef.update({
        'resenasGuardadas': FieldValue.arrayRemove([uidResena])
      });
      print('Ingreso de informacion exitoso.');
      obtenerResenasGuardadas();
      // Una vez actualizada la informacion, se devuelve a InfoUser para mostrar su nueva informacion
    } catch (e) {
      print("Error al intentar ingresar informacion");
    }
  }

  //Obtengo toda la informacion de la coleccion reseñas
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('resenas');

  Future<List<Map<String, dynamic>>> getResenasData() async {
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot resenasQuerySnapshot = await _collectionRef.get();
    List<Map<String, dynamic>> resenasDataList = [];
    for (var doc in resenasQuerySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      (data['uid_usuario'] == user!.uid)
          ? resenasDataList.add({'data': data, 'uid': doc.id})
          : null;
    }

    setState(() {
      listaResenas = resenasDataList;
    });
    return resenasDataList;
  }

  Future<List<dynamic>> getResenasKeys() async {
    User? user = FirebaseAuth.instance.currentUser;

    QuerySnapshot resenasQuerySnapshot = await _collectionRef.get();
    var resenasKeysList = [];
    for (var doc in resenasQuerySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      widget.tipoUI == 'Mis reseñas'
          ? (data['uid_usuario'] == user?.uid)
              ? {
                  resenasKeysList.add([data, doc.id])
                }
              : null
          : resenasKeysList.add([data, doc.id]);
    }
    setState(() {
      resenasKeys = resenasKeysList;
    });
    return resenasKeysList;
  }

  final CarouselController _controller = CarouselController();

  String nombreResenaActual = "";

  Future<void> _openMapsModal(String ubicacion) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$ubicacion";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw "Could not launch $googleMapsUrl";
    }
  }

  Widget btnResena(
      IconData icono, String tipo, String nombre, String UidResena) {
    return (InkWell(
      onHover: (value) {
        if (value) {
          setState(() {
            btnResenaHovered = [tipo, true];
          });
        } else {
          setState(() {
            btnResenaHovered = [tipo, false];
          });
        }
      },
      onTap: () {
        if (tipo == 'Guardar reseña') {
          resenasGuardadas.contains(UidResena)
              ? borrarFavoritos(UidResena)
              : subirFavoritos(UidResena);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: (btnResenaHovered[0] == tipo &&
                  btnResenaHovered[1] == true &&
                  nombreResenaActual == nombre)
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

  String obtenerKeyResena(String nombre) {
    String keyResena = '';
    for (var resena in resenasKeys) {
      if (resena[0]['nickname_usuario'] == nombre) {
        keyResena = resena[1];
      }
    }
    return keyResena;
  }

  double promedio(Map<String, dynamic> listaCalificaciones) {
    double promedio = 0;
    double suma = 0;
    int cantidad = 0;
    listaCalificaciones.forEach((key, value) {
      suma += value;
      cantidad++;
    });
    promedio = suma / cantidad;
    return promedio;
  }

  Widget sliderImagenes() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (listaResenas.length > 0 && nombreResenaActual == "") {
        nombreResenaActual = listaResenas[0]["data"]["nickname_usuario"];
      }
    });
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getResenasData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        List<Map<String, dynamic>> resenasDataList = snapshot.data!;

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
                        nombreResenaActual =
                            resenasDataList[index]["data"]["nickname_usuario"];
                      })
                    },
                  ),
                  carouselController: _controller,
                  items: resenasDataList.asMap().entries.map((entry) {
                    int index = entry.key;
                    String nombre = entry.value["data"]["nickname_usuario"];
                    String urlImagen = entry.value["data"]["urlFotografia"];
                    String ubicacion = entry.value["data"]["direccion"];
                    String fecha = entry.value["data"]["fechaCreacion"];
                    String calificacion = entry.value["data"]["comentario"];
                    String cafeteria = entry.value["data"]["cafeteria"];
                    String creador = entry.value["data"]["uid_usuario"];
                    Map<String, dynamic> listaCalificaciones =
                        entry.value["data"]["reseña"];

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
                                                          nombreResenaActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5,
                                                      top: nombreResenaActual ==
                                                              nombre
                                                          ? 10
                                                          : 5,
                                                      bottom:
                                                          nombreResenaActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5),
                                                  child: Text(
                                                    ubicacion,
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
                                                          nombreResenaActual ==
                                                                  nombre
                                                              ? 10
                                                              : 5,
                                                      top: nombreResenaActual ==
                                                              nombre
                                                          ? 10
                                                          : 5,
                                                      bottom:
                                                          nombreResenaActual ==
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
                                      initialRating:
                                          promedio(listaCalificaciones),
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
                                    nombreResenaActual == nombre
                                        ? Container(
                                            child: Text(
                                              '${promedio(listaCalificaciones).toString()}/5',
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
                                          btnResena(Icons.web, 'Web', nombre,
                                              entry.value["uid"]),
                                          btnResena(Icons.map, 'Mapa', nombre,
                                              entry.value["uid"]),
                                          btnResena(Icons.feedback, 'Reseñas',
                                              nombre, entry.value["uid"]),
                                          creador == user?.uid
                                              ? btnResena(
                                                  Icons.settings,
                                                  'Configuracion',
                                                  nombre,
                                                  entry.value["uid"])
                                              : btnResena(
                                                  resenasGuardadas.contains(
                                                          entry.value["uid"])
                                                      ? Icons.favorite
                                                      : Icons.favorite_outline,
                                                  'Guardar reseña',
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

  Widget vistaResenas() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        mostrarDataStudio = true;
      });
    });

    return Container(
        width: MediaQuery.of(context).size.width,
        child: (listaResenas.isEmpty && widget.tipoUI == 'Reseñas guardadas')
            ? Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 300),
                child: Text(
                  'Sin reseñas guardadas',
                  style: TextStyle(
                      color: colorMorado,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              )
            : sliderImagenes());
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
                          'Reseñas',
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
                                        'Reseñas',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.feedback,
                                      color: colorNaranja,
                                      size: 50,
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
                                widget.tipoUI == 'Reseñas guardadas' &&
                                        resenasGuardadas.isEmpty
                                    ? ''
                                    : nombreResenaActual,
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
                Container(child: vistaResenas()),
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
                    'Mis reseñas',
                    style: TextStyle(
                        color: colorNaranja,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(20),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: sliderImagenes(),
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

    obtenerResenasGuardadas();
    getResenasKeys();
    getResenasData();
  }
}
