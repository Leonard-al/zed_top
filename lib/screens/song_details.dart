import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zclassic/main.dart';
import 'package:timeago/timeago.dart' as timeago;

class SongDetails extends StatelessWidget {
  static const String id = 'Song details';
  const SongDetails({
    Key? key,
    required this.image,
    required this.audio,
    required this.title,
    required this.artist,
    required this.date,
  }) : super(key: key);
  final String image;
  final String audio;
  final String title;
  final String artist;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    Stream<QuerySnapshot>? streamQuery = db
        .collection('UCZ')
        .where('values.singer', isGreaterThanOrEqualTo: artist)
        .limit(15)
        .snapshots();
    String mainContainer = '';

    final loadedTime = date;
    final now = DateTime.now();
    final difference = now.difference(loadedTime);
    mainContainer = timeago.format(now.subtract(difference));

    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: [
            SizedBox(
              height: 400,
              width: 500,
              child: Image.network(
                image,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 6.0, top: 8.0, bottom: 2.0, right: 8.0),
              child: Text(
                "Download $artist - $title",
                softWrap: true,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  decorationThickness: 20.0,
                  fontSize:
                      Provider.of<FontSizeController>(context, listen: true)
                              .value! +
                          15.0,
                ),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Text('Uploaded $mainContainer')),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: TextButton(
                          onPressed: () {
                            null;
                          },
                          child: const Text('Download',
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: TextButton(
                          onPressed: () {
                            null;
                          },
                          child: const Text('Play',
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: streamQuery,
              builder: (context, snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasData
                        ? SizedBox(
                            height: 400,
                            child: ListView.builder(
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data?.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot data =
                                    snapshot.data!.docs[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => SongDetails(
                                                  image: data['cover image'],
                                                  audio: data['audio file'],
                                                  title: data['title'],
                                                  artist: data['artist'],
                                                  date: data['uploaded date']
                                                      .toDate(),
                                                )));
                                  },
                                  child: GridView.count(
                                      primary: false,
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      shrinkWrap: true,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.teal[300],
                                          ),
                                          padding: const EdgeInsets.only(
                                              left: 2,
                                              right: 2,
                                              top: 16,
                                              bottom: 2),
                                          margin:
                                              const EdgeInsets.only(bottom: 2),
                                          child: Column(
                                            children: [
                                              Flexible(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                  child: Image.network(
                                                      data['cover image']),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                data['title'],
                                              ),
                                              Text(
                                                data['artist'],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                );
                              },
                            ),
                          )
                        : const Center(child: Text('No internet connection'));
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.text,
    required this.pressed,
  }) : super(key: key);
  final String text;
  final Function pressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(5),
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: TextButton(
            onPressed: () {
              pressed;
            },
            child: Text(text)),
      ),
    );
  }
}
