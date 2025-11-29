import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mayvin/view/progresslider.dart';
import 'package:mayvin/view/swiper.dart';
import 'dart:async';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/playerbloc.dart';
import '../model/audio_item.dart';
import 'audiosetting.dart';
import 'buttonpractice.dart';
import 'custom_drawer.dart';
import 'infosong.dart';
import '../service/databasehelper.dart';

class PlayerWrapper extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const PlayerWrapper({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _PlayerWrapperState createState() => _PlayerWrapperState();
}

class _PlayerWrapperState extends State<PlayerWrapper> {
  late final PlayerBloc bloc;
  List<AudioItem> canciones = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCanciones();
  }

  Future<void> _loadCanciones() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.getDataBase();
    
    final count = await dbHelper.getAudioItemsCount();
    
    if (count == 0) {
      final audioList = [
        AudioItem(
          "music/allthat.mp3",
          "All that",
          "Cristal",
          "assets/images/allthat_colored.jpg",
        ),
        AudioItem(
            "music/love.mp3",
            "Love",
            "Victor",
            "assets/images/love_colored.jpg"),
        AudioItem(
          "music/thejazzpiano.mp3",
          "Jazz Piano",
          "Oswaldo",
          "assets/images/thejazzpiano_colored.jpg",
        ),
        AudioItem(
          "music/misoledad.mp3",
          "Mi Soledad",
          "Los plebes del rancho de Ariel camacho",
          "assets/images/plebes.jpg",
        ),
        AudioItem("music/tutu.mp3", "TUTU", "Camilo", "assets/images/camilo.jpg"),
        AudioItem(
          "music/atravezdelvaso.mp3",
          "A Travez del Vaso",
          "Carin Leon",
          "assets/images/carin.jpg",
        ),
        AudioItem(
          "music/porquetequiero.mp3",
          "Porque Te Quiero",
          "Grupo Firme",
          "assets/images/grupofirme.jpg",
        ),
        AudioItem(
          "music/indecision.mp3",
          "Indecision",
          "La Arrolladora Banda Limon",
          "assets/images/arrolladora.jpg",
        ),
      ];
      
      for (int i = 0; i < audioList.length; i++) {
        await dbHelper.insertAudioItem(audioList[i]);
      }
    }
    
    canciones = await dbHelper.getAudioItems();
    
    setState(() {
      bloc = PlayerBloc(audioPlayer: widget.audioPlayer, canciones: canciones);
      bloc.add(PlayerLoadEvent(0));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return BlocProvider<PlayerBloc>(
      create: (_) => bloc,
      child: Player(canciones: canciones),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

class Player extends StatefulWidget {
  final List<AudioItem> canciones;

  const Player({Key? key, required this.canciones}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  static const _wormColor = Color(0xffff0000);
  late PageController pageController;
  StreamSubscription? blocSubscription;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, viewportFraction: .8);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PlayerBloc>();

      blocSubscription = bloc.stream.listen((state) {
        if (state is PlayingState && mounted && pageController.hasClients) {
          final currentPage = pageController.page?.round() ?? 0;
          if (currentPage != state.currentIndex) {
            final estaAnimando = pageController.position.isScrollingNotifier.value;
            if (estaAnimando) {
              pageController.jumpToPage(state.currentIndex);
            } else {
              final diferencia = (currentPage - state.currentIndex).abs();
              if (diferencia > 1) {
                pageController.jumpToPage(state.currentIndex);
              } else {
                pageController.animateToPage(
                  state.currentIndex,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: const Text(
          'MayVin Music',
          style: TextStyle(
            fontSize: 22,
            fontFamily: "DMSerif",
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, bloc),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: CustomDrawer(
        canciones: widget.canciones,
        bloc: bloc,
        pageController: pageController,
        onSettingsTap: () => _showSettings(context, bloc),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Swiper(
                pageController: pageController,
                audioList: widget.canciones,
                color: _wormColor,
                bloc: bloc,
              ),
            ),
            Informationsongs(audiolis: widget.canciones, bloc: bloc),
            Progresslider(color: _wormColor, bloc: bloc),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Buttonpractice(color: _wormColor, bloc: bloc),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    blocSubscription?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _showSettings(BuildContext context, PlayerBloc bloc) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: const Color(0xfff3d4ba),
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.45,
                child: AudioSettings(bloc: bloc),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
