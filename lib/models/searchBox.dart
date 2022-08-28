import 'package:flutter/material.dart';
import 'package:zclassic/constants/constants.dart';
import 'package:zclassic/models/search.dart';

class SearchBoxDelegate extends SliverPersistentHeaderDelegate {
  // SearchBoxDelegate({required this.path})
  //  String path;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, 'search_screen');
          // Route route =
          //     MaterialPageRoute(builder: (context) => const SearchSong());
          // Navigator.pushReplacement(context, route);
        },
        child: Container(
          decoration: kMainColor,
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: Container(
                height: 78.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.search,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'I\'m looking for...',
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  // TODO: implement build

  @override
  // TODO: implement maxExtent
  double get maxExtent => 80;

  @override
  // TODO: implement minExtent
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
