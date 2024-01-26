
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pcrcli/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'boss.dart';
import 'home.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int routeNum = 0;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? url = prefs.getString('url');
  if (!(url == null || url == '')){
    routeNum = 1;
  }
  String? token = prefs.getString('token');
  if (!(token == null || token == '')){
    routeNum = 2;
  }
  runApp(MyApp(routeNum));
}

class BossInfo {
  int bossID = 0;
  int stage = 0;
  int round = 0;
  int valueC = 0;
  int valueD = 0;
  List<String> tree = [' ',];
  String attacking = ' ';
  BossInfo({
    this.bossID = 0,
    this.stage = 0,
    this.round = 0,
    this.valueC = 0,
    this.valueD = 0,
    this.attacking = '',
    this.tree = const [''],
  });
}

class AppState extends ChangeNotifier {
  List<String> records = ['1','2'];
  BossInfo boss1 = BossInfo(bossID: 1);
  BossInfo boss2 = BossInfo(bossID: 2);
  BossInfo boss3 = BossInfo(bossID: 3);
  BossInfo boss4 = BossInfo(bossID: 4);
  BossInfo boss5 = BossInfo(bossID: 5);
  bool updateBoss(BossInfo bossInfo,int bossID) {
    switch (bossID){
      case 1:boss1 = bossInfo;break;
      case 2:boss2 = bossInfo;break;
      case 3:boss3 = bossInfo;break;
      case 4:boss4 = bossInfo;break;
      case 5:boss5 = bossInfo;break;
      default:return false;
    }
    notifyListeners();
    return true;
  }
  void appendRecord(String data){
    records.add(data);
    notifyListeners();
  }
  void initRecord(List<String> data){
    records = data;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final int routeNum;
  const MyApp(this.routeNum, {super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    StatefulWidget home = const StartUp();
    switch(routeNum){
      case 0:
        break;
      case 1:
        home = const login();
        break;
      case 2:
        home = const bossPage();
        break;
      default:
        break;
    }
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: home,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
