import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';

class VisionUI extends StatefulWidget {
  const VisionUI({super.key});

  @override
  _VisionUIState createState() => _VisionUIState();
}

class _VisionUIState extends State<VisionUI> {
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
          width: MediaQuery.of(context).size.width * 0.47,
          height: MediaQuery.of(context).size.width * 0.325,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
          ),
          child: videoPlayer(),
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
              child: switchActiveCamera(),
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

  Widget vistaDataStudio() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        mostrarDataStudio = true;
      });
    });
    return Container(
      width: 980,
      height: 540,
      color: Colors.black,
      child: Container(),
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
                          'Vision AI',
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
                            width: mostrarControl ? 250 : 80,
                            height: 70,
                            decoration: BoxDecoration(
                                color: colorMorado,
                                borderRadius: BorderRadius.circular(40)),
                            child: GestureDetector(
                              onTap: (() {
                                setState(() {
                                  mostrarControl = !mostrarControl;
                                  mostrarData2 = false;
                                });
                                Future.delayed(
                                    Duration(
                                        milliseconds:
                                            mostrarControl2 ? 50 : 550), () {
                                  setState(() {
                                    mostrarControl2 = !mostrarControl2;
                                    mostrarData = false;
                                  });
                                });
                              }),
                              child: mostrarControl2
                                  ? Center(
                                      child: Text(
                                        'Camara remota',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : ImageIcon(
                                      AssetImage('assets/icon.png'),
                                      color: colorNaranja,
                                    ),
                            ),
                          ),
                        )
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(top: 40),
                    child:
                        (mostrarData2) ? vistaDataStudio() : vistaVisionAI()),
              ],
            )),
      ),
    ));
  }

  Widget switchActiveCamera() {
    return (Container(
      //color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              (dispositivo == 'PC') ? 'Apagar' : 'Apagar camara',
              style: TextStyle(
                  color: (dispositivo == 'PC') ? colorMorado : colorNaranja,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: activeCamera,
            onChanged: (value) {
              setState(() {
                setState(() {
                  activeCamera = value;
                  mostrarControl = value;
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller.play();
                  }
                });
              });
            },
            activeTrackColor: colorMorado,
            activeColor: colorNaranja,
            inactiveTrackColor: colorMorado,
            inactiveThumbColor: colorNaranja,
          ),
          Container(
            child: Text(
              (dispositivo == 'PC') ? 'Encender' : 'Encender camara',
              style: TextStyle(
                  color: (dispositivo == 'PC') ? colorMorado : colorNaranja,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
        switchActiveCamera(),
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
        switchActiveCamera(),
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
                  'Vision con inteligencia artificial',
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
              child: videoPlayer(),
            ),
            (pantalla < 882)
                ? Container(
                    height: MediaQuery.of(context).size.height - 450,
                    child: columnaControlCamara(),
                    //decoration: BoxDecoration(color: Colors.black),
                  )
                : filaControlCamara(),
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
