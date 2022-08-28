import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zclassic/constants/constants.dart';
import 'package:zclassic/models/networking.dart';
import 'package:zclassic/screens/song_details.dart';
import 'package:zclassic/screens/welcome_screen.dart';

class SearchSong extends StatefulWidget {
  const SearchSong({
    Key? key,
    required this.path,
  }) : super(key: key);
  final String path;

  static const String id = 'search_screen';

  @override
  State<SearchSong> createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchSong> {
  Stream<QuerySnapshot>? streamQuery;
  Future<QuerySnapshot>? docList;
  final messageTextController = TextEditingController();
  bool _isVisible = false;
  String searchKey = "";
  final db = FirebaseFirestore.instance;

  void showIcon() {
    setState(() {
      if (searchKey.isEmpty) {
        _isVisible = false;
      } else {
        _isVisible = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff1A3C40),
        appBar: PreferredSize(
            preferredSize: const Size(60.0, 75.0), child: searchWidget()),
        body: StreamBuilder<QuerySnapshot>(
          stream: streamQuery,
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? const Center(child: CircularProgressIndicator())
                : snapshot.hasData
                    ? ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot data = snapshot.data!.docs[index];
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SongDetails(
                                        image: data['cover image'],
                                        audio: data['audio file'],
                                        title: data['title'],
                                        artist: data['artist'],
                                        date: data['uploaded date'].toDate(),
                                      )));
                            },
                            child: Card(
                              color: const Color(0xff1D5C63),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 10.0, 0.5, 10.0),
                                child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                        data['cover image'],
                                      ),
                                      backgroundColor: Colors.black26,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: ListTile(
                                        textColor: Colors.white,
                                        title: Text(
                                          data['title'],
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text(
                                          data['artist'],
                                          softWrap: true,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('Nothing matches your search'));
          },
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 100,
      decoration: kMainColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              IconButton(
                hoverColor: Colors.green,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.green,
                ),
                onPressed: () {
                  Navigator.popAndPushNamed(context, WelcomeScreen.id);
                },
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: messageTextController,
                    cursorColor: Colors.teal,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        searchKey = value;
                        streamQuery = db
                            .collection(widget.path)
                            .where('values.singer',
                                isLessThanOrEqualTo: searchKey)
                            .limit(100)
                            .snapshots();
                      });

                      showIcon();
                    },
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Search',
                        fillColor: Colors.green,
                        focusColor: Colors.red),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    messageTextController.clear();
                    _isVisible = false;
                  });
                },
                icon: Visibility(
                  visible: _isVisible,
                  child: const Icon(
                    Icons.cancel_sharp,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Material(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  color: const Color(0xff417D7A),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          streamQuery = db
                              .collection("UCZ")
                              .where('values.song', arrayContains: [searchKey])
                              .limit(50)
                              .snapshots();
                        });
                      },
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
