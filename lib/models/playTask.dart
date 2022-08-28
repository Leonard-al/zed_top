import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

class PlayCurrentSong extends StatefulWidget {
  const PlayCurrentSong({
    Key? key,
  }) : super(key: key);

  @override
  State<PlayCurrentSong> createState() => _PlayCurrentSongState();
}

class _PlayCurrentSongState extends State<PlayCurrentSong> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    isPlaying ? null : dispose();
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatTime(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));

      return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Slider(
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);
              await audioPlayer.resume();
            }),
        Row(
          children: [Text(formatTime(position)), Text(formatTime(duration))],
        ),
        CircleAvatar(
          child: IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                } else {
                  // await audioPlayer.play(AssetSource);
                }
              }),
        )
      ],
    );
  }
}
