
import 'package:flutter/material.dart';
import 'package:fucorona/GraphView.dart';
import 'package:fucorona/MapView.dart';
import 'TableLayout.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MainPersistentTabBar(),
    );
  }
}

class MainPersistentTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('qrip'),
          centerTitle: true,
          backgroundColor: Colors.black87,
        ),
        bottomNavigationBar: menu(),
        body: TabBarView(
          children: [
            MapView(),
            GraphView(),
            TableLayout(),
          ],
        ),
      ),
    );
  }
}

Widget menu() {
  return Container(
    color: Colors.black87,
    child: TabBar(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelPadding: EdgeInsets.symmetric(horizontal: 50),
      indicatorColor: Colors.blue,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: [
        Tab(
          text: "Map",
          icon: Icon(Icons.map),
        ),
        Tab(
          text: "Graph",
          icon: Icon(Icons.assessment),
        ),
        Tab(
          text: "Table",
          icon: Icon(Icons.grain),
        ),
      ],
    ),
  );
}