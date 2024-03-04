import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcrcli/main.dart';
import 'package:pcrcli/settings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class bossPage extends StatefulWidget {
  const bossPage({super.key});

  @override
  State<bossPage> createState() => _bossPageState();
}

class _bossPageState extends State<bossPage> {
  final TextEditingController _damage = TextEditingController();
  final TextEditingController _revise = TextEditingController();
  List<int> recordsUniquenessCheck = [];
  late WebSocketChannel ws;
  late String token;
  late String url;
  // late Box<dynamic> settingsBox;
  // late AppSettings appSettings;
  late GetxSettings getxSettings;
  int counter = 0;


  @override



  Future _loadPreferences() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var settingsBox = await Hive.openBox('settingsBox');
    getxSettings = Get.find<GetxSettings>();
    // url = prefs.getString('url') ?? '';
    url = getxSettings.appSettings.value.remoteServerUrl;
    // token = prefs.getString('token') ?? '';
    token = getxSettings.appSettings.value.token;
    ws = IOWebSocketChannel.connect(
        '${url.replaceFirst('http', 'ws')}/v1/ws',
        headers: {
          HttpHeaders.cookieHeader:'pekoToken=$token'
        }
    );
    ws.stream.listen((event) {
      print(event);
      handleWebsocketMessage(event);
    });
    // sendInitData();
    await getRecords(url,token);
  }

  Future<void> getRecords(String url,String token) async {
    var homeData = Get.find<HomeData>();
    var headers = {'Cookie':'pekoToken=$token'};
    var request = http.Request('GET',Uri.parse('$url/v1/records'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var jsonString = await response.stream.bytesToString();
    var data = jsonDecode(jsonString);
    List<String> records = [];
    for(Map<String,dynamic> i in data){
      if (i['CanUndo'] != 1){
        continue;
      }
      print('i: $i');
      records.add('${i['AttackFrom']}对boss${i['AttackTo']}造成了${i['Damage']}点伤害!');
    }
    // Provider.of<AppState>(context, listen: false).initRecord(records);
    homeData.initRecord(records);

    request = http.Request('GET',Uri.parse('$url/v1/bosses'));
    request.headers.addAll(headers);
    response = await request.send();
    jsonString = await response.stream.bytesToString();
    data = jsonDecode(jsonString);
    for(Map<String,dynamic> i in data) {
      print('i: $i');
      BossInfo boss = BossInfo(
        bossID:i['ID'],
        stage:i['Stage'],
        round:i['Round'],
        valueC:i['Value'],
        valueD:i['ValueD'],
        attacking:i['WhoIsIn'],
        tree:(i['Tree'] as String).split('|'),
      );
      // Provider.of<AppState>(context, listen: false).updateBoss(boss,boss.bossID);
      homeData.updateBoss(boss, boss.bossID);
    }
  }

  void handleWebsocketMessage(dynamic message) {
    var homeData = Get.find<HomeData>();
    // todo 处理ws收到的数据，更新appState的boss信息并执行notifyListeners()
    final data = jsonDecode(message);
    if (data is List) {
      // if (data.length < 1) {
      //   print('data is empty');
      //   return;
      // }
      // Map<String,dynamic> data1 = data[0];
      // if (data1.containsKey('WhoIsIn')){
      //   for(Map<String,dynamic> i in data) {
      //     print('i: $i');
      //     BossInfo boss = BossInfo(
      //       bossID:i['ID'],
      //       stage:i['Stage'],
      //       round:i['Round'],
      //       valueC:i['Value'],
      //       valueD:i['ValueD'],
      //       attacking:i['WhoIsIn'],
      //       tree:(i['Tree'] as String).split('|'),
      //     );
      //     Provider.of<AppState>(context, listen: false).updateBoss(boss,boss.bossID);
      //   }
      // }else if (data1.containsKey('BeforeBossStage')){
      //   List<String> records = [];
      //   for(Map<String,dynamic> i in data){
      //     if (i['CanUndo'] != 1){
      //       continue;
      //     }
      //     records.add('${i['AttackFrom']}对boss${i['AttackTo']}造成了${i['Damage']}点伤害!');
      //   }
      //   Provider.of<AppState>(context, listen: false).initRecord(records);
      // }
      //

    }else if (data is Map){
      if(data.containsKey('WhoIsIn')){
        BossInfo boss = BossInfo(
          bossID:data['ID'],
          stage:data['Stage'],
          round:data['Round'],
          valueC:data['Value'],
          valueD:data['ValueD'],
          attacking:data['WhoIsIn'],
          tree:(data['Tree'] as String).split('|'),
        );
        // Provider.of<AppState>(context, listen: false).updateBoss(boss,boss.bossID);
        homeData.updateBoss(boss,boss.bossID);
      }else if (data.containsKey('BeforeBossStage')){
        if (recordsUniquenessCheck.contains(data['ID'])){
          return;
        }
        recordsUniquenessCheck.add(data['ID']);
        // Provider.of<AppState>(context, listen: false).appendRecord('${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!');
        homeData.appendRecord('${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!');
      }
    }
  }

  // ws发送一次获取boss状态的请求 需要已有ws和token
  void sendInitData(){
    Map<String,String> jsonData = {
      'type':'getBoss',
      'token':token,
    };

    String jsonString = jsonEncode(jsonData);
    ws.sink.add(jsonString);

    jsonData = {
      'type':'getRecord',
      'token':token,
    };
    jsonString = jsonEncode(jsonData);
    ws.sink.add(jsonString);
  }

  void _reloadPage(){
    setState(() {
      counter = 0;
    });
  }

  @override
  void dispose() {
    ws.sink.close();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F4F8),
        automaticallyImplyLeading: false,
        title: Text(
          'Clan Battle',
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),

      body: FutureBuilder(
        future: _loadPreferences(),
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError) {
              // 请求失败，显示错误
              print("Error: ${snapshot.error}");
            } else {
              // 请求成功，显示数据
              print("ok");
            }
          } else {
            // 请求未结束，显示loading
            return CircularProgressIndicator();
          }



          return ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 公告栏
              recordBoard(),
              // Boss 状态格子

              GestureDetector (
                  onTap: () => showDialog(

              context: context,
              builder: (BuildContext context) {
              return bossCMDDialog(
                  contentWidget: bossCMD(
                    bossID: 1,
                    token: token,
                    ws: ws,
                  )
              );
              },
              ),
                  child: bossCard(bossID: 1,bossImg: '$url/pic/1.jpg',url: url,)
              ),
              GestureDetector (
                  onTap: () => showDialog(

                    context: context,
                    builder: (BuildContext context) {
                      return bossCMDDialog(
                          contentWidget: bossCMD(
                            bossID: 2,
                            token: token,
                            ws: ws,
                          )
                      );
                    },
                  ),
                  child: bossCard(bossID: 2,bossImg: '$url/pic/2.jpg',url: url,)
              ),
              GestureDetector (
                  onTap: () => showDialog(

                    context: context,
                    builder: (BuildContext context) {
                      return bossCMDDialog(
                          contentWidget: bossCMD(
                            bossID: 3,
                            token: token,
                            ws: ws,
                          )
                      );
                    },
                  ),
                  child: bossCard(bossID: 3,bossImg: '$url/pic/3.jpg',url: url,)
              ),
              GestureDetector (
                  onTap: () => showDialog(

                    context: context,
                    builder: (BuildContext context) {
                      return bossCMDDialog(
                          contentWidget: bossCMD(
                            bossID: 4,
                            token: token,
                            ws: ws,
                          )
                      );
                    },
                  ),
                  child: bossCard(bossID: 4,bossImg: '$url/pic/4.jpg',url: url,)
              ),
              GestureDetector (
                  onTap: () => showDialog(

                    context: context,
                    builder: (BuildContext context) {
                      return bossCMDDialog(
                          contentWidget: bossCMD(
                            bossID: 5,
                            token: token,
                            ws: ws,
                          )
                      );
                    },
                  ),
                  child: bossCard(bossID: 5,bossImg: '$url/pic/5.jpg',url: url,)
              ),
              ElevatedButton(
                  onPressed: (){
                    // Provider.of<AppState>(context, listen: false).appendRecord('test');
                    var homeData = Get.find<HomeData>();
                    homeData.appendRecord('test');
                  },
                  child: Text('add record board test')
              ),
              Text('${getxSettings.appSettings.value.remoteServerUrl},${getxSettings.appSettings.value.username}${getxSettings.appSettings.value.authority},${getxSettings.appSettings.value.token}'),
            ],
          );
        }
      ),
    );
  }
}

class BossStatusTile extends StatelessWidget {
  final String bossName;

  const BossStatusTile({super.key, required this.bossName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            bossName,
            style: TextStyle(fontSize: 18.0),
          ),
          Icon(Icons.star, color: Colors.orange),
        ],
      ),
    );
  }
}

class bossCard extends StatefulWidget {
  final int bossID;
  final String bossImg;
  final String url;
  const bossCard({super.key, required this.bossID, required this.bossImg, required this.url});

  @override
  State<bossCard> createState() => _bossCardState();
}

class _bossCardState extends State<bossCard> {
  late int bossID;
  late BossInfo boss;
  late String bossImg;
  late dynamic appState;
  late String url;
  var homeData = Get.find<HomeData>();

  // 选择图片
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 裁剪图片
      File? croppedImage = await _cropImage(File(pickedFile.path));

      if (croppedImage != null) {

        // 上传图片
        await _uploadImage(croppedImage);

        // 刷新页面
        setState(() {});
      }
    }
  }

  // 裁剪图片
  Future<File?> _cropImage(File image) async {
    return await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.original,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );
  }

  // 上传图片
  Future<void> _uploadImage(File image) async {
    final uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('pic', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      // 上传成功
      print('Image uploaded successfully!');
    } else {
      // 上传失败
      print('Image upload failed with status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    bossID = widget.bossID;
    bossImg = widget.bossImg;
    url = widget.url;
  }
  @override
  Widget build(BuildContext context) {
    // appState = Provider.of<AppState>(context);
    // switch (bossID){
    //   case 1: boss = appState.boss1;break;
    //   case 2: boss = appState.boss2;break;
    //   case 3: boss = appState.boss3;break;
    //   case 4: boss = appState.boss4;break;
    //   case 5: boss = appState.boss5;break;
    // }
    return // Generated code for this Container Widget...
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x520E151B),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    bossImg,
                    width: 80,
                    height: 80,
                    // fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Obx(
                      (){
                        switch (bossID){
                          case 1: boss = homeData.boss1.value;break;
                          case 2: boss = homeData.boss2.value;break;
                          case 3: boss = homeData.boss3.value;break;
                          case 4: boss = homeData.boss4.value;break;
                          case 5: boss = homeData.boss5.value;break;
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: boss.valueC/boss.valueD,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(Colors.blue),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                              child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text('${boss.stage}阶 ${boss.round}回'),
                                        Text('${NumberFormat('#,##0').format(boss.valueC)}/${NumberFormat('#,##0').format(boss.valueD)}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text('攻击:${boss.attacking}'),
                                        Text('挂树:${boss.tree[0]==' '?0:boss.tree.length}'),
                                      ],
                                    )
                                  ]
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  }
}

class bossCMDDialog extends AlertDialog {
  bossCMDDialog({required Widget contentWidget}) : super(
    content: contentWidget,
    contentPadding: EdgeInsets.zero,
    backgroundColor: Colors.transparent,
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(20),
    //   side: BorderSide(color: Colors.blue, width: 3),
    // ),
  );
}

class bossCMD extends StatefulWidget {
  final int bossID;
  final String token;
  final WebSocketChannel ws;
  const bossCMD({super.key, required this.bossID, required this.token, required this.ws});

  @override
  State<bossCMD> createState() => _bossCMDState();
}

class _bossCMDState extends State<bossCMD> {
  final TextEditingController _damage = TextEditingController();
  final TextEditingController _revise = TextEditingController();
  late int authority;
  int round = 1;
  @override
  void initState() {
    super.initState();
    _loadStoredValue();
  }

  Future<void> _loadStoredValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authority = prefs.getInt('user_authority') ?? 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x520E151B),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(25),
        ),
        // constraints: BoxConstraints(
        //   maxWidth: 200.0, // 设置最大宽度
        //   maxHeight: 200,
        // ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 7,),
              TextField(
                keyboardType: TextInputType.number,
                controller: _damage,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: '伤害值',
                  hintText: '输入伤害值...',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF59BCF8),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF59BCF8),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                ),
                onEditingComplete: (){
                  Map<String,dynamic> jsonData = {
                    "type":"attack",
                    "attack_boss":{
                      "a_type":0,
                      "boss_id":widget.bossID,
                      "value":int.parse(_damage.text),
                      "from_name":"6"
                    },
                    "token":widget.token,
                  };
                  String jsonString = json.encode(jsonData);
                  widget.ws.sink.add(jsonString);
                  Navigator.of(context).pop();
                },
              ),
              Container(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"attack",
                          "attack_boss":{
                            "a_type":0,
                            "boss_id":widget.bossID,
                            "value":int.parse(_damage.text),
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('出刀',style: TextStyle(color: Colors.black),)),
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"attack",
                          "attack_boss":{
                            "a_type":1,
                            "boss_id":widget.bossID,
                            "value":2036854775807,
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('尾刀',style: TextStyle(color: Colors.black),)),
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"undo",
                          "undo":{
                            "boss_id":widget.bossID,
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        jsonData = {
                          "type":"getRecord",
                          "token":widget.token,
                        };
                        jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('撤回',style: TextStyle(color: Colors.black),)),
                ],
              ),
              Container(height: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"imin",
                          "im_in":{
                            "boss_id":widget.bossID,
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('我进了',style: TextStyle(color: Colors.black),)),
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"imout",
                          "im_out":{
                            "boss_id":widget.bossID,
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('我出了',style: TextStyle(color: Colors.black),)),
                ],
              ),
              Container(height: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"ontree",
                          "on_tree":{
                            "boss_id":widget.bossID,
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('挂树',style: TextStyle(color: Colors.black),)),
                  TextButton(
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: (){
                        Map<String,dynamic> jsonData = {
                          "type":"downtree",
                          "down_tree":{
                            "boss_id":widget.bossID,
                            "from_name":"6"
                          },
                          "token":widget.token,
                        };
                        String jsonString = json.encode(jsonData);
                        widget.ws.sink.add(jsonString);
                        Navigator.of(context).pop();
                      },
                      child: Text('下树',style: TextStyle(color: Colors.black),)),
                ],
              ),
              Container(height: 10,),
              Visibility(
                visible: (authority>1),
                child: TextField(
                  controller: _revise,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: '血量',
                    hintText: '输入血量...',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF59BCF8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF59BCF8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                  ),
                ),
              ),
              Visibility(visible: (authority>1),child: Container(height: 7,)),
              Visibility(
                visible: (authority>1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<int>(

                      value: round,
                      onChanged: (int? newValue) {
                        setState(() {
                          round = newValue ?? 1;
                        });
                      },
                      items: List.generate(100, (index) => index + 1)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    // SizedBox(height: 20),
                    // Text('Selected round: $round'),

                    TextButton(
                        style: ButtonStyle(
                          side: MaterialStateProperty.all<BorderSide>(
                            const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: (){
                          Map<String,dynamic> jsonData = {
                            "type":"revise",
                            "revise_boss":{
                              "boss_id":widget.bossID,
                              "value":int.parse(_revise.text),
                              "round":round
                            },
                            "token":widget.token,
                          };
                          String jsonString = json.encode(jsonData);
                          widget.ws.sink.add(jsonString);
                          Navigator.of(context).pop();
                        },
                        child: Text('调整',style: TextStyle(color: Colors.black),)),
                    TextButton(
                        style: ButtonStyle(
                          side: MaterialStateProperty.all<BorderSide>(
                            const BorderSide(color: Color(0xFF59BCF8), width: 1.2),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: (){
                          Map<String,dynamic> jsonData = {
                            "type":"revise",
                            "revise_boss":{
                              "boss_id":widget.bossID,
                              "value":int.parse(_revise.text),
                              "round":round
                            },
                            "token":widget.token,
                          };
                          String jsonString = json.encode(jsonData);
                          widget.ws.sink.add(jsonString);
                          Navigator.of(context).pop();
                        },
                        child: Text('上传图片',style: TextStyle(color: Colors.black),)),
                  ],
                ),
              ),
            ],
          ),
        )
      );
  }
}


class recordBoard extends StatefulWidget {
  const recordBoard({super.key});

  @override
  State<recordBoard> createState() => _recordBoardState();
}

class _recordBoardState extends State<recordBoard> {
  final List<String> records = [];
  final ScrollController _recordCtl = ScrollController();
  late dynamic appState;
  var homeData = Get.find<HomeData>();

  // List<Widget> _buildRecords(){
  //   return appState.records;
  // }

  // void _addRecord(String value){
  //   setState(() {
  //     records.add(value);
  //   });
  // }

  void didChangeDependencies(){
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _recordToBottom();
    });
  }

  void _recordToBottom(){
    _recordCtl.animateTo(
      _recordCtl.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }
  @override
  Widget build(BuildContext context) {
    // appState = Provider.of<AppState>(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x520E151B),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Obx(
          (){
            homeData.records.listen((List<String> newList) {
              // 在这里执行当列表发生变化时要执行的操作
              // 例如将 ListView 拉到最下面的位置
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _recordCtl.animateTo(
                  _recordCtl.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              });
            });
            return ListView.builder(
              padding: EdgeInsetsDirectional.fromSTEB(10, 30, 10, 30),
              scrollDirection: Axis.vertical,
              controller: _recordCtl,
              // itemCount: appState.records.length,
              itemCount: homeData.records.length,
              itemBuilder: (BuildContext context, int index){
                // return Center(child: Text(appState.records[index]));
                return Center(child: Text(homeData.records[index]));
              }
            );
          }
        ),
        // child: ListView(
        //   padding: EdgeInsetsDirectional.fromSTEB(10, 30, 10, 30),
        //   scrollDirection: Axis.vertical,
        //   controller: _recordCtl,
        //   children: _buildRecords(),
        // ),
      ),
    );
  }
}



