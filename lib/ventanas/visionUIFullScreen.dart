import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:firebase_database/firebase_database.dart';

class VisionUIFullScreen extends StatefulWidget {
  const VisionUIFullScreen({super.key});

  @override
  _VisionUIFullScreenState createState() => _VisionUIFullScreenState();
}

class _VisionUIFullScreenState extends State<VisionUIFullScreen> {
  Widget dataStudio() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision UI'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Vision UI'),
            dataStudio(),
          ],
        ),
      ),
    );
  }
}
