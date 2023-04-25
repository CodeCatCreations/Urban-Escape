import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class SoundsPage extends StatelessWidget {
  const SoundsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          SoundWidget(
            icon: Icons.sunny,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            player: AudioPlayer(),
          ),
          SoundWidget(
            icon: Icons.cloudy_snowing,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            player: AudioPlayer(),
          ),
          SoundWidget(
            icon: Icons.waves,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            player: AudioPlayer(),
          ),
          SoundWidget(
            icon: Icons.wine_bar,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            player: AudioPlayer(),
          ),
          SoundWidget(
            icon: Icons.forest,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            player: AudioPlayer(),
          ),
          SoundWidget(
            icon: Icons.beach_access,
            activatedColor: Colors.green,
            deactivatedColor: Colors.grey,
            player: AudioPlayer(),
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
  final AudioPlayer player;

  const SoundWidget({
    Key? key,
    required this.icon,
    required this.activatedColor,
    required this.deactivatedColor,
    required this.player,
  }) : super(key: key);

  @override
  State<SoundWidget> createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<SoundWidget> {
  bool _isActivated = false;
  double _volume = 0.5;

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
    });
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
    });
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
