import 'package:flutter/material.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';
import 'network.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // ThemeData
      home: const MyHomePage(title: 'Últimas Noticias'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<RssFeed>? future;
  @override
  void initState() {
    super.initState();
    future = getNews();
    getNews().then((rss) {
      print(rss.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            elevation: 0.0,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                ) // TextStyle
                ,
              ) //Text
              ,
            ) //Padding
            ,
            actions: const <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 32.0),
                child: InkWell(
                  child: Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                ),
              )
            ]),
        body: _body());
  }

  Widget _body() {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ListView.builder(
                itemCount: snapshot.data.items.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(snapshot.data.description),
                    );
                  }
                  if (index == 1) {
                    return _bigItem();
                  }
                  return _item(snapshot.data.items[index - 2]);
                }),
          );
        });
  }

  Widget _bigItem() {
    var screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: (screenWidth - 64.0) * 3.0 / 5.0,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: NetworkImage(
                  'https://www.elcomercio.com/wp-content/uploads/2021/06/logo-el-comercio.jpg'),
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white),
        )
      ],
    );
  }

  Widget _item(RssItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 9.0),
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: IntrinsicHeight(
          child: Row(children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.categories!.first.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(item.title!),
                  Text(item.dc!.creator!),
                ],
              ),
            ),
            Container(
              width: 120.0,
              height: 120.0,
              child: Image(
                image: NetworkImage(item.enclosure!.url!),
                fit: BoxFit.cover,
              ),
            )
          ]),
        ),
      ),
    );
  }
}
