import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:webviewx/webviewx.dart';

class DataUI extends StatefulWidget {
  const DataUI({super.key});

  @override
  _DataUIState createState() => _DataUIState();
}

class _DataUIState extends State<DataUI> {
  //Colores
  var colorScaffold = Color(0xffffebdcac);
  var colorNaranja = Color.fromARGB(255, 255, 79, 52);
  var colorMorado = Color.fromARGB(0xff, 0x52, 0x01, 0x9b);
  late WebViewXController webviewController;
  //Modulo VisionAI
  var mostrarControl = false;
  var mostrarControl2 = false;
  var mostrarData = false;
  var mostrarData2 = false;
  var mostrarDataStudio = false;
  var uidCamara = "";
  var pantalla = 0.0;
  late VideoPlayerController _controller;
  final videoUrl = 'https://www.visionsinc.xyz/hls/test.m3u8';
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

  int maxPositionY(int cantZoom) {
    var maxY = (cantZoom * 5) * 5;
    return maxY;
  }

  int maxPositionX(int cantZoom) {
    var maxX = ((cantZoom * 5) * 2) * 3;
    return maxX;
  }

  void centerCamera() async {
    final postData = {'inputTB': 0, 'inputLR': 0, 'zoom': 0};
    return FirebaseDatabase.instance
        .ref()
        .child('live/zoomInput')
        .update(postData);
  }

  //funcion para obtener todos los UID de la coleccion visionAI de la BD de Firestore

  void InputTB(String value) async {
    final ref = FirebaseDatabase.instance.ref();
    final stream = ref.child('live').child('zoomInput').onValue;
    await stream.first.then((event) {
      final username = event.snapshot.value as Map<String, dynamic>;
      int cantZoom = username['zoom'];
      int inputTB = username['inputTB'];
      var maxPost = maxPositionY(cantZoom);
      if (value == "Up") {
        inputTB -= 25;
      } else if (value == "Down") {
        inputTB += 25;
      }
      if (inputTB > maxPost) {
        inputTB = maxPost;
      } else if (inputTB < -maxPost) {
        inputTB = -maxPost;
      }

      final postData = {'inputTB': inputTB};
      return FirebaseDatabase.instance
          .ref()
          .child('live/zoomInput')
          .update(postData);
    });
  }

  void InputLR(String value) async {
    final ref = FirebaseDatabase.instance.ref();
    final stream = ref.child('live').child('zoomInput').onValue;
    await stream.first.then((event) {
      final username = event.snapshot.value as Map<String, dynamic>;
      int cantZoom = username['zoom'];
      int inputLR = username['inputLR'];
      var maxPost = maxPositionX(cantZoom);
      if (value == "Left") {
        inputLR -= 30;
      } else if (value == "Right") {
        inputLR += 30;
      }
      if (inputLR > maxPost) {
        inputLR = maxPost;
      } else if (inputLR < -maxPost) {
        inputLR = -maxPost;
      }

      final postData = {'inputLR': inputLR};
      return FirebaseDatabase.instance
          .ref()
          .child('live/zoomInput')
          .update(postData);
    });
  }

  void writeNewPost(bool value) async {
    // A post entry.
    final postData = {'Streaming': value};

    return FirebaseDatabase.instance.ref().child('live').update(postData);
  }

  Widget videoPlayer() {
    return (Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Container(),
    ));
  }

  Widget btnsOnOff() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: IconButton(
              color: colorNaranja,
              iconSize: 30,
              style: ButtonStyle(),
              onPressed: () {
                // Wrap the play or pause in a call to `setState`. This ensures the
                // correct icon is shown.
                setState(() {
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              },
              icon: Icon(Icons.power_settings_new)),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: IconButton(
              color: colorScaffold,
              iconSize: 30,
              style: ButtonStyle(),
              onPressed: () => writeNewPost(false),
              icon: Icon(Icons.power_settings_new)),
        ),
      ],
    ));
  }

  Widget consolaMovimiento() {
    print(uidCamara);
    var anchoAlto = 0.0;
    dispositivo == 'PC' ? anchoAlto = 50 : anchoAlto = 35;
    return (Column(
      children: [
        Container(
          width: anchoAlto,
          height: anchoAlto,
          decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: IconButton(
              color: colorNaranja,
              iconSize: (dispositivo == 'PC') ? 30 : 17,
              style: ButtonStyle(),
              onPressed: () => InputTB('Up'),
              icon: Icon(Icons.arrow_upward)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: anchoAlto,
              height: anchoAlto,
              decoration: BoxDecoration(
                  color: colorMorado,
                  borderRadius: BorderRadius.all(Radius.circular(40))),
              child: IconButton(
                  color: colorNaranja,
                  iconSize: (dispositivo == 'PC') ? 30 : 17,
                  style: ButtonStyle(),
                  onPressed: () => InputLR('Left'),
                  icon: Icon(Icons.arrow_back)),
            ),
            Container(
              width: anchoAlto,
              height: anchoAlto,
              decoration: BoxDecoration(
                  color: colorMorado,
                  borderRadius: BorderRadius.all(Radius.circular(40))),
              child: IconButton(
                  color: colorNaranja,
                  iconSize: (dispositivo == 'PC') ? 30 : 17,
                  style: ButtonStyle(),
                  onPressed: () => centerCamera(),
                  icon: Icon(Icons.select_all_outlined)),
            ),
            Container(
              width: anchoAlto,
              height: anchoAlto,
              decoration: BoxDecoration(
                  color: colorMorado,
                  borderRadius: BorderRadius.all(Radius.circular(40))),
              child: IconButton(
                  color: colorNaranja,
                  iconSize: (dispositivo == 'PC') ? 30 : 17,
                  style: ButtonStyle(),
                  onPressed: () => InputLR("Right"),
                  icon: Icon(Icons.arrow_forward)),
            ),
          ],
        ),
        Container(
          width: anchoAlto,
          height: anchoAlto,
          decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: IconButton(
              color: colorNaranja,
              iconSize: (dispositivo == 'PC') ? 30 : 17,
              style: ButtonStyle(),
              onPressed: () => InputTB("Down"),
              icon: Icon(Icons.arrow_downward)),
        ),
      ],
    ));
  }

  Widget btnsZoom() {
    var anchoAlto = 0.0;
    var iconSize = (dispositivo == 'PC') ? 30.0 : 17.0;

    dispositivo == 'PC' ? anchoAlto = 50 : anchoAlto = 35;
    void zoom(String value) async {
      final ref = FirebaseDatabase.instance.ref();
      final stream = ref.child('live').child('zoomInput').onValue;

      await stream.first.then((event) {
        final username = event.snapshot.value as Map<String, dynamic>;

        var zoom = username['zoom'];
        var maxinputTB;
        var maxinputLR;

        if (value == "zoom+") {
          zoom += 1;
        } else if (value == "zoom-") {
          zoom -= 1;
        }
        if (zoom >= 9) {
          zoom = 9;
        }
        var inputTB = username['inputTB'];
        var inputLR = username['inputLR'];
        maxinputTB = maxPositionY(zoom);
        maxinputLR = maxPositionX(zoom);
        var postData = {
          'zoom': zoom,
          'inputLR': inputLR,
          'inputTB': inputTB,
        };
        if (maxinputLR <= inputLR) {
          postData['inputLR'] = maxinputLR;
        }
        if (-maxinputLR >= inputLR) {
          postData['inputLR'] = -maxinputLR;
        }
        if (maxinputTB <= inputTB) {
          postData['inputTB'] = maxinputTB;
        }
        if (-maxinputTB >= inputTB) {
          postData['inputTB'] = -maxinputTB;
        }
        if (zoom <= 0) {
          centerCamera();
        } else {
          return FirebaseDatabase.instance
              .ref()
              .child('live/zoomInput')
              .update(postData);
        }
      });
    }

    return (Row(
      mainAxisAlignment: pantalla < 1031
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: anchoAlto,
          height: anchoAlto,
          decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: IconButton(
              color: colorNaranja,
              iconSize: iconSize,
              style: ButtonStyle(),
              onPressed: () => zoom('zoom+'),
              icon: Icon(Icons.zoom_in_outlined)),
        ),
        SizedBox(
          width: (dispositivo == 'PC') ? 30 : 10,
        ),
        Container(
          width: anchoAlto,
          height: anchoAlto,
          decoration: BoxDecoration(
              color: colorMorado,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: IconButton(
              color: colorNaranja,
              iconSize: iconSize,
              style: ButtonStyle(),
              onPressed: () => zoom('zoom-'),
              icon: Icon(Icons.zoom_out_outlined)),
        ),
      ],
    ));
  }

  Widget vistaVisionAI() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Container(
            child: videoPlayer(),
            height: MediaQuery.of(context).size.width * 0.2,
          ),
        ),
        Container(
          width: 250,
          height: 500,
          decoration: BoxDecoration(
              color: colorNaranja,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ]),
          child: Column(children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: btnsOnOff(),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: consolaMovimiento(),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 60, horizontal: 50),

              //color: Colors.black,
              child: btnsZoom(),
            )
          ]),
        ),
      ],
    ));
  }

  Widget dataStudio() {
    return WebViewX(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      initialContent: '''
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style type="text/css">
  html, body {
    margin: 0;
    padding: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
  }
  #datastudio {
    width: 100%;
    height: 100%;
  }
</style>
        </head>
        <body>
          <iframe id="datastudio" src="https://lookerstudio.google.com/embed/reporting/32e7bee6-09fc-4ebd-a389-52fc9cfcbbfb/page/zf4CD" frameborder="0" style="border:0" allowfullscreen></iframe>
        </body>
      </html>
    ''',
      initialSourceType: SourceType.html,
      onWebViewCreated: (controller) => webviewController = controller,
    );
  }

  Widget vistaDataStudio() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        mostrarDataStudio = true;
      });
    });
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 300,
      color: Colors.black,
      child: dataStudio(),
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
            margin: EdgeInsets.only(
                top: 50,
                left: dispositivo == 'PC' ? 50 : 0,
                right: dispositivo == 'PC' ? 50 : 0),
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
                          'Estudio de datos',
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
                                        'Estudio de datos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.dataset_outlined,
                                      color: colorNaranja,
                                      size: 60,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(top: 40), child: vistaDataStudio()),
              ],
            )),
      ),
    ));
  }

  Widget filaControlCamara() {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: consolaMovimiento(),
        ),
        Container(
          //color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Encender camara',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: mostrarControl,
                onChanged: (value) {
                  setState(() {
                    mostrarControl = value;
                  });
                },
                activeTrackColor: colorNaranja,
                activeColor: colorMorado,
                inactiveTrackColor: colorMorado,
                inactiveThumbColor: colorNaranja,
              ),
              Container(
                child: Text(
                  'Apagar camara',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          //color: Colors.black,
          child: btnsZoom(),
        )
      ],
    ));
  }

  Widget columnaControlCamara() {
    return (Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          //color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Encender camara',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: mostrarControl,
                onChanged: (value) {
                  setState(() {
                    mostrarControl = value;
                  });
                },
                activeTrackColor: colorNaranja,
                activeColor: colorMorado,
                inactiveTrackColor: colorMorado,
                inactiveThumbColor: colorNaranja,
              ),
              Container(
                child: Text(
                  'Apagar camara',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: consolaMovimiento(),
        ),
        btnsZoom(),
      ],
    ));
  }

  Widget vistaMobile() {
    return (Container(
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
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  'Estudio de datos',
                  style: TextStyle(
                      color: colorNaranja, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: dataStudio(),
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
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
