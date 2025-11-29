import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mayvin/view/player.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Widget build(BuildContext context) {
    return PlayerWrapper(audioPlayer: audioPlayer);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}