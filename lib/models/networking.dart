import 'dart:core';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:zclassic/models/fetching_file.dart';

class SongStream extends StatefulWidget {
  const SongStream({
    Key? key,
    required this.firestoreCollection,
  }) : super(key: key);
  final String firestoreCollection;
  @override
  State<SongStream> createState() => _SongStreamState();
}

class _SongStreamState extends State<SongStream>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 5), vsync: this);
    animationController?.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.aspectRatio;
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(widget.firestoreCollection);
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        query.snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: snapshots,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
                color: Colors.purple,
                valueColor: animationController?.drive(
                    ColorTween(begin: Colors.blueAccent, end: Colors.red)),
              ),
            ),
          );
        }

        final songList = snapshot.data?.docs.reversed.toList();
        List<AllSongList> allSongList = [];
        for (var songs in songList!) {
          final coverImage = songs['cover image'];
          final songFile = songs['audio file'];
          final songTitle = songs['title'];
          final songComposer = songs['artist'];
          final tym = songs['uploaded date'];

          final allSongs = AllSongList(
            titles: '$songTitle',
            cover: '$coverImage',
            theFile: '$songFile',
            curIndex: allSongList,
            composer: '$songComposer',
            uploadedTime: tym.toDate(),
          );
          allSongList.add(allSongs);
        }

        return kIsWeb || Platform.isWindows
            ? LayoutGrid(
                rowGap: 2.0,
                // equivalent to mainAxisSpacing
                columnGap: auto.flex,
                // equivalent to crossAxisSpacing
                autoPlacement: AutoPlacement.rowSparse,
                gridFit: GridFit.loose,
// set some flexible track sizes based on the crossAxisCount
                columnSizes: crossAxisCount < 1
                    ? [1.0.fr, 1.0.fr, 1.0.fr, 1.0.fr, 1.0.fr, 1.0.fr]
                    : [
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr,
                        1.0.fr
                      ],
// set all the row sizes to auto (self-sizing height)
                rowSizes: const [
                  auto,
                  auto,
                  auto,
                  auto,
                  auto,
                  auto,

                  // 3.3.fr,
                  // 3.5.fr,
                ],
                children: allSongList)
            : ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: allSongList.length,
                itemBuilder: (context, int index) {
                  return Column(children: allSongList);
                },
              );
        // : ListView(
        //     physics: const ScrollPhysics(),
        //     shrinkWrap: true,
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //     semanticChildCount: 2,
        //     children: allSongList,
        //   );
      },
    );
  }
}

//       : ListView.separated(
//           physics: const ScrollPhysics(),
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             return ListTile(
//               title: Text(songList[index]["title"]!,
//                   style: const TextStyle(fontSize: 18)),
//               subtitle: const Text("titles"),
//               onTap: () => AudioManager.instance.play(index: index),
//             );
//           },
//           separatorBuilder: (BuildContext context, int index) =>
//               const Divider(),
//           itemCount: songList.length);
// });
