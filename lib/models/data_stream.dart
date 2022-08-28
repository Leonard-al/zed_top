// FutureBuilder(
// future: Storage().listFiles(),
// builder: (BuildContext context,
//     AsyncSnapshot<firebase_storage.ListResult> snapshot) {
// if (snapshot.connectionState == ConnectionState.done &&
// snapshot.hasData) {
// return Container(
// color: Colors.grey,
// height: MediaQuery.of(context).size.height,
// child: ListView.builder(
// scrollDirection: Axis.horizontal,
// shrinkWrap: true,
// itemCount: snapshot.data!.items.length,
// itemBuilder: (BuildContext context, int index) {
// return ElevatedButton(
// onPressed: () {},
// child: Text(snapshot.data!.items[index].name));
// }),
// );
// }
// if (snapshot.connectionState == ConnectionState.waiting &&
// !snapshot.hasData) {
// return const CircularProgressIndicator();
// }
// return Container();
// })
