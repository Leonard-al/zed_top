import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';
import 'package:zclassic/constants/constants.dart';
import 'package:zclassic/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({
    Key? key,
  }) : super(key: key);

  static const String id = 'settings';

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

void addDefaultValueToSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('fontsize', 12.0);
}

Future<double?> getFontSize() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  double? value = prefs.getDouble("fontsize");
  return value;
}

Future<bool> updateFontSize(double updatedSize) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  return await sharedPreferences.setDouble('fontsize', updatedSize);
}

class _AppSettingsState extends State<AppSettings> {
  SharedPreferences? prefs;
  bool _playOption = false;
  double? _changeFontSize;
  final List<double> _fontSizeList = [
    6.0,
    8.0,
    10.0,
    12.0,
    14.0,
    16.0,
    18.0,
    20.0,
    25.0,
    30.0,
    35.0
  ];

  Dialog fontSizeDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetAnimationDuration: const Duration(seconds: 2),
      insetAnimationCurve: Curves.bounceIn,
      insetPadding: const EdgeInsets.all(2.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: ChangeNotifierProvider(
            create: (context) => FontSizeController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: IconButton(
                    onPressed: () {
                      // Provider.of<FontSizeController>(context, listen: false)
                      //     .increment(4);
                    },
                    icon: const Icon(
                      Icons.exposure_plus_2_sharp,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<FontSizeController>(context, listen: false)
                          .decrement(_changeFontSize!);
                    },
                    child: const Icon(
                      Icons.exposure_minus_1_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Retrieving font size
      getFontSize().then((value) => setState(() {
            _changeFontSize = value!.toDouble();
          }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double? fontSize = Provider.of<double?>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            height: 100,
            decoration: kMainColor,
          ),
          centerTitle: true,
          title: const Text(
            'Settings',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                inactiveTrackColor: Colors.grey,
                contentPadding: const EdgeInsets.all(8.0),
                title: Text(
                  'Auto Play Next',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(left: 7.0),
                  child: Text(
                    'Play the next song automatically',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                value: _playOption,
                onChanged: (bool value) {
                  setState(() {
                    _playOption = value;

                    //  Add provider function here
                  });
                },
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 3),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 8.0),
                  title: const Text("Font Size"),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      iconEnabledColor: Colors.white,
                      dropdownColor: const Color(0xff1A3C40),
                      autofocus: true,
                      hint: const Text("Select Font Size"),
                      isExpanded: false,
                      value: _changeFontSize,
                      items: _fontSizeList.map((myFontSize) {
                        return DropdownMenuItem(
                          value: myFontSize,
                          child: Text(myFontSize.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _changeFontSize = value as double;
                          updateFontSize(value);
                          Provider.of<FontSizeController>(context,
                                  listen: false)
                              .decrement(_changeFontSize!);
                        });
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Restart the app to apply the font size  changes to the entire app',
                    style: TextStyle(fontSize: _changeFontSize),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await showDialog(
                      context: context, builder: (_) => fontSizeDialog());
                },
                child: const TittleText(title: 'Font Size'),
              ),
              TextButton(
                  onPressed: () async {},
                  child: const TittleText(title: 'Font Style')),
            ],
          ),
        ),
      ),
    );
  }
}

class TittleText extends StatelessWidget {
  final String title;

  const TittleText({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
        title,
        style: TextStyle(
            fontSize: Provider.of<FontSizeController>(context, listen: true)
                .value as double,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
