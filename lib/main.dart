
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcrcli/global.dart';
import 'package:pcrcli/register.dart';
import 'package:pcrcli/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;

import 'boss.dart';
import 'home.dart';
import 'startup.dart';
import 'login.dart';
import 'my_page.dart';

part 'init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await hiveInit();
  var routeNum = await initState();
  await wsInit();
  runApp(MyApp(routeNum));
}

Future<int> initState() async {
  Get.put(HomeData());
  Get.put(GetxSettings());
  Get.put(WSC());

  GetxSettings getxSettings = Get.find<GetxSettings>();
  var settingsBox = Hive.box('settingsBox');
  getxSettings.appSettings.value = settingsBox.get('settings');


  int routeNum = 0;
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String url = getxSettings.appSettings.value.remoteServerUrl;
  bool isUrl = debugMode?false:getxSettings.appSettings.value.isUrlConfirmed;
  bool isLogin = debugMode?false:getxSettings.appSettings.value.isLoggedIn;
  if (!isUrl){
    routeNum = 0;
  }else{
    routeNum = 1;
  }
  String token = getxSettings.appSettings.value.token;
  // token = debugMode? '' : token;
  if (isLogin){
    routeNum = 2;
  }
  return routeNum;
}

Future<void> hiveInit() async {
  var appDocumentDirectory = await getApplicationDocumentsDirectory();
  String path = appDocumentDirectory.path;
  Hive
    ..init(path)
    ..registerAdapter(AppSettingsAdapter());
  var box = await Hive.openBox('settingsBox');
  if (box.isEmpty){
    var settings = AppSettings();
    settings.initIndex();
    await box.put('settings', settings);
  }
  // AppSettings appSettings = box.get('settings');
  // print(appSettings.getIndex);
}

Future<void> wsInit() async {
  WSC wsc = Get.find<WSC>();
  try{
    await wsc.connect();
  }catch(e){
    print(e);
  }
}

class HomeData extends GetxController {
  var records = <Record>[].obs;
  List<BossInfo> bosses = [
    BossInfo(),
    BossInfo(),
    BossInfo(),
    BossInfo(),
    BossInfo(),
  ];
  Map<String,User> users = {};
    // BossInfo(bossID: 1).obs,
    // BossInfo(bossID: 2).obs,
    // BossInfo(bossID: 3).obs,
    // BossInfo(bossID: 4).obs,
    // BossInfo(bossID: 5).obs,


  HomeData(){
    for(int i=0;i<5;i++){
      // BossInfo boss = BossInfo();
      bosses[i].bossID.value = i+1;
      // bosses[i] = boss;
    }
  }
  // var boss1 = BossInfo(bossID: 1).obs;
  // var boss2 = BossInfo(bossID: 2).obs;
  // var boss3 = BossInfo(bossID: 3).obs;
  // var boss4 = BossInfo(bossID: 4).obs;
  // var boss5 = BossInfo(bossID: 5).obs;

  void updateBoss(BossInfo bossInfo,int bossID) {
    // switch (bossID){
    //   case 1:boss1.value = bossInfo;break;
    //   case 2:boss2.value = bossInfo;break;
    //   case 3:boss3.value = bossInfo;break;
    //   case 4:boss4.value = bossInfo;break;
    //   case 5:boss5.value = bossInfo;break;
    //   default:return false;
    // }
    if(bosses[bossID - 1].stage.value != bossInfo.stage.value){
      bosses[bossID - 1].stage.value = bossInfo.stage.value;
    }
    if(bosses[bossID - 1].round.value != bossInfo.round.value){
      bosses[bossID - 1].round.value = bossInfo.round.value;
    }
    if(bosses[bossID - 1].valueC.value != bossInfo.valueC.value){
      bosses[bossID - 1].valueC.value = bossInfo.valueC.value;
    }
    if(bosses[bossID - 1].valueD.value != bossInfo.valueD.value){
      bosses[bossID - 1].valueD.value = bossInfo.valueD.value;
    }
    if(bosses[bossID - 1].attacking.value != bossInfo.attacking.value){
      bosses[bossID - 1].stage.value = bossInfo.stage.value;
    }
    if(bosses[bossID - 1].tree != bossInfo.tree){
      bosses[bossID - 1].tree = RxList<String>.from(bossInfo.tree);
    }
    if(bosses[bossID - 1].picETag.value != bossInfo.picETag.value){
      bosses[bossID - 1].picETag.value = bossInfo.picETag.value;
    }
    // bosses[bossID - 1] = bossInfo;
    // return true;
  }

  void appendRecord(Record data){
    records.add(data);
  }
  void initRecord(List<Record> data){
    records.value = data;
  }
}

class User {
  RxString name = ''.obs;
  RxString picEtag = ''.obs;
  RxString picEtag128 = ''.obs;
  RxInt permission = 0.obs;
}

class Record {
  Uint8List pic = Uint8List(0);
  String text = '';
}

class BossInfo {
  RxInt bossID = 0.obs;
  RxInt stage = 0.obs;
  RxInt round = 0.obs;
  RxInt valueC = 0.obs;
  RxInt valueD = 0.obs;
  RxList<String> tree = [' ',].obs;
  RxString attacking = ' '.obs;
  RxString picETag = ''.obs;
  // BossInfo({
  //   this.bossID = 0.obs,
  //   this.stage = 0.obs,
  //   this.round = 0.obs,
  //   this.valueC = 0.obs,
  //   this.valueD = 0.obs,
  //   this.attacking,
  //   this.tree,
  //   this.picETag,
  // });
}

// class AppState extends ChangeNotifier {
//   List<String> records = [];
//   BossInfo boss1 = BossInfo(bossID: 1);
//   BossInfo boss2 = BossInfo(bossID: 2);
//   BossInfo boss3 = BossInfo(bossID: 3);
//   BossInfo boss4 = BossInfo(bossID: 4);
//   BossInfo boss5 = BossInfo(bossID: 5);
//   bool updateBoss(BossInfo bossInfo,int bossID) {
//     switch (bossID){
//       case 1:boss1 = bossInfo;break;
//       case 2:boss2 = bossInfo;break;
//       case 3:boss3 = bossInfo;break;
//       case 4:boss4 = bossInfo;break;
//       case 5:boss5 = bossInfo;break;
//       default:return false;
//     }
//     notifyListeners();
//     return true;
//   }
//   void appendRecord(String data){
//     records.add(data);
//     notifyListeners();
//   }
//   void initRecord(List<String> data){
//     records = data;
//     notifyListeners();
//   }
// }

class MyApp extends StatelessWidget {
  final int routeNum;
  const MyApp(this.routeNum, {super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // StatefulWidget home = const StartUp();
    String homePage = '/startup';
    switch(routeNum){
      case 0:
        break;
      case 1:
        // home = const login();
        homePage = '/login';
        break;
      case 2:
        // home = const bossPage();
        homePage = '/home';
        break;
      default:
        break;
    }
    // return ChangeNotifierProvider(
    //   create: (context) => AppState(),
    //   child: MaterialApp(
    return MaterialApp(
        title: 'Flutter Demo',
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],

        // theme: ThemeData(
        //   // This is the theme of your application.
        //   //
        //   // TRY THIS: Try running your application with "flutter run". You'll see
        //   // the application has a blue toolbar. Then, without quitting the app,
        //   // try changing the seedColor in the colorScheme below to Colors.green
        //   // and then invoke "hot reload" (save your changes or press the "hot
        //   // reload" button in a Flutter-supported IDE, or press "r" if you used
        //   // the command line to start the app).
        //   //
        //   // Notice that the counter didn't reset back to zero; the application
        //   // state is not lost during the reload. To reset the state, use hot
        //   // restart instead.
        //   //
        //   // This works for code too, not just values: Most code changes can be
        //   // tested with just a hot reload.
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //   useMaterial3: true,
        // ),
        routes: {
          '/startup': (context) => StartUp(),
          '/login': (context) => login(),
          '/register': (context) => register(),
          // '/home': (context) => bossPage(),
          '/home': (context) => Home(),
          '/my_page': (context) => MyPage(),
        },
        initialRoute: homePage,
        // home: home,
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
