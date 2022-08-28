import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zclassic/models/fetching_file.dart';
import 'package:zclassic/screens/settings.dart';
import 'package:zclassic/models/search.dart';
import 'package:zclassic/screens/gospel_category.dart';
import 'package:zclassic/screens/upload_file.dart';
import 'package:zclassic/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zclassic/screens/about.dart';
import 'package:zclassic/screens/themes_screen.dart';
import 'firebase_options.dart';

const debug = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterDownloader.initialize(
    debug: debug,
    ignoreSsl: true,
  );
  await FlutterDownloader.registerCallback(AllSongList.downloadCallback);
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? true;
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FontSizeController>(
              create: (_) => FontSizeController()),
          FutureProvider<double?>.value(
            value: getFontSize(),
            initialData: 12.0,
            updateShouldNotify: (_, __) => true,
          ),
        ],
        child: const Zclassic(),
      ),
    );
  });
}

class ThemeNotifier {}

class FontSizeController with ChangeNotifier {
  double _value = 12.0;

  double? get value => _value;

  void increment(double number) {
    _value = number;
    notifyListeners();
  }

  void decrement(double number) {
    _value = number;
    notifyListeners();
  }
}

class Zclassic extends StatelessWidget {
  const Zclassic({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        hintColor: Colors.grey,
        cardColor: const Color(0xff1A3C40),
        scaffoldBackgroundColor: const Color(0xff1A3C40),
        textTheme: TextTheme(
          subtitle1: const TextStyle(color: Colors.white),
          subtitle2: const TextStyle(color: Colors.white),
          headline3: const TextStyle(color: Colors.white),
          bodyText2: TextStyle(
            color: Colors.white,
            fontSize: Provider.of<double?>(context, listen: true),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      title: 'Zed Music',
      home: const SplashScreen(),
      routes: {
        WelcomeScreen.id: (context) =>
            const WelcomeScreen(collection: 'Zed Mix'),
        SearchSong.id: (context) => const SearchSong(
              path: '',
            ),
        GospelCategory.id: (context) => const GospelCategory(),
        AppSettings.id: (context) => const AppSettings(),
        AboutScreen.id: (context) => const AboutScreen(),
        CustomThemeScreen.id: (context) => const CustomThemeScreen(),
        UploadFileScreen.id: (context) => const UploadFileScreen(
              title: 'Upload your song',
            ),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  displaySplash() {
    Timer(const Duration(seconds: 3), () async {
      const String defaultPage = "Zed Mix";
      Route route = MaterialPageRoute(
          builder: (_) => const WelcomeScreen(
                collection: defaultPage,
              ));
      Navigator.pushReplacement(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Image(
        image: AssetImage('images/image1.jpg'),
        alignment: Alignment.center,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.fill,
      ),
    );
  }
}

// initialRoute: WelcomeScreen.id,
// routes: {
// WelcomeScreen.id: (context) => const WelcomeScreen(),
// UploadFileScreen.id: (context) => const UploadFileScreen(
// title: 'Upload your song',
// ),
// },

//
// Font Size
// Provider.of<FontSizeController>(context, listen: true)
// .value
//     .toDouble(),
