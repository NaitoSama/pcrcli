part of 'main.dart';

class WSC extends GetxController{
  bool isConnected = false;
  late WebSocketChannel ws;
  List<int> recordsUniquenessCheck = [];
  late String url;
  late String token;
  bool dataInitComplete = false;


  Future<void> connect() async {
    GetxSettings getxSettings = Get.find<GetxSettings>();
    url = getxSettings.appSettings.value.remoteServerUrl;
    token = getxSettings.appSettings.value.token;
    if(!getxSettings.appSettings.value.isLoggedIn||!getxSettings.appSettings.value.isUrlConfirmed) {
        throw Exception('url or token is not initialized!');
      }
    ws = IOWebSocketChannel.connect(
        '${url.replaceFirst('http', 'ws')}/v1/ws',
        headers: {
          HttpHeaders.cookieHeader:'pekoToken=$token'
        }
    );

    ws.stream.listen((event) {
      // print(event);
      _handleWebsocketMessage(event);
    });
    isConnected = true;
    await _getRecords();
  }

  void _handleWebsocketMessage(dynamic message) async {
    var getx = Get.find<GetxSettings>();
    var homeData = Get.find<HomeData>();
    final data = jsonDecode(message);
    if (data is Map){
      if(data.containsKey('WhoIsIn')){
        int bossID = data['ID'];
        BossInfo boss = homeData.bosses[bossID - 1];
        boss.stage.value = data['Stage'];
        boss.round.value = data['Round'];
        boss.valueC.value = data['Value'];
        boss.valueD.value = data['ValueD'];
        boss.attacking.value = data['WhoIsIn'];
        boss.tree.value = (data['Tree'] as String).split('|');
        boss.picETag.value = data['PicETag'];
      }else if (data.containsKey('BeforeBossStage')){
        if (recordsUniquenessCheck.contains(data['ID'])){
          return;
        }
        recordsUniquenessCheck.add(data['ID']);
        // Provider.of<AppState>(context, listen: false).appendRecord('${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!');
        String? picETag = homeData.users[data['AttackFrom']]?.picEtag.value;
        if (!getx.appSettings.value.eTagToPic.containsKey(picETag) && picETag != ''){
          final response = await http.get(Uri.parse('$url/pic/$picETag.jpg'));
          if (response.statusCode == 200) {
            getx.appSettings.value.eTagToPic[picETag!] = response.bodyBytes;
            getx.updateSettings(getx.appSettings.value);
          } else {
            throw Exception('Failed to fetch image: ${response.statusCode}');
          }
        }

        Record record = Record();
        record.pic = picETag!;
        record.text = '${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!';
        record.id = data['ID'];
        record.createTime = data['CreatedAt'];
        record.attackFrom = data['AttackFrom'];
        record.attackTo = data['AttackTo'];
        record.canUndo = data['CanUndo'];
        homeData.appendRecord(record);
      }
    }
  }

  Future<void> _getRecords() async {

    // init record
    List<String> users = [];
    var homeData = Get.find<HomeData>();
    var getx = Get.find<GetxSettings>();
    var headers = {'Cookie':'pekoToken=$token'};
    var request = http.Request('GET',Uri.parse('$url/v1/records'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var jsonString = await response.stream.bytesToString();
    var data = jsonDecode(jsonString);
    List<Record> records = [];

    // init users
    users.add(getx.appSettings.value.username);
    for(Map<String,dynamic> i in data){
      if (i['CanUndo'] != 1){
        continue;
      }
      String username = i['AttackFrom'];
      if (!users.contains(username)){
        users.add(username);
      }
    }
    String query = '';
    for (int index=0;index<users.length;index++){
      query += 'users=${users[index]}';
      if (index != users.length-1) query += '&';
    }
    var request2 = http.Request('GET',Uri.parse('$url/v1/users?$query'));
    request2.headers.addAll(headers);
    var response2 = await request2.send();
    var jsonString2 = await response2.stream.bytesToString();
    var data2 = jsonDecode(jsonString2);
    for(Map<String,dynamic> i in data2){
      User user = User();
      user.name.value = i['Name'];
      user.picEtag.value = i['PicETag'];
      user.picEtag128.value = i['Pic16ETag'];
      user.permission.value = i['Permission'];
      homeData.users[i['Name']] = user;
    }


    // init records
    for(Map<String,dynamic> i in data){
      if (i['CanUndo'] != 1){
        continue;
      }
      String? picETag = homeData.users[i['AttackFrom']]?.picEtag.value;
      if (!getx.appSettings.value.eTagToPic.containsKey(picETag) && picETag != ''){
        final response = await http.get(Uri.parse('$url/pic/$picETag.jpg'));
        if (response.statusCode == 200) {
          getx.appSettings.value.eTagToPic[picETag!] = response.bodyBytes;
          getx.updateSettings(getx.appSettings.value);
        } else {
          throw Exception('Failed to fetch image: ${response.statusCode}');
        }
      }

      Record record = Record();
      record.pic = picETag!;
      record.text = '${i['AttackFrom']}对boss${i['AttackTo']}造成了${i['Damage']}点伤害!';
      record.id = i['ID'];
      record.createTime = i['CreatedAt'];
      record.attackFrom = i['AttackFrom'];
      record.attackTo = i['AttackTo'];
      record.canUndo = i['CanUndo'];
      records.add(record);

    }
    // Provider.of<AppState>(context, listen: false).initRecord(records);
    homeData.initRecord(records);

    request = http.Request('GET',Uri.parse('$url/v1/bosses'));
    request.headers.addAll(headers);
    response = await request.send();
    jsonString = await response.stream.bytesToString();
    data = jsonDecode(jsonString);
    GetxSettings getxSettings = Get.find<GetxSettings>();
    int j = 0;
    for(Map<String,dynamic> i in data) {
      print('i: $i');
      int bossID = i['ID'];
      BossInfo boss = homeData.bosses[bossID - 1];
      boss.stage.value = i['Stage'];
      boss.round.value = i['Round'];
      boss.valueC.value = i['Value'];
      boss.valueD.value = i['ValueD'];
      boss.attacking.value = i['WhoIsIn'];
      boss.tree.value = (i['Tree'] as String).split('|');
      boss.picETag.value = i['PicETag'];
      // getxSettings.appSettings.value.bossPicETag[j++] = i['PicETag'];
      // Provider.of<AppState>(context, listen: false).updateBoss(boss,boss.bossID);
      // homeData.updateBoss(boss, boss.bossID.value);
    }
    // getxSettings.updateSettings(getxSettings.appSettings.value);

    // request = http.Request('GET',Uri.parse('$url/v1/users'));
    // request.headers.addAll(headers);
    // response = await request.send();
    // jsonString = await response.stream.bytesToString();
    // data = jsonDecode(jsonString);

    dataInitComplete = true;
  }
}