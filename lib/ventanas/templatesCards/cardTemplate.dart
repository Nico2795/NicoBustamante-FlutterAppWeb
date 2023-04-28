import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

//Colores
var colorScaffold = Color(0xffffebdcac);
var colorNaranja = Color.fromARGB(255, 255, 79, 52);
var colorMorado = Color.fromARGB(0xff, 0x52, 0x01, 0x9b);

class cardTemplate extends StatelessWidget {
  final String template;
  final String title;
  final String title2;
  final String title3;
  final String image;
  final String dispositivo;
  final Widget body;
  final IconData icon;

  cardTemplate({
    Key? key,
    required this.template,
    required this.title,
    required this.title2,
    required this.title3,
    required this.image,
    required this.dispositivo,
    required this.body,
    required this.icon,
  }) : super(key: key);

//title en este codigo hace referencia a la ubicacion mostrada en vista Eventos, o a las cafeterias mostradas en vistaReseñas
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
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
              ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: ImageNetwork(
                  image: image,
                  height: 250,
                  width: 500,
                  fitWeb: BoxFitWeb.fill,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Container(
                            margin: EdgeInsets.only(
                              right: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Text(
                              title,
                              style: TextStyle(
                                color: colorNaranja,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          icon: Container(
                            margin: EdgeInsets.only(
                              left: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: colorNaranja,
                              size: 24,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(colorMorado),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      title2,
                      style: TextStyle(
                        color: colorMorado,
                        fontSize: dispositivo == 'PC' ? 30 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title3,
                      style: TextStyle(
                        color: colorMorado,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              body
            ],
          ),
        ),
      ),
    );
  }
}
