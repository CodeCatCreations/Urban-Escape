import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class SoundsPage extends StatelessWidget {
  const SoundsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        children: const [
          SoundWidget(
            icon: Icons.sunny,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            soundFilePath: "https://bigsoundbank.com/UPLOAD/mp3/0999.mp3", // Birds
          ),
          SoundWidget(
            icon: Icons.cloudy_snowing,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            soundFilePath: "https://bigsoundbank.com/UPLOAD/mp3/0740.mp3", // Rain
          ),
          SoundWidget(
            icon: Icons.waves,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            soundFilePath: "https://bigsoundbank.com/UPLOAD/mp3/0267.mp3", // Waves and birds
          ),
          SoundWidget(
            icon: Icons.grass,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            soundFilePath: "https://bigsoundbank.com/UPLOAD/mp3/0908.mp3", // Wind in tall grass
          ),
          SoundWidget(
            icon: Icons.forest,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            soundFilePath: "https://bigsoundbank.com/UPLOAD/mp3/0100.mp3", // Forest
          ),
          SoundWidget(
            icon: Icons.fireplace,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            soundFilePath: "https://bigsoundbank.com/UPLOAD/mp3/0987.mp3", // Fire
          ),
        ],
      ),
    );
  }
}

class SoundWidget extends StatefulWidget {
  final IconData icon;
  final Color activatedColor;
  final Color deactivatedColor;
  final String soundFilePath;

  const SoundWidget({
    Key? key,
    required this.icon,
    required this.activatedColor,
    required this.deactivatedColor,
    required this.soundFilePath,
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
                ? Icon(widget.icon, color: widget.activatedColor)
                : Icon(widget.icon, color: widget.deactivatedColor)),
            onPressed: _toggleSound,
          ),
        ),
        const SizedBox(height: 16),
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
    await _audioPlayer.play(widget.soundFilePath, volume: _volume);
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
