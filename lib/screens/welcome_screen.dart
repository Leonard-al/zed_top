import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zclassic/constants/constants.dart';
import 'package:zclassic/main.dart';
import 'package:zclassic/models/default_page.dart';
import 'package:zclassic/models/networking.dart';
import 'package:zclassic/models/searchBox.dart';
import 'package:zclassic/screens/artists.dart';
import 'package:zclassic/screens/upload_file.dart';
import 'package:url_launcher/url_launcher.dart';

enum Menu { itemOne, itemTwo, itemThree, itemFour }

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    Key? key,
    required this.collection,
  }) : super(key: key);
  final String collection;

  static const String id = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String dropdownValue = '';

  String _selectedMenu = '';

  //pop up menu item

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Zclassic'),
            content: const Text('Do you really want to exit?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                //return true when click on "Yes"
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialogue had returned null, then return false
  }

  openDialPad(String phoneNumber) async {
    Uri url = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      return "Can't open dial pad.";
    }
  }

  openMailApp(String email) async {
    Uri url = Uri(scheme: "mailto", path: email);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      return "Can't open mail app.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'ZClassic',
            style: kTitleTextStyle,
          ),
          flexibleSpace: Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff417D7A), Color(0xffEDE6DB)],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xff1A3C40),
          width: 300,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "images/music.jpg",
                    width: MediaQuery.of(context).size.width,
                    // height: 300,
                  ),
                  const Header(header: 'Categories'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'gospel_category');
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.church,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Gospel',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Artists(
                                collection: "Old Zed",
                              )));
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.balance,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Old Zed',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Artists(
                                collection: 'HipHop',
                              )));
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.single_bed,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'HipHop',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, UploadFileScreen.id);
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.upload_file,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Upload your Song',
                    ),
                  ),
                  const Divider(
                    color: Colors.white70,
                  ),
                  const Header(header: 'Contact'),
                  TextButton(
                    onPressed: () {
                      openDialPad('+260969753018');
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.phone,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Phone',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      openMailApp('leonardzm3@gmail.com');
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.email_outlined,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Email',
                    ),
                  ),
                  const Divider(
                    color: Colors.white70,
                  ),
                  TextButton(
                    onPressed: () {
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pushNamed(context, 'themes');
                      });
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.shield_moon_outlined,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Theme',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      null;
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.rate_review,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Rate this app',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'settings');
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.settings,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'Settings',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'about');
                    },
                    child: const Options(
                      icon: Icon(
                        Icons.info,
                        size: 34,
                        color: Colors.white,
                      ),
                      titles: 'About',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: CustomScrollView(
          // scrollDirection: Axis.vertical,
          slivers: [
            SliverPersistentHeader(
              delegate: SearchBoxDelegate(),
              pinned: true,
            ),
            const SliverToBoxAdapter(child: DefaultPage()),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  final String header;

  const Header({
    Key? key,
    required this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        header,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 30,
        ),
      ),
    );
  }
}

class Options extends StatelessWidget {
  final String titles;

  final Icon icon;
  const Options({
    Key? key,
    required this.titles,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Padding(padding: const EdgeInsets.all(8.0), child: icon),
          Flexible(
            child: Text(
              titles,
              softWrap: true,
              style: TextStyle(
                  fontSize:
                      Provider.of<FontSizeController>(context, listen: true)
                          .value,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// PopupMenuButton<Menu>(
// // Callback that sets the selected popup menu item.
// onSelected: (Menu item) {
// setState(() {
// _selectedMenu = item.name;
// });
// },
// position: PopupMenuPosition.under,
// itemBuilder: (BuildContext context) =>
// <PopupMenuEntry<Menu>>[
// const PopupMenuItem<Menu>(
// value: Menu.itemOne,
// child: Text('SDA'),
// ),
// const PopupMenuItem<Menu>(
// value: Menu.itemTwo,
// child: Text('UCZ'),
// ),
// const PopupMenuItem<Menu>(
// value: Menu.itemThree,
// child: Text('Catholic'),
// ),
// const PopupMenuItem<Menu>(
// value: Menu.itemFour,
// child: Text('Pentecostal'),
// ),
// ],
// child: const Icon(Icons.menu),
// );
