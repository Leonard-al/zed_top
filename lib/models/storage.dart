import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'dart:io';

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<firebase_storage.ListResult> listFiles() async {
    firebase_storage.ListResult results = await storage.ref('Songs').listAll();

    for (var ref in results.items) {
      print('Found file: $ref');
    }
    return results;
  }
}

class FirestoreStorage {
  final cloud_firestore.FirebaseFirestore storage =
      cloud_firestore.FirebaseFirestore.instance;

  Future<firebase_storage.ListResult> listFiles() async {
    firebase_storage.ListResult results = (await storage
        .collection('Songs')
        .get()) as firebase_storage.ListResult;

    for (var ref in results.items) {
      print('Found file: $ref');
    }
    return results;
  }
}

//Web file picker
//
// startFilePicker() async {
//   final uploadInput = html.FileUploadInputElement();
//   uploadInput.click();
//   uploadInput.onChange.listen((e) {
//     // read file content as dataURL
//     final files = uploadInput.files;
//     if (files != null) {
//       final file = files[0];
//       setState(() {
//         _image = file as File?;
//       });
//       // final reader = html.FileReader();
//       // reader.onLoadEnd.listen((e) {
//       //   setState(() {
//       //     _image = reader.result as File?;
//       //   });
//       // });
//       // reader.onError.listen((fileEvent) {
//       //   setState(() {
//       //     // option1Text = "Some Error occurred while reading the file";
//       //   });
//       // });
//       // reader;
//
//     }
//   });
// }

//
//
//
// Future getImageWeb() async {
//   html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
//   uploadInput.click();
//
//   uploadInput.onChange.listen((e) {
//     // read file content as dataURL
//     final files = uploadInput.files;
//     if (files?.length == 1) {
//       final file = files![0];
//       html.FileReader reader = html.FileReader();
//
//       reader.onLoadEnd.listen((e) {
//         setState(() {
//           webDisplayImage = reader.result as Uint8List?;
//           _image = File.fromRawPath(webDisplayImage!);
//         });
//       });
//
//       reader.onError.listen((fileEvent) {
//         setState(() {
//           // return Text("Some Error occurred while reading the file") ;
//         });
//       });
//
//       reader.readAsArrayBuffer(file);
//     }
//   });
// }
