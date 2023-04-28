import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_network/image_network.dart';
import 'package:prueba/sliderImagenesHeader/index.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:webviewx/webviewx.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import '../templatesCards/cardTemplate.dart';
import "../eventosUI/allEvents.dart";

void main() {
  runApp(GetMaterialApp(
    home: ShoppingUI(
      tipoUI: "",
    ),
  ));
}

class ShoppingUI extends StatefulWidget {
  final tipoUI;
  const ShoppingUI({required this.tipoUI});

  @override
  _ShoppingUIState createState() => _ShoppingUIState();
}

const String access_token =
    "APP_USR-519707263701019-042611-ddcb72600592e72088947c072e6b3de1-340468762";

class MercadoPagoService {
  static Future<String> createPreference(
      String description, double price, int quantity) async {
    String url = "https://api.mercadopago.com/checkout/preferences";
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token'
    };
    var body = {
      "items": [
        {
          "title": description,
          "unit_price": price,
          "quantity": quantity,
        }
      ],
      "back_urls": {
        "success": "http://localhost:8080/feedback",
        "failure": "http://localhost:8080/feedback",
        "pending": "http://localhost:8080/feedback"
      },
      "auto_return": "approved"
    };
    final response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(body));
    if (response.statusCode == 201) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['id'];
    } else {
      throw Exception('Failed to create preference');
    }
  }
}

class _ShoppingUIState extends State<ShoppingUI> {
  late EventosUI eventosUI;
  //Colores
  var colorScaffold = Color(0xffffebdcac);
  var colorNaranja = Color.fromARGB(255, 255, 79, 52);
  var colorMorado = Color.fromARGB(0xff, 0x52, 0x01, 0x9b);

  //Modulo VisionAI
  var activeCamera = false;
  var mostrarControl = false;
  var mostrarControl2 = false;
  var mostrarData = false;
  var mostrarData2 = false;
  var mostrarDataStudio = false;
  var mostrarGridImagenes = true;
  var mostrarGridImagenes2 = false;
  var mostrarFormulario = false;
  var mostrarFormulario2 = false;
  var mostrarDatosUsuario = false;
  var mostrarDatosUsuario2 = false;
  var uidCamara = "";
  var pantalla = 0.0;
  var eventosGuardados = [];
  late VideoPlayerController _controller;
  final videoUrl = 'https://www.visionsinc.xyz/hls/test.m3u8';
  final cartItems = [].obs;
  int cantidadCompras = 0;
  int contadorCompras = 1;

  List<Map<String, dynamic>> listaCompras = obtenerListaCompras().listaCompras;

  // Hacer algo con la lista de compras

  void initState() {
    super.initState();
    eventosUI = EventosUI(tipoUI: "carrito");

    try {
      _controller = VideoPlayerController.network(
        videoUrl,
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
      _controller.setVolume(0.0);
    } catch (e) {
      print(e);
    }
  }

  var dispositivo = '';

  var btnEventoHovered = ['', false];

  //------FIREBASE----------//

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Obtengo toda la informacion de la coleccion eventos
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('eventos');

  Future<List<Map<String, dynamic>>> geteventosData() async {
    QuerySnapshot eventosQuerySnapshot = await _collectionRef.get();
    List<Map<String, dynamic>> eventosDataList = [];
    for (var doc in eventosQuerySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Agrega el ID del documento al mapa de datos
      eventosDataList.add(data);
    }
    return eventosDataList;
  }

  late InAppWebViewController webView;

  var nombreEvento = "";

  //-----------FORMULARIO------//

  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _ageHasError = false;
  bool _genderHasError = false;

  var genderOptions = ['Male', 'Female', 'Other'];

  void _onChanged(dynamic val) => debugPrint(val.toString());

//Almacenamos las cantidades seleccionadas

  /* List<int> cantidadesSeleccionadas = []; */
  List<int> cantidadesSeleccionadas = [];

  //Lista donde se almacenarán las fechas seleccionadas
  List<DateTime> fechasSeleccionadas =
      []; // Agrega esta variable para almacenar las fechas seleccionadas

  /* Almacenamos la información del evento seleccionado para utilizarlo en el formualario */
  Map<String, dynamic>? _eventoSeleccionado;

  Map<DateTime, int> cantidadesPorFecha = {};

  Widget entradaFormulario() {
    //Dividimos la cadena de fechas en dos fechas separadas
    String fechasDisponibles = _eventoSeleccionado!["fecha"];
    List<String> fechas = fechasDisponibles.split(" - ");
    String fechaInicio = fechas[0];
    String fechaFin = fechas[1];

    //Creamos una lista de todas las fechas en el rango con for y add
    List<DateTime> todasLasFechas = [];

    //Convertimos a DateTime para poder iterar sobre estas
    DateTime fechaInicioDateTime = DateFormat("dd/MM/yy").parse(fechaInicio);

    DateTime fechaFinDateTime = DateFormat("dd/MM/yy").parse(fechaFin);

    for (var i = fechaInicioDateTime;
        i.isBefore(fechaFinDateTime.add(Duration(days: 1)));
        i = i.add(Duration(days: 1))) {
      todasLasFechas.add(i);
    }
    List<int> cantidadPorFecha = List.filled(todasLasFechas.length, 0);
    List<FilterChip> opciones = todasLasFechas.map((fecha) {
      String fechaString = DateFormat('dd/MMM/yyyy').format(fecha);
      return FilterChip(
        label: Text(fechaString),
        selected: fechasSeleccionadas.contains(fecha),
        backgroundColor: Colors
            .green, // Agrega el color de fondo de las fechas seleccionadas
        avatar: fechasSeleccionadas.contains(
                fecha) // Agrega el icono líder a las fechas seleccionadas
            ? Icon(Icons.check, color: Colors.white)
            : null,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              fechasSeleccionadas.add(fecha);
              print("se ha agregado una fecha");
              print(fechasSeleccionadas);
            } else {
              final index = fechasSeleccionadas.indexOf(fecha);
              fechasSeleccionadas.remove(fecha);
              print("Se ha eliminado una fecha");
            }
          });
        },
      );
    }).toList();

    return Scaffold(
      backgroundColor: colorScaffold,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Container(
                  width: dispositivo == "PC"
                      ? 600
                      : MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: colorMorado,
                            size: 35,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Fechas Disponibles",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorMorado,
                                fontSize: 25),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                          flex: 100,
                          child: Wrap(
                            children: todasLasFechas.map((fecha) {
                              String fechaString =
                                  DateFormat('dd/MMM/yyyy').format(fecha);
                              return Container(
                                margin: EdgeInsets.all(5),
                                child: FilterChip(
                                  label: Text(fechaString),
                                  labelStyle: TextStyle(color: Colors.white),
                                  backgroundColor: colorNaranja,
                                  checkmarkColor: colorNaranja,
                                  selectedColor: colorMorado,
                                  selected: fechasSeleccionadas.contains(fecha),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        fechasSeleccionadas.add(fecha);
                                        print("se ha agregado una fecha");
                                      } else {
                                        fechasSeleccionadas.remove(fecha);
                                        print("Se ha eliminado una fecha");
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          )),
                      Divider(
                        color: colorNaranja,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_num_rounded,
                            color: colorMorado,
                            size: 35,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Seleccione la cantidad de entradas",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorMorado,
                              fontSize: 25,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                        ],
                      ),
                      Expanded(
                          flex: 150,
                          child: Column(
                            children: fechasSeleccionadas.map((fecha) {
                              final index = todasLasFechas.indexOf(fecha);
                              final cantidad = cantidadesPorFecha[fecha] ?? 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Fecha: ${DateFormat('dd/MMM/yyyy').format(fecha)}",
                                    style: TextStyle(color: colorMorado),
                                  ),
                                  FormBuilderDropdown(
                                    dropdownColor: colorNaranja,
                                    focusColor: Colors.transparent,
                                    name: 'cantidad${index + 1}',
                                    decoration: InputDecoration(),
                                    items: [
                                      DropdownMenuItem(
                                        value: 0,
                                        child: Text(
                                          '0',
                                          style: TextStyle(color: colorMorado),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text(
                                          '1',
                                          style: TextStyle(color: colorMorado),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 2,
                                        child: Text(
                                          '2',
                                          style: TextStyle(color: colorMorado),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 3,
                                        child: Text(
                                          '3',
                                          style: TextStyle(color: colorMorado),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        final index =
                                            todasLasFechas.indexOf(fecha);
                                        cantidadesPorFecha[fecha] =
                                            int.parse(value.toString());
                                        print(cantidadesPorFecha);
                                      });
                                    },
                                    initialValue: cantidad,
                                  ),
                                ],
                              );
                            }).toList(),
                          ))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
            ),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorMorado,
                    foregroundColor: colorNaranja,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      var formData = _formKey.currentState!.value;

                      // Aquí puedes hacer lo que quieras con los valores de fecha y cantidad

                      //Snack si es que corresponde
/*                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Tu entrada ha sido agregada al carrito'),
                        ),
                      ); */

                      setState(() {
                        mostrarDatosUsuario = true;
                        mostrarFormulario = false;
                      });
                    } else {
                      setState(() {
                        autoValidate = true;
                      });
                    }
                  },
                  child: Text(
                    'Continuar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorMorado,
                    foregroundColor: colorNaranja,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarGridImagenes = true;
                    });
                  },
                  child: Text(
                    'Volver',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget datosUsuario() {
    return Scaffold(
      backgroundColor: colorScaffold,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Container(
                  width: dispositivo == "PC"
                      ? 600
                      : MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FormBuilderTextField(
                        name: 'nombre',
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              errorText: "Este campo es obligatorio",
                            ),
                          ],
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'apellido',
                        decoration: InputDecoration(
                          labelText: 'Apellido',
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              errorText: "Este campo es obligatorio",
                            ),
                          ],
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'rut',
                        decoration: InputDecoration(
                          labelText: 'RUT',
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              errorText: "Este campo es obligatorio",
                            ),
                          ],
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'direccion',
                        decoration: InputDecoration(
                            focusColor: colorMorado,
                            labelText: 'Dirección',
                            labelStyle: TextStyle(
                              color: colorMorado,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: colorMorado),
                            )),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              errorText: "Este campo es obligatorio",
                            ),
                          ],
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'telefono',
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(
                              errorText: "Este campo es obligatorio",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorMorado,
                              foregroundColor: colorNaranja,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.saveAndValidate()) {
                                var formData = _formKey.currentState!.value;

                                // Obtener la credencial del usuario actualmente autenticado
                                final user = FirebaseAuth.instance.currentUser;
                                final userId = user
                                    ?.uid; // userId es null si el usuario no está autenticado

                                // Acceder al ID del evento seleccionado
                                var eventoId = _eventoSeleccionado!["id"];

                                // Crear una nueva lista de compras usando el mapa cantidadesPorFecha
                                var nuevaListaCompras =
                                    <Map<String, dynamic>>[];
                                cantidadesPorFecha.forEach((fecha, cantidad) {
                                  var nuevaCompra = {
                                    'fecha': fecha,
                                    'eventoNombre':
                                        _eventoSeleccionado!["nombre"],
                                    'eventoId': eventoId,
                                    'cantidad': cantidad.toString(),
                                    'nombre': formData['nombre'],
                                    'apellido': formData['apellido'],
                                    'rut': formData['rut'],
                                    'direccion': formData['direccion'],
                                    'telefono': formData['telefono'],
                                    'userId': userId,
                                  };
                                  var nombreCompra = "compra$contadorCompras";
                                  nuevaListaCompras
                                      .add({nombreCompra: nuevaCompra});
                                  cantidadCompras++;
                                  contadorCompras++;
                                });

                                // Agregar las nuevas compras a la lista de compras existente
                                /*  listaCompras.addAll(nuevaListaCompras); */

                                fechasSeleccionadas = [];
                                cantidadesSeleccionadas = [];
                                cantidadesPorFecha = {};

                                /* print(listaCompras); */
                                print(
                                    "La cantidad de compras que tienes es $cantidadCompras");

                                Future.delayed(Duration(seconds: 3), () {
                                  setState(() {
                                    mostrarGridImagenes = true;
                                    mostrarDatosUsuario = false;
                                  });
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Tu entrada ha sido agregada al carrito, redireccionando',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Enviar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorMorado,
                              foregroundColor: colorNaranja,
                            ),
                            onPressed: () {
                              setState(() {
                                mostrarDatosUsuario = false;
                                mostrarFormulario = true;
                              });
                            },
                            child: Text(
                              'Volver',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget moduloInformacion(String descripcion) {
    return Column(
      children: [
        Container(
          width: dispositivo == 'PC' ? 450 : 350,
          decoration: BoxDecoration(
            color: colorMorado,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(descripcion,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: dispositivo == 'PC' ? 16 : 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget moduloFecha(String fecha) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: colorMorado,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            width: 200,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.event,
                    color: Colors.white, size: dispositivo == 'PC' ? 24 : 20),
                Text(
                  fecha,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String nombreEventoActual = "";

  Widget btnEvento(
      IconData icono, String tipo, String nombre, String UidEvento) {
    return InkWell(
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
                  nombreEventoActual == nombre)
              ? Color.fromARGB(255, 107, 0, 200)
              : colorMorado,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        child: Container(
          margin: EdgeInsets.all(10),
          child: Icon(icono, color: colorNaranja, size: 26),
        ),
      ),
    );
  }

  Widget btnsEvento(String nombre, String uid, String? userUid,
      eventoSeleccionado, entryValue) {
    return Container(
      margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.1, bottom: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          btnEvento(Icons.info_outline, 'Información', nombre, uid),
          InkWell(
            onTap: () {
              setState(() {
                mostrarGridImagenes = false;
                mostrarFormulario = true;
                _eventoSeleccionado = entryValue;
              });
              print('Botón de compra presionado');
            },
            child: Container(
              decoration: BoxDecoration(
                color: colorMorado, // Color de fondo morado
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(Icons.attach_money_rounded,
                  color: colorNaranja), // Icono naranja
            ),
          ),
          btnEvento(Icons.map_outlined, 'Mapa', nombre, uid),
          btnEvento(
              Icons.favorite_border_outlined, "Guardar reseña", nombre, uid)
        ],
      ),
    );
  }

  Future<void> subirFavoritos(String UidEvento) async {
    try {
      // Importante: Este tipo de declaracion se utiliza para solamente actualizar la informacion solicitada y no manipular informacion adicional, como lo es la imagen y esto permite no borrar otros datos importantes
      User? user = FirebaseAuth.instance.currentUser;
      print(UidEvento);
      print(eventosGuardados);
      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(user?.uid);

      docRef.update({
        'eventosGuardados': FieldValue.arrayUnion([UidEvento])
      });
      print('Ingreso de informacion exitoso.');
      obtenerEventosGuardados();
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
      print(eventosGuardados);
      // Se busca la coleccion 'users' de la BD de Firestore en donde el uid sea igual al del usuario actual
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection("users").doc(user?.uid);
      // Se actualiza la informacion del usuario actual mediante los controladores, que son los campos de informacion que el usuario debe rellenar

      docRef.update({
        'eventosGuardados': FieldValue.arrayRemove([uidResena])
      });
      print('Ingreso de informacion exitoso.');
      obtenerEventosGuardados();
      // Una vez actualizada la informacion, se devuelve a InfoUser para mostrar su nueva informacion
    } catch (e) {
      print("Error al intentar ingresar informacion");
    }
  }

  Future<List<dynamic>?> obtenerEventosGuardados() async {
    User? user = FirebaseAuth.instance.currentUser;
    firestore.collection('users').doc(user?.uid).get().then((value) {
      setState(() {
        eventosGuardados = value.data()!['eventosGuardados'];
      });
    });
  }

  Widget gridImagenes() {
    int contador = 0;
    int contadorCompras = 1;
    var listaElementos = [];

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: geteventosData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        List<Map<String, dynamic>> cafeteriasDataList = snapshot.data!;

        return Align(
          child: CarouselSlider(
            options: CarouselOptions(
              enlargeCenterPage: true,
              viewportFraction: dispositivo == 'PC' ? 0.4 : 0.9,
              aspectRatio: 16 / 9,
              disableCenter: true,
              enableInfiniteScroll: false,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlay: false,
              height: dispositivo == 'PC'
                  ? MediaQuery.of(context).size.height * 0.72
                  : MediaQuery.of(context).size.height * 0.85,
            ),
            items: cafeteriasDataList.asMap().entries.map((entry) {
              int index = entry.key;
              String nombre = entry.value["nombre"];
              String urlImagen = entry.value["imagen"].isNotEmpty
                  ? entry.value["imagen"][0]
                  : "assets/logo.png";
              String lugar = entry.value["lugar"];
              String descripcion = entry.value["descripcion"];
              String fecha = entry.value["fecha"];
              String ubicacion = entry.value["ubicacion"];

              return Container(
                  width: dispositivo == "PC"
                      ? MediaQuery.of(context).size.width - 600
                      : MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 0, top: 0),
                  child: cardTemplate(
                      template: "Eventos",
                      title: ubicacion,
                      title2: nombre,
                      title3: "Precio",
                      image: urlImagen,
                      dispositivo: dispositivo,
                      body: Container(
                        width: 500,
                        height: 236,
                        child: Column(
                          children: [
                            Expanded(child: moduloInformacion(descripcion)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  moduloFecha(fecha),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  btnsEvento(
                                      'Nombre del evento',
                                      'Creador del evento',
                                      'ID del evento',
                                      _eventoSeleccionado,
                                      entry.value)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      icon: Icons.location_on));
            }).toList(),
          ),
        );
      },
    );
  }

/*   Widget formularioEventos(){
    return 
  }; */

  Widget vistaTransbankStudio() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 220,
        child: vistaCarrito(listaCompras));
  }

  /* ---------------------VISTA CARRITO--------------------------------- */
  int _total = 0;

  Widget vistaCarrito(List<Map<String, dynamic>> listaCompras) {
    int precioUnitario = 100;
    _total = 0; // reiniciar la variable _total

    listaCompras.forEachIndexed((index, compra) {
      // utilizar forEachIndexed en lugar de forEach
      if (compra == null || compra.isEmpty) {
        return;
      }
      compra = listaCompras[index]['compra${index + 1}'];
      var cantidad = int.parse(compra['cantidad'] ?? '1');
      var precioTotal = cantidad * precioUnitario;
      _total += precioTotal; // agregar el precio total al total
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScaffold,
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorNaranja,
                ),
                width: MediaQuery.of(context).size.width / 2.5,
                height: dispositivo == 'PC'
                    ? MediaQuery.of(context).size.height * 0.72
                    : MediaQuery.of(context).size.height * 0.85,
                margin: EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Tu orden",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: listaCompras.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: listaCompras.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final compra =
                                      listaCompras[index]['compra${index + 1}'];
                                  if (compra == null || compra.isEmpty) {
                                    return SizedBox();
                                  }

                                  // Obtener la cantidad actual del artículo
                                  final cantidad =
                                      int.parse(compra['cantidad'] ?? '1');

                                  var precioTotal = cantidad * precioUnitario;
                                  /* 1 *100 = 100
                                    2* 100 = 200
                                    total = total + precio total
                                      100      0      100
                                      300         100   + 200
                                                300        300
                                      
                                   */

                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              compra!['eventoNombre'] ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                                DateFormat('dd/MM/yyyy').format(
                                                  compra['fecha']?.toLocal() ??
                                                      DateTime.now(),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              width: 100,
                                              child: Wrap(
                                                spacing: 10,
                                                children: [
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon:
                                                            Icon(Icons.remove),
                                                        onPressed: () {
                                                          setState(() {
                                                            if (cantidad > 1) {
                                                              listaCompras[index]
                                                                          [
                                                                          'compra${index + 1}']![
                                                                      'cantidad'] =
                                                                  (cantidad - 1)
                                                                      .toString();
                                                              _total -=
                                                                  precioUnitario;
                                                              print(
                                                                  listaCompras);
                                                            } else {
                                                              listaCompras[
                                                                          index]
                                                                      [
                                                                      'compra${index + 1}']![
                                                                  'cantidad'] = '1';
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Text(
                                                        '$cantidad',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.add),
                                                        onPressed: () {
                                                          setState(() {
                                                            listaCompras[index][
                                                                        'compra${index + 1}']![
                                                                    'cantidad'] =
                                                                (cantidad + 1)
                                                                    .toString();
                                                            _total +=
                                                                precioUnitario;
                                                            print(listaCompras);
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                                '\$${precioTotal.toString()}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                listaCompras.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  );
                                })
                            : Center(
                                child: Text(
                                  'No hay compras en tu carrito',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorMorado,
                ),
                height: dispositivo == 'PC'
                    ? MediaQuery.of(context).size.height / 2
                    : MediaQuery.of(context).size.height * 0.85,
                width: MediaQuery.of(context).size.height / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: \$${_total.toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.height / 2,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(colorNaranja),
                        ),
                        onPressed: () {
                          // Lógica para ir a pagar
                          print(_total);
                        },
                        child: Text('Ir a pagar'),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.height / 2,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          setState(() {
                            listaCompras.clear();
                            print(listaCompras);
                          });
                        },
                        child: Text('Eliminar todo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget vistaWeb() {
    return (Dialog(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutBack,
        height: MediaQuery.of(context).size.height - 50,
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
            margin: EdgeInsets.only(top: 50, left: 50, right: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
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
                          mostrarGridImagenes
                              ? 'Carrito'
                              : mostrarFormulario
                                  ? "Comprar entradas"
                                  : mostrarDatosUsuario
                                      ? "Ingresa tus datos"
                                      : "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOutBack,
                            width: mostrarGridImagenes
                                ? (mostrarControl ? 250 : 80)
                                : 250,
                            decoration: BoxDecoration(
                              color: colorMorado,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: SingleChildScrollView(
                              child: Container(
                                height:
                                    70, // Ajustar a la altura inicial del contenedor
                                child: mostrarGridImagenes
                                    ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return vistaCarrito(listaCompras);
                                            },
                                          );
                                        },
                                        child: mostrarControl2
                                            ? Center(
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                      mostrarGridImagenes
                                                          ? 'Resumen de tu compra'
                                                          : _eventoSeleccionado![
                                                              "nombre"],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            2), // Ajustar espacio entre elementos
                                                    SizedBox(
                                                        height:
                                                            2), // Ajustar espacio entre elementos
                                                    Container(
                                                      width: 246.3,
                                                      decoration: BoxDecoration(
                                                        color: colorMorado,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width: 248,
                                                            height: 30,
                                                            color: colorMorado,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 200,
                                                                color:
                                                                    colorMorado,
                                                                child: Text(
                                                                  'nombre evento',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: 46,
                                                                color:
                                                                    colorMorado,
                                                                child: Text(
                                                                  '500',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      colorMorado,
                                                                ),
                                                                width: 200,
                                                                child: Text(
                                                                  'Total',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      colorMorado,
                                                                ),
                                                                width: 46,
                                                                child: Text(
                                                                  '1000',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                                color:
                                                                    colorMorado,
                                                              ),
                                                              width: 246.3,
                                                              child: ElevatedButton(
                                                                  onPressed:
                                                                      () {},
                                                                  child: Text(
                                                                      "Ir al carrito"))),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40),
                                                                color:
                                                                    colorMorado,
                                                              ),
                                                              width: 246.3,
                                                              child:
                                                                  ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            colorNaranja,
                                                                        foregroundColor:
                                                                            colorMorado,
                                                                      ),
                                                                      onPressed:
                                                                          () {},
                                                                      child: Text(
                                                                          "Pagar directamente"))),
                                                        ],
                                                      ),
                                                    ),

                                                    // Añadir más elementos aquí
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                width: 30,
                                                height: 30,
                                                child: Center(
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Icon(
                                                          Icons
                                                              .shopping_cart_sharp,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      if (cantidadCompras > 0)
                                                        Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    1),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            constraints:
                                                                BoxConstraints(
                                                              minWidth: 16,
                                                              minHeight: 16,
                                                            ),
                                                            child: Text(
                                                              cantidadCompras
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      )
                                    : Center(
                                        child: Text(
                                          _eventoSeleccionado!["nombre"],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        mostrarGridImagenes == false
                            ? Align(
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
                                              milliseconds:
                                                  mostrarData2 ? 50 : 550), () {
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
                              )
                            : SizedBox()
                      ],
                    )),
                Container(
                  child: vistaTransbankStudio(),
                  margin: EdgeInsets.only(top: 40),
                )
              ],
            )),
      ),
    ));
  }

  Widget vistaMobile() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 50,
      decoration: BoxDecoration(color: colorScaffold),
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return vistaCarrito(listaCompras);
                  },
                );
              },
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorMorado,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Entradas',
                            style: TextStyle(
                                color: colorNaranja,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Icon(
                            Icons.shopping_cart_sharp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          if (cantidadCompras > 0)
                            Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                cantidadCompras.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              margin: EdgeInsets.only(left: 5),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height - 150,
              decoration: BoxDecoration(
                color: colorScaffold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: vistaTransbankStudio(),
            ),
            /* if (pantalla < 882)
            Container(
              height: MediaQuery.of(context).size.height - 600,
              child: columnaControlCamara(),
            )
          else
            filaControlCamara(), */
          ],
        ),
      ),
    );
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
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
