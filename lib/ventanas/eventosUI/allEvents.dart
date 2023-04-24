import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

void main() {
  runApp(GetMaterialApp(
    home: EventosUI(
      tipoUI: null,
    ),
  ));
}

class EventosUI extends StatefulWidget {
  final tipoUI;
  const EventosUI({required this.tipoUI});

  @override
  _EventosUIState createState() => _EventosUIState();
}

class CartController extends GetxController {
  final cartItems = [].obs;
  int get count => cartItems.length;

  void addToCart(item) {
    cartItems.add(item);
  }

  void removeFromCart(item) {
    cartItems.remove(item);
  }
}

class _EventosUIState extends State<EventosUI> {
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
  late VideoPlayerController _controller;
  final videoUrl = 'https://www.visionsinc.xyz/hls/test.m3u8';
  final cartItems = [].obs;
  final cartController = CartController();
  int cantidadCompras = 0;
  int contadorCompras = 1;

  void initState() {
    super.initState();

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

  List<Map<String, dynamic>> listaCompras = [];

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
                                listaCompras.addAll(nuevaListaCompras);

                                fechasSeleccionadas = [];
                                cantidadesSeleccionadas = [];
                                cantidadesPorFecha = {};

                                print(listaCompras);
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
                viewportFraction: dispositivo == "PC" ? 0.3 : 1,
                aspectRatio: 16 / 9,
                disableCenter: true,
                enableInfiniteScroll: false,
                autoPlay: false,
                height: 500),
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
                child: Card(
                  color: colorScaffold,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  child: Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 340,
                        ),
                        ImageNetwork(
                            /* borderRadius: BorderRadius.circular(10), */
                            image: urlImagen,
                            width: dispositivo == "PC"
                                ? 350
                                : MediaQuery.of(context).size.width,
                            height: dispositivo == "PC"
                                ? 150
                                : MediaQuery.of(context).size.height - 600,
                            fitAndroidIos: BoxFit.fill,
                            fitWeb: BoxFitWeb.fill),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          nombre,
                          style: TextStyle(
                            color: colorNaranja,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          fecha,
                          style: TextStyle(
                            color: colorNaranja,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          descripcion,
                          style: TextStyle(
                            color: colorNaranja,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          lugar,
                          style: TextStyle(
                            color: colorNaranja,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Precio",
                          style: TextStyle(
                            color: colorNaranja,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ubicacion,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: colorNaranja,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_2_rounded,
                                    color: colorNaranja,
                                    size: 12,
                                  ),
                                  Text(
                                    "Visitantes",
                                    style: TextStyle(
                                      color: colorNaranja,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: colorMorado,
                                    foregroundColor: colorNaranja,
                                    padding:
                                        EdgeInsets.only(left: 54, right: 54)),
                                onPressed: () {
                                  setState(() {
                                    mostrarGridImagenes = false;
                                    mostrarFormulario = true;
                                    _eventoSeleccionado = entry.value;
                                  });
                                },
                                child: Text(
                                  "¡Asistir!",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorMorado,
                                  foregroundColor: colorNaranja,
                                ),
                                onPressed: () {},
                                child: Text(
                                  "Más información",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
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
        height: MediaQuery.of(context).size.height - 300,
        child: mostrarGridImagenes
            ? gridImagenes()
            : mostrarFormulario
                ? entradaFormulario()
                : mostrarDatosUsuario
                    ? datosUsuario()
                    : Container());
  }

  Widget resumenCarrito(List<Map<String, dynamic>> listaCompras) {
    return Dialog(
      child: Container(
        color: colorScaffold,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 600,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                color: colorMorado,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Resumen de tu compra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              color: colorScaffold,
              width: 600,
              height: 200,
              margin: EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nombre del evento'),
                        Text('Fecha'),
                        Text('Cantidad'),
                        Text('Precio'),
                      ],
                    ),
                    Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: listaCompras.length,
                      itemBuilder: (BuildContext context, int index) {
                        final compra =
                            listaCompras[index]['compra${index + 1}'];
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(compra!['eventoNombre']),
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(compra!['fecha'].toLocal())),
                                Text(compra!['cantidad']),
                                Text('\$${compra['precio'].toString()}')
                              ],
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 600,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // Acción del botón "Ir al carrito"
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: Text('Ir al carrito'),
              ),
            ),
            SizedBox(
              height: 10,
              child:
                  DecoratedBox(decoration: BoxDecoration(color: colorScaffold)),
            ),
            SizedBox(
              width: 600,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // Acción del botón "Ir a pagar directamente"
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(colorNaranja),
                ),
                child: Text('Ir a pagar directamente'),
              ),
            ),
          ],
        ),
      ),
    );
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
                              ? 'Eventos'
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
                                              return resumenCarrito(
                                                  listaCompras);
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
                    return resumenCarrito(listaCompras);
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
                            ),
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
                color: Colors.black,
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
