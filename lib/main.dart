import 'dart:ui';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prueba/firebase_options.dart';
import 'package:prueba/login/login.dart';
import 'package:prueba/ventanas/eventosUI/allEvents.dart';
import 'package:prueba/ventanas/shoppingUI/shoppingCartUI.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'dart:html' as html;

import 'sliderImagenesHeader/index.dart';

Future<void> main() async {
  List<Map<String, dynamic>> listaCompras = [];
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ListaComprasInheritedWidget(
    listaCompras: listaCompras,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoffeeMondo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'CoffeeMondo'),
      routes: {
        '/eventos': (context) => EventosUI(tipoUI: ""),
        '/carrito': (context) => ShoppingUI(
              tipoUI: "carrito",
            )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();

    //setup listener ---------------------------------
    // Registra un listener para el evento "message"
  }

  var dispositivo = '';
  int _counter = 0;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  var containerWidth = false;
  var containerHeight = 0;
  /*  void setupMessageListener() {} */

  late WebViewXController webviewController;
  @override
  Widget build(BuildContext context) {
    html.window.addEventListener("message", (html.Event event) {
      // Convierte la lista de path en una cadena separada por "/"
      String message = event.path.map((e) => e.toString()).join("/");
      // Muestra un dialog en caso de éxito
      // Muestra el mensaje en la consola
      print("Mensaje recibido desde JavaScript: $message");

      setState(() {});
    });

    bool usuarioExiste = currentUser != null;
    final ancho_pantalla = MediaQuery.of(context).size.width;
    setState(() {
      if (ancho_pantalla > 1130) {
        dispositivo = 'PC';
      } else {
        dispositivo = 'MOVIL';
      }
    });
    return Scaffold(
        body: PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.width * 0.75),
      child: Stack(children: [
        index(
          usuario: usuarioExiste,
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
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: dispositivo == "PC"
                ? MediaQuery.of(context).size.width / 4
                : MediaQuery.of(context).size.width,
            height: dispositivo == "PC"
                ? MediaQuery.of(context).size.height * 0.8
                : 200,
            child: Positioned(
                bottom: 0,
                right: 0,
                child: WebViewX(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  initialContent: '''
                <html lang="es">
            <head>
              <link rel="stylesheet" href="main.css">
              <meta charset="utf-8">
              <title></title>
            </head>
            <body>
              <script src="https://www.gstatic.com/dialogflow-console/fast/messenger-cx/bootstrap.js?v=1"></script>
            <df-messenger df-cx="true" location="us-central1" chat-title="Agente Virtual de CoffeeMondo ☕" agent-id="aeee7fab-0176-4d4f-8bd5-c1f2c7298ea0" language-code="es" chat-icon="assets/logo.png">
            </df-messenger>
              <script>
            window.addEventListener('dfMessengerLoaded', function (event) {
                const dfMessenger = document.querySelector('df-messenger');
                const openText = ('¡Hola, bienvenid@! ¿Deseas interactuar con nuestro agente virtual: Mondo Bot?');
            dfMessenger.renderCustomText(openText);
            });
            
              </script>
              
              <script>
                const dfMessenger = document.querySelector('df-messenger');
                dfMessenger.addEventListener('event-type', function (event) {
            
                });
              </script>
              <h1></h1>
            </body>
            <style>
              df-messenger {
               --df-messenger-bot-message: #FF4F34ff;
               --df-messenger-button-titlebar-color: #FF4F34ff;
               --df-messenger-chat-background-color: #603D8Dff;
               --df-messenger-font-color: white;
               --df-messenger-send-icon: #FF4F34ff;
               --df-messenger-user-message: #D7432Cff;
              }
            </style>
          </html>
          
              ''',
                  initialSourceType: SourceType.html,
                  onWebViewCreated: (controller) =>
                      webviewController = controller,
                )),
          ),
        ),
      ]),
    ));
  }
}
