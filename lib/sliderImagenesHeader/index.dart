import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba/header/header.dart';

import 'package:prueba/login/login.dart';

class index extends StatefulWidget {
  final List<Widget> imagenes;
  final bool usuario;

  index({required this.imagenes, required this.usuario});

  @override
  _indexState createState() => _indexState();
}

class _indexState extends State<index> {
  final PageController _pageController = PageController(initialPage: 0);

  int _currentPage = 0;
  bool usuarioLogeado = false;

  @override
  Widget build(BuildContext context) {
    var dispositivo = '';
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
    final ancho_pantalla = MediaQuery.of(context).size.width;

    setState(() {
      if (ancho_pantalla > 1130) {
        dispositivo = 'PC';
      } else {
        dispositivo = 'MOVIL';
      }
    });
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: widget.imagenes,
        ),

        Header(ancho_pantalla, usuarioLogeado),

        //(ancho_pantalla > 1180) ? Login() : Container(),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 150),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dispositivo == 'PC'
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        if (_currentPage == 0) {
                          _pageController.animateToPage(
                              widget.imagenes.length - 1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      },
                    )
                  : Container(),
              dispositivo == 'PC'
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        if (_currentPage == widget.imagenes.length - 1) {
                          _pageController.animateToPage(0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      },
                    )
                  : Container(),
            ],
          ),
        )
      ],
    );
  }
}
