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

  void _handleWebsocketMessage(dynamic message) {
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
        homeData.appendRecord('${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!');
      }
    }
  }

  Future<void> _getRecords() async {
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
    dataInitComplete = true;
  }
}