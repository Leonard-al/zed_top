import 'dart:isolate';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:path_provider/path_provider.dart';
import 'package:zclassic/main.dart';

import 'package:zclassic/screens/song_details.dart';

class AllSongList extends StatefulWidget {
  const AllSongList({
    Key? key,
    required this.cover,
    required this.theFile,
    required this.titles,
    required this.curIndex,
    required this.composer,
    required this.uploadedTime,
  }) : super(key: key);

  final String cover;
  final String theFile;
  final String titles;
  final String composer;
  final DateTime uploadedTime;
  final List<AllSongList> curIndex;

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort? sendPort = IsolateNameServer.lookupPortByName('download');
    sendPort?.send([id, status, progress]);
  }

  @override
  State<AllSongList> createState() => _AllSongListState();
}

class _AllSongListState extends State<AllSongList> {
  bool isPlaying = false;
  final AudioPlayer _player = AudioPlayer(playerId: 'one');
  ReceivePort receivePort = ReceivePort();
  int progressIndicator = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    _bindBackgroundIsolate();
    setupAudio();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _player.dispose();
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      super.dispose();
    }
  }

  Future<void> setupAudio() async {
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _player.onPlayerStateChanged.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });
      }
    });

    _player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    _player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });

    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _player.dispose();
        });
      }
    });
  }

  Future<void> playAudio(String s) async {
    _player.play(UrlSource(s));
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'downloader_send_port');
    receivePort.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (mounted) {
        setState(() {
          progressIndicator = progress;
        });
      }
    });
  }

  Dialog imageDialog() {
    return Dialog(
      backgroundColor: const Color(0xff1A3C40),
      insetAnimationDuration: const Duration(seconds: 2),
      insetAnimationCurve: Curves.bounceIn,
      insetPadding: const EdgeInsets.all(2.0),
      child: Container(
        width: 500,
        height: 400,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
                image: NetworkImage(widget.cover), fit: BoxFit.cover)),
      ),
    );
  }

  Future download() async {
    final baseStorage = await getExternalStorageDirectory();

    final taskId = await FlutterDownloader.enqueue(
      url: widget.theFile,
      saveInPublicStorage: true,
      savedDir: baseStorage!.path,
      fileName: "${widget.composer}_${widget.titles} ",
      showNotification: true,
      openFileFromNotification: true,
      requiresStorageNotLow: true,
    );
    return taskId;
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

    return kIsWeb
        ? Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                        context: context, builder: (_) => imageDialog());
                  },
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.network(
                      widget.cover,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: SizedBox(
                    // height: 200,
                    width: 200,
                    child: Text(
                      widget.titles,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SongDetails(
                          image: widget.cover,
                          audio: widget.theFile,
                          title: widget.titles,
                          artist: widget.composer,
                          date: widget.uploadedTime)));
                },
                child: Card(
                  color: const Color(0xff1D5C63),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.5, 10.0),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (_) => imageDialog());
                                },
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(widget.cover),
                                  backgroundColor: Colors.black26,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: InkWell(
                                  child: Column(children: [
                                    Text(
                                      widget.titles,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900),
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.composer,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300),
                                      softWrap: true,
                                    ),
                                  ]),
                                ),
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(2.0),
                                splashRadius: 15,
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_circle,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  if (isPlaying) {
                                    await _player.pause();
                                  } else {
                                    await _player.dispose();
                                    setState(() {
                                      _player.play(
                                        UrlSource(widget.theFile),
                                      );
                                    });

                                    // playAudio(widget.theFile);
                                  }

                                  // if (isPlaying) {
                                  //   null;
                                  // } else {
                                  //   // audioPlayer.resume();
                                  // }
                                },
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(2.0),
                                splashRadius: 15,
                                onPressed: () {
                                  download();
                                },
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                              ),
                            ]),
                        Visibility(
                          visible: isPlaying ? true : false,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 10,
                                  width: 200,
                                  child: Slider(
                                    min: 0.0,
                                    max: duration.inSeconds.toDouble(),
                                    value: position.inSeconds.toDouble(),
                                    onChanged: (value) async {
                                      var position =
                                          Duration(seconds: value.toInt());
                                      await _player.seek(position);
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatTime(position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(formatTime(duration - position),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
