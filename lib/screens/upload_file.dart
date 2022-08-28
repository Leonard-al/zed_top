import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zclassic/constants/constants.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;
  static const String id = 'upload_file';

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _fireStore = FirebaseFirestore.instance;
  String songId = DateTime.now().toString();
  String coverImageId = DateTime.now().toString();
  bool uploading = false;
  File? _image;
  File? audio;
  Uint8List? webDisplayImage;
  String? _fileName;
  String? _churchSelected;
  String? _artist;
  String? _title;
  int? _uploadStatus;
  int? _imageUploadStatus;
  final List<String> _churchList = [
    "Catholic",
    "Gospel Mix",
    "JW",
    "Old Zed",
    "Pentecostal",
    "Praise & Worship",
    "Preachings",
    "SDA",
    "Testimonies",
    "UCZ",
    "Zed Mix"
  ];
  final snackBar = const SnackBar(
      content: Text(
    'Add a cover photo to continue',
    style: TextStyle(
      color: Colors.white70,
    ),
  ));

  final snackBar2 = const SnackBar(
      content: Text(
    'Choose a song to continue',
    style: TextStyle(
      color: Colors.white70,
    ),
  ));
  final snackBar3 = const SnackBar(
      content: Text(
    'Uploaded successfully',
    style: TextStyle(
      color: Colors.white70,
    ),
  ));

  uploadSongAndSaveItemInfo() async {
    setState(() {
      uploading = true;
    });

    String songDownloadUrl =
        await uploadAudio().whenComplete(() => uploadImageTask());
    String imageUrl = await uploadImageTask();

    saveItemInfo(songDownloadUrl, imageUrl);
  }

  Future uploadAudio() async {
    final storage = FirebaseStorage.instance.ref().child(_churchSelected!);
    final uploadTask = storage
        .child(_artist!)
        .child(_artist!.toLowerCase())
        .child('$_title, $songId')
        .putFile(audio!);
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress = 100.0 *
              (taskSnapshot.bytesTransferred.round() / taskSnapshot.totalBytes);
          // print("Upload is $progress% complete.");
          setState(() {
            _uploadStatus = progress.round();
          });

          break;
        case TaskState.paused:
          // print("Upload is paused.");
          break;
        case TaskState.canceled:
          // print("Upload was canceled");
          break;
        case TaskState.error:
          () {
            TaskState.paused;
          };
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          setState(() {});

        // Handle successful uploads on complete
        // ...
        // break;

      }
    });

    TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => uploadImageTask());

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future uploadImageTask() async {
    final storage = FirebaseStorage.instance.ref().child('Cover Images');
    final imageTask = storage.child("$_artist $_title $coverImageId").putFile(
          _image!,
        );
    imageTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final imageProgress = 100.0 *
              (taskSnapshot.bytesTransferred.round() / taskSnapshot.totalBytes);
          print("Upload is $imageProgress% complete.");
          setState(() {
            _imageUploadStatus = imageProgress.round();
          });

          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          () {
            TaskState.paused;
          };
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          setState(() {});

        // Handle successful uploads on complete
        // ...
        // break;

      }
    });

    TaskSnapshot taskSnapshot = await imageTask;
    String coverImageUrl = await taskSnapshot.ref.getDownloadURL();
    return coverImageUrl;
  }

  saveItemInfo(String downloadUrl, String coverImageUrl) {
    _fireStore.collection(_churchSelected!).add({
      'title': _title,
      'artist': _artist,
      'audio file': downloadUrl,
      'uploaded date': DateTime.now(),
      'cover image': coverImageUrl,
      "values": {
        'song': '$_title',
        'singer': '$_artist',
      }
    }).whenComplete(
      () => showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.green,
          contentTextStyle: const TextStyle(color: Colors.white),
          title: const Text(
            'Success!',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
              'Congratulations❤! your song has been uploaded successfully.'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.done, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
    // () => ScaffoldMessenger.of(context).showSnackBar(snackBar3));
    setState(() {
      uploading = false;
      _fileName = null;
      _image = null;
      audio = null;
      _controller.clear();
      _controller2.clear();
      _churchSelected = null;
      // songId = DateTime.now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.title,
            style: kTitleTextStyle,
          ),
        ),
        flexibleSpace: Container(
          height: 100,
          decoration: kMainColor,
        ),
      ),
      body: kIsWeb
          ? Row(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.attach_file_rounded),
                        Material(
                          color: Colors.black26,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          child: TextButton(
                              onPressed: () {
                                kIsWeb ? getAudioWeb() : getAudio();
                              },
                              child: const Text(
                                'Choose a song',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40,
                        child: _fileName == null
                            ? const Text('No file selected')
                            : Text(
                                '$_fileName',
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: SizedBox(
                        height: 20,
                        child: Text('Add a cover photo'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        getImage();
                      },
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.upload_sharp,
                          size: 40.0,
                        ),
                        Material(
                          color: Colors.black26,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          child: TextButton(
                              onPressed: () {
                                if (_image == null) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                                if (audio == null) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar2);
                                }
                                if (_fileName == null) {
                                  return;
                                } else if (audio != null && _image != null) {
                                  uploadSongAndSaveItemInfo();
                                }

                                // storageUploadTask();
                              },
                              child: const Text('Upload now')),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 35,
                        child: Text('about to start'),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Center(
                        child: webDisplayImage == null
                            ? Placeholder(
                                fallbackWidth:
                                    MediaQuery.of(context).size.width,
                                color: Colors.grey,
                              )
                            : Image.memory(
                                webDisplayImage!,
                              )
                        // This to be revisited as its  not working in web

                        ),
                  ),
                ),
              ],
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Center(
                    child: _image == null
                        ? const Placeholder(
                            fallbackWidth: 400,
                            color: Colors.grey,
                          )
                        : Image.file(
                            _image!,
                            fit: BoxFit.fill,
                            height: 400,
                            width: MediaQuery.of(context).size.width,
                          ),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      height: 20,
                      child: Text('Add a cover photo'),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    getImage();
                  },
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.attach_file_rounded,
                        size: 45,
                      ),
                      Material(
                        color: Colors.green,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        child: TextButton(
                            onPressed: () {
                              getAudio();
                            },
                            child: const Text(
                              'Choose a song',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: SizedBox(
                    height: 40,
                    child: _fileName == null
                        ? const Text('No file selected')
                        : Text(
                            '$_fileName',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          controller: _controller,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            return (value != null && value.contains('@'))
                                ? 'Do not include the @.'
                                : null;
                          },
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              labelText: 'Title *',
                              filled: true,
                              fillColor: Colors.black26,
                              errorStyle: TextStyle(color: Colors.red),
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: 'Enter song title'),
                          onChanged: (newText) {
                            _title = newText;
                          }),
                    ),
                    Expanded(
                      child: TextFormField(
                          controller: _controller2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            return (value != null && value.contains('@'))
                                ? 'Do not include the @.'
                                : null;
                          },
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.black26,
                              labelText: 'Singer *',
                              errorStyle: TextStyle(color: Colors.red),
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: 'Enter artist or choir name'),
                          onChanged: (newText) {
                            _artist = newText;
                          }),
                    )
                  ],
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 3),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 8.0),
                    title: const Text("Type"),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                        iconEnabledColor: Colors.white,
                        dropdownColor: const Color(0xff1A3C40),
                        autofocus: true,
                        hint: const Text("choose song type"),
                        isExpanded: false,
                        value: _churchSelected,
                        items: _churchList.map((myChurch) {
                          return DropdownMenuItem(
                            value: myChurch,
                            child: Text(myChurch),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _churchSelected = value as String?;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.upload_sharp,
                      size: 40.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                      child: Material(
                        color: Colors.green,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        child: TextButton(
                          onPressed: () {
                            if (_image == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                            if (audio == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar2);
                            } else if (audio != null &&
                                _image != null &&
                                _title != null &&
                                _artist != null &&
                                _churchSelected != null) {
                              uploadSongAndSaveItemInfo();
                            } else {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  backgroundColor: Colors.black26,
                                  contentTextStyle:
                                      const TextStyle(color: Colors.red),
                                  title: const Text(
                                    'So sorry!',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content: const Text(
                                      'Please provide all the required information'),
                                  actions: <Widget>[
                                    IconButton(
                                        icon: const Icon(Icons.close_rounded,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        })
                                  ],
                                ),
                              );
                            }

                            // storageUploadTask();
                          },
                          child: const Text(
                            'Upload now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    LinearPercentIndicator(
                      //leaner progress bar
                      width: 180, //width for progress bar
                      animation: true, //animation to show progress at first
                      animationDuration: 2000,
                      lineHeight: 45.0,
                      percent: _uploadStatus != null
                          ? _uploadStatus! / 100.toDouble() < 1
                              ? _uploadStatus! / 100.toDouble()
                              : _imageUploadStatus != null
                                  ? _imageUploadStatus! / 100.toDouble()
                                  : 0.0
                          : 0.0, // 30/100 = 0.3
                      center: Text("$_imageUploadStatus"),
                      barRadius: const Radius.circular(10),
                      //make round cap at start and end both
                      progressColor:
                          Colors.green, //percentage progress bar color
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: SizedBox(
                //     child: uploadSongAndSaveItemInfo()
                //         ? uploadProgress()
                //         : Text('about to start'),
                //     height: 35,
                //   ),
                // ),
              ],
            ),
    );
  }

  Future getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
  }

  Future getAudio() async {
    final pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    setState(() {
      final file = pickedFile?.files;
      _fileName = file?.first.name;
    });
    setState(() {
      final audioFile = pickedFile?.paths.first;
      audio = File(audioFile!);
    });
  }

  Future getAudioWeb() async {
    final pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    setState(() {
      Uint8List? pickedFileWeb = pickedFile?.files.single.bytes;
      String? filename = pickedFile?.files.single.name;

      _fileName = filename;
      final audioFile = pickedFileWeb?.offsetInBytes.toString();
      audio = File(audioFile!);
    });
    setState(() {});
  }

  uploadProgress() {
    LinearPercentIndicator(
      //leaner progress bar
      width: 210, //width for progress bar
      animation: true, //animation to show progress at first
      animationDuration: 2000,
      lineHeight: 30.0,
      percent: 0.0, // 30/100 = 0.3
      center: Text("$_uploadStatus"),
      barRadius: const Radius.circular(10),
      //make round cap at start and end both
      progressColor: Colors.redAccent, //percentage progress bar color
      backgroundColor: Colors.orange[100],
    );
  }
}
