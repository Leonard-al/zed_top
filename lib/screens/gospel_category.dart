import 'package:flutter/material.dart';
import 'package:zclassic/screens/artists.dart';

class GospelCategory extends StatelessWidget {
  const GospelCategory({Key? key}) : super(key: key);

  static const String id = 'gospel_category';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: const <Widget>[
              MyGrid(type: 'png', image: 'sda', text: 'SDA'),
              MyGrid(type: 'png', image: 'ucz', text: 'UCZ'),
              MyGrid(text: 'Catholic', type: 'png', image: 'catholic'),
              MyGrid(text: 'Pentecostal', image: 'pente', type: 'jpg'),
              MyGrid(type: 'jpg', image: 'jw', text: 'JW'),
              MyGrid(image: 'praise', text: 'Praise & Worship', type: 'jpg'),
              MyGrid(text: 'Mixed', image: 'mixed', type: 'png'),
              MyGrid(image: 'Bible', type: 'png', text: 'Preachings'),
              MyGrid(image: 'testimonies', type: 'jpg', text: 'Testimonies'),
            ],
          ),
        ),
      ),
    );
  }
}

class MyGrid extends StatelessWidget {
  const MyGrid({
    Key? key,
    required this.image,
    required this.text,
    required this.type,
  }) : super(key: key);
  final String image;
  final String text;
  final String type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Artists(collection: text)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Colors.teal[300],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Image(
                  image: AssetImage(
                    'images/$image.$type',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              text,
              softWrap: true,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
