import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_network/image_network.dart';


class sliderCard extends StatefulWidget {
  @override
  _sliderCardState createState() => _sliderCardState();
}

class _sliderCardState extends State<sliderCard> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
 
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
  };
  }
}



