import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zclassic/models/networking.dart';
import 'package:zclassic/models/searchBox.dart';

class Artists extends StatelessWidget {
  const Artists({
    Key? key,
    required this.collection,
  }) : super(key: key);
  final String collection;
  static const String id = 'artists';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          // scrollDirection: Axis.vertical,
          slivers: [
            SliverPersistentHeader(
              delegate: SearchBoxDelegate(),
              pinned: true,
            ),
            SliverToBoxAdapter(
                child: SongStream(
              firestoreCollection: collection,
            )),
          ],
        ),
      ),
    );
  }
}
