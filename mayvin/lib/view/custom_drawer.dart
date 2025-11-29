import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/playerbloc.dart';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../model/audio_item.dart';

class CustomDrawer extends StatefulWidget {
  final PageController pageController;
  final List<AudioItem> canciones;
  final PlayerBloc bloc;
  final VoidCallback onSettingsTap;

  const CustomDrawer({
    Key? key,
    required this.canciones,
    required this.onSettingsTap,
    required this.bloc,
    required this.pageController,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late PageController drawerPageController;
  bool isManuallyChanging = false;

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.bloc.state is PlayingState) {
      initialIndex = (widget.bloc.state as PlayingState).currentIndex;
    }
    drawerPageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    drawerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayState>(
      listener: (context, state) {
        if (state is PlayingState &&
            !isManuallyChanging &&
            drawerPageController.hasClients) {
          drawerPageController.animateToPage(
            state.currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: BlocBuilder<PlayerBloc, PlayState>(
        builder: (context, state) {
          AudioItem? currentSong;
          bool isPlaying = false;

          if (state is PlayingState) {
            if (state.currentIndex >= 0 && state.currentIndex < widget.canciones.length) {
              currentSong = widget.canciones[state.currentIndex];
              isPlaying = state.playing;
            }
          }

          return Drawer(
            backgroundColor: const Color(0xfff3d4ba),
            child: Column(
              children: [
                _buildHeader(),
                Divider(color: Colors.black.withOpacity(0.1), height: 1, thickness: 1),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings, color: Color(0xffff0000), size: 24),
                        title: const Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSettingsTap();
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: drawerPageController,
                    itemCount: widget.canciones.length,
                    onPageChanged: (indice) {
                      isManuallyChanging = true;
                      final actual = widget.bloc.state;
                      if (actual is PlayingState && indice != actual.currentIndex) {
                        widget.bloc.add(PlayerLoadEvent(indice));
                      }
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) setState(() => isManuallyChanging = false);
                      });
                    },
                    itemBuilder: (context, index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(widget.canciones[index].imagePath, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                _buildPlaybackControls(currentSong, isPlaying),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xffffc79c),
            const Color(0xffff0000).withOpacity(0.8),
            const Color(0xfff3d4ba),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'MayVin Music',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: "DMSerif",
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu música, tu estilo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(AudioItem? currentSong, bool isPlaying) {
    final bloc = context.read<PlayerBloc>();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffffc79c).withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentSong != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xffff0000).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentSong.artist,
                      style: TextStyle(
                        color: Colors.black87.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.skip_previous,
                  onPressed: () => bloc.add(PrevEvent()),
                ),
                _buildControlButton(
                  icon: isPlaying ? Icons.pause : Icons.play_arrow,
                  onPressed: () => bloc.add(isPlaying ? PauseEvent() : PlayEvent()),
                  isPrimary: true,
                ),
                _buildControlButton(
                  icon: Icons.skip_next,
                  onPressed: () => bloc.add(NextEvent()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: isPrimary ? 64 : 56,
        height: isPrimary ? 64 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary
              ? const Color(0xffff0000).withOpacity(0.2)
              : Colors.white.withOpacity(0.6),
          border: isPrimary
              ? Border.all(color: const Color(0xffff0000).withOpacity(0.6), width: 2)
              : Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        ),
        child: Icon(
          icon,
          color: isPrimary ? const Color(0xffff0000) : Colors.black87,
          size: isPrimary ? 32 : 28,
        ),
      ),
    );
  }
}