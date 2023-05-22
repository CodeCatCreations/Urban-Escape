import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:urban_escape_application/app_pages/progress_page/daily_banner_page.dart';
import 'package:urban_escape_application/database/local_user.dart';

class SoundsPage extends StatelessWidget {
  const SoundsPage({Key? key}) : super(key: key);

  void showAchievementPopup(BuildContext context) async {
    bool achievementPopupShown =
        await LocalUser.getSoundAchievementPopupShown();
    if (!achievementPopupShown) {
      // ignore: use_build_context_synchronously
      ProgressBannerBar.show(
          context, 'Congrats! You have just passed an achievement!');
    }
    LocalUser.setSoundsAchievementPopupShown(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          children: [
            SoundWidget(
              imageFilePath: 'assets/icons/rainy.png',
              activatedColor: Colors.black54,
              deactivatedColor: Colors.white70,
              soundFileSource: AssetSource('sounds/Rain.mp3'), // Rain
            ),
            SoundWidget(
              imageFilePath: 'assets/icons/thunder.png',
              activatedColor: Colors.black54,
              deactivatedColor: Colors.white70,
              soundFileSource: AssetSource('sounds/Thunder.mp3'), // Thunder
            ),
            SoundWidget(
              imageFilePath: 'assets/icons/wind.png',
              activatedColor: Colors.black54,
              deactivatedColor: Colors.white70,
              soundFileSource: AssetSource('sounds/Wind.mp3'), // Wind
            ),
            SoundWidget(
              imageFilePath: 'assets/icons/wave.png',
              activatedColor: Colors.black54,
              deactivatedColor: Colors.white70,
              soundFileSource: AssetSource('sounds/Waves.mp3'), // Waves
            ),
            SoundWidget(
              imageFilePath: 'assets/icons/bird.png',
              activatedColor: Colors.black54,
              deactivatedColor: Colors.white70,
              soundFileSource: AssetSource('sounds/Birds.mp3'), // Birds
            ),
            SoundWidget(
              imageFilePath: 'assets/icons/campfire.png',
              activatedColor: Colors.black54,
              deactivatedColor: Colors.white70,
              soundFileSource: AssetSource('sounds/Campfire.mp3'), // Campfire
            ),
          ],
        ),
      ),
    );
  }
}

class SoundWidget extends StatefulWidget {
  final String imageFilePath;
  final Color activatedColor;
  final Color deactivatedColor;
  final Source soundFileSource;

  const SoundWidget({
    Key? key,
    required this.imageFilePath,
    required this.activatedColor,
    required this.deactivatedColor,
    required this.soundFileSource,
  }) : super(key: key);

  @override
  State<SoundWidget> createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<SoundWidget> {
  late final AudioPlayer _audioPlayer;
  bool _isActivated = false;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            iconSize: 100,
            icon: (_isActivated
                ? Image(
                    image: AssetImage(widget.imageFilePath),
                    color: widget.activatedColor)
                : Image(
                    image: AssetImage(widget.imageFilePath),
                    color: widget.deactivatedColor)),
            onPressed: _toggleSound,
          ),
        ),
        const SizedBox(height: 0),
        VolumeSlider(
          value: _volume,
          onChanged: _setVolume,
          isEnabled: _isActivated,
        ),
      ],
    );
  }

  void _toggleSound() {
    setState(() {
      _isActivated = !_isActivated;
      if (_isActivated) {
        _playSound();
      } else {
        _stopSound();
      }
    });
  }

  void _playSound() async {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(widget.soundFileSource);
    if (widget.imageFilePath == 'assets/icons/wave.png') {
        SoundsPage().showAchievementPopup(context);
    }
  }

  void _stopSound() {
    _audioPlayer.stop();
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _audioPlayer.setVolume(volume);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class VolumeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final bool isEnabled;

  const VolumeSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: isEnabled ? onChanged : null,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
    );
  }
}
