part of 'main.dart';

class WSC extends GetxController {
  bool isConnected = false;
  late WebSocketChannel ws;
  List<int> recordsUniquenessCheck = [];
  late String url;
  late String token;
  bool dataInitComplete = false;
  bool isTimeout = true;
  int reconnect = 0;
  GetxSettings getxSettings = Get.find<GetxSettings>();
  HomeData homeData = Get.find<HomeData>();

  void WSDispose() {
    ws.sink.close();
  }

  Future<void> connect() async {
    print('ws is connecting...');
    isTimeout = true;
    url = getxSettings.appSettings.value.remoteServerUrl;
    token = getxSettings.appSettings.value.token;
    if (!getxSettings.appSettings.value.isLoggedIn ||
        !getxSettings.appSettings.value.isUrlConfirmed) {
      throw Exception('url or token is not initialized!');
    }
    ws = IOWebSocketChannel.connect('${url.replaceFirst('http', 'ws')}/v1/ws',
        headers: {HttpHeaders.cookieHeader: 'pekoToken=$token'});

    // await ws.ready;
    var stream = ws.stream.listen(
      (event) {
        // print(event);
        _handleWebsocketMessage(event);
      },
      onError: (error) {
        print(error);
      },
    );

    if (!await _connectionDetection()) {
      WSDispose();
      await connect();
      return;
    }

    isConnected = true;
    homeData.isWSValid.value = true;
    _heartbeat();
    await _renewMyData();
    await _getRecords();
  }

  Future<void> _renewMyData() async {
    GetxSettings getxSettings = Get.find<GetxSettings>();
    final Map<String, String> headers = {
      'Cookie': 'pekoToken=${getxSettings.appSettings.value.token}'
    };
    var response = await http.get(
      Uri.parse(
          '${getxSettings.appSettings.value.remoteServerUrl}/v1/users?users=${getxSettings.appSettings.value.username}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      GetxSettings getxSettings = Get.find<GetxSettings>();
      if (getxSettings.appSettings.value.authority !=
          jsonResponse[0]['Permission']) {
        await getNewTokenCircle();
      }
    }
  }

  void _handleWebsocketMessage(dynamic message) async {
    var getx = Get.find<GetxSettings>();
    var homeData = Get.find<HomeData>();
    final body = jsonDecode(message);
    var data = body["Data"];
    switch (body["type"]) {
      case "promotion_user":
        {
          if (getx.appSettings.value.username == body["Data"]) {
            getNewTokenCircle();
          }
          break;
        }

      case "heartbeat":
        {
          isTimeout = false;
          break;
        }

      case "boss_update":
        {
          int bossID = data['ID'];
          BossInfo boss = homeData.bosses[bossID - 1];
          // boss lock change notification
          if (boss.attacking.value != data['WhoIsIn']) {
            String title = data['WhoIsIn'] == ' ' ? '解锁BOSS' : '锁定BOSS';
            BotToast.showNotification(
              // leading: (_) => SvgPicture.asset('images/swords.svg'),
              title: (_) => Row(
                children: [
                  Container(
                      height: 20,
                      width: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: data['WhoIsIn'] == ' '
                            ? Image.asset(
                                'images/64135784.png',
                              )
                            : Image.memory(
                                getx.appSettings.value.eTagToPic[
                                    homeData.users[data['WhoIsIn']]!.picEtag]!,
                              ),
                      )),
                  Text(title),
                ],
              ),
              subtitle: (_) => Text(
                  '${data['WhoIsIn'] == ' ' ? '没有人' : data['WhoIsIn']}正在攻打boss$bossID'),
            );
            // boss.isAttChanged.value = true;
          }
          // tree change notification
          if (boss.tree.value != (data['Tree'] as String).split('|') &&
              (data['Tree'] as String).split('|') !=
                  [
                    ' ',
                  ]) {
            // boss.isTreeChanged.value = true;
          }
          boss.stage.value = data['Stage'];
          boss.round.value = data['Round'];
          boss.valueC.value = data['Value'];
          boss.valueD.value = data['ValueD'];
          boss.attacking.value = data['WhoIsIn'];
          boss.tree.value = (data['Tree'] as String).split('|');
          boss.picETag.value = data['PicETag'];
          break;
        }

      case "record_append":
        {
          if (recordsUniquenessCheck.contains(data['ID'])) {
            return;
          }
          recordsUniquenessCheck.add(data['ID']);
          // Provider.of<AppState>(context, listen: false).appendRecord('${data['AttackFrom']}对boss${data['AttackTo']}造成了${data['Damage']}点伤害!');
          String? picETag = homeData.users[data['AttackFrom']]?.picEtag.value;
          if (!getx.appSettings.value.eTagToPic.containsKey(picETag) &&
              picETag != '') {
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
          String name = Characters(data['AttackFrom']).length > 16
              ? '${Characters(data['AttackFrom']).take(16)}...'
              : data['AttackFrom'];
          late String damage;
          if (data['Damage'] >= 10000 && data['Damage'] < 100000000) {
            damage = '${data['Damage'] ~/ 10000}万';
          } else if (data['Damage'] >= 100000000) {
            damage = '${data['Damage'] ~/ 1000000 / 100}亿';
          } else {
            damage = '${data['Damage']}';
          }
          record.text = '$name对boss${data['AttackTo']}造成了$damage伤害!';
          record.id = data['ID'];
          record.createTime = data['CreatedAt'];
          record.attackFrom = data['AttackFrom'];
          record.attackTo = data['AttackTo'];
          record.canUndo = data['CanUndo'];
          record.damage = data['Damage'];
          homeData.appendRecord(record);
          break;
        }

      case "record_delete":
        {
          int recordID = data["ID"];
          homeData.deleteRecord(recordID);
          break;
        }
    }
  }

  Future<void> _getRecords() async {
    // init record
    List<String> users = [];
    var homeData = Get.find<HomeData>();
    var getx = Get.find<GetxSettings>();
    var headers = {'Cookie': 'pekoToken=$token'};

    var request = http.Request('GET', Uri.parse('$url/v1/records'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.contentLength == null || response.contentLength! > 4) {
      var jsonString = await response.stream.bytesToString();
      var data = jsonDecode(jsonString);
      List<Record> records = [];

      // init users
      users.add(getx.appSettings.value.username);
      for (Map<String, dynamic> i in data) {
        if (i['CanUndo'] != 1) {
          continue;
        }
        String username = i['AttackFrom'];
        if (!users.contains(username)) {
          users.add(username);
        }
      }
      String query = '';
      for (int index = 0; index < users.length; index++) {
        query += 'users=${users[index]}';
        if (index != users.length - 1) query += '&';
      }
      var request2 = http.Request('GET', Uri.parse('$url/v1/users?$query'));
      request2.headers.addAll(headers);
      var response2 = await request2.send();
      var jsonString2 = await response2.stream.bytesToString();
      var data2 = jsonDecode(jsonString2);
      for (Map<String, dynamic> i in data2) {
        User user = User();
        user.id.value = i['ID'];
        user.name.value = i['Name'];
        user.picEtag.value = i['PicETag'];
        user.picEtag128.value = i['Pic16ETag'];
        user.permission.value = i['Permission'];
        homeData.users[i['Name']] = user;
      }

      // init records
      for (Map<String, dynamic> i in data) {
        if (i['CanUndo'] != 1) {
          continue;
        }
        String? picETag = homeData.users[i['AttackFrom']]?.picEtag.value;
        if (!getx.appSettings.value.eTagToPic.containsKey(picETag) &&
            picETag != '') {
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
        String name = Characters(i['AttackFrom']).length > 16
            ? '${Characters(i['AttackFrom']).take(16)}...'
            : i['AttackFrom'];
        late String damage;
        if (i['Damage'] >= 10000 && i['Damage'] < 100000000) {
          damage = '${i['Damage'] ~/ 10000}万';
        } else if (i['Damage'] >= 100000000) {
          damage = '${i['Damage'] ~/ 1000000 / 100}亿';
        } else {
          damage = '${i['Damage']}';
        }
        record.text = '$name对boss${i['AttackTo']}造成了$damage伤害!';
        record.id = i['ID'];
        record.createTime = i['CreatedAt'];
        record.attackFrom = i['AttackFrom'];
        record.attackTo = i['AttackTo'];
        record.canUndo = i['CanUndo'];
        record.damage = i['Damage'];
        records.add(record);
      }
      // Provider.of<AppState>(context, listen: false).initRecord(records);
      homeData.initRecord(records);
    } else {
      var request2 = http.Request('GET',
          Uri.parse('$url/v1/users?users=${getx.appSettings.value.username}'));
      request2.headers.addAll(headers);
      var response2 = await request2.send();
      var jsonString2 = await response2.stream.bytesToString();
      var data2 = jsonDecode(jsonString2);
      for (Map<String, dynamic> i in data2) {
        User user = User();
        user.id.value = i['ID'];
        user.name.value = i['Name'];
        user.picEtag.value = i['PicETag'];
        user.picEtag128.value = i['Pic16ETag'];
        user.permission.value = i['Permission'];
        homeData.users[i['Name']] = user;
      }
    }

    request = http.Request('GET', Uri.parse('$url/v1/bosses'));
    request.headers.addAll(headers);
    response = await request.send();
    var jsonString = await response.stream.bytesToString();
    var data = jsonDecode(jsonString);
    GetxSettings getxSettings = Get.find<GetxSettings>();
    int j = 0;
    for (Map<String, dynamic> i in data) {
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

  void _sendHeartbeat() {
    Map<String, String> jsonData = {
      "type": "heartbeat",
      "Data": "nothing",
      "token": getxSettings.appSettings.value.token
    };
    final jsonString = jsonEncode(jsonData);
    ws.sink.add(jsonString);
  }

  Future<void> _heartbeat() async {
    while (true) {
      isTimeout = true;
      _sendHeartbeat();
      await Future.delayed(const Duration(seconds: 5));
      if (isTimeout) {
        homeData.isWSValid.value = false;
        print('reconnecting...');
        await connect();
        // todo reconnect or something to remind user
        return;
      }
    }
  }

  Future<bool> _connectionDetection() async {
    // isTimeout = true;
    _sendHeartbeat();
    for (int i = 0; i < 30; i++) {
      // 3 seconds detection
      print(i);
      if (!isTimeout) {
        return true;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }
    return false;
  }
}

Future<bool> getNewToken() async {
  GetxSettings getx = Get.find<GetxSettings>();
  final url = Uri.parse(
      '${getx.appSettings.value.remoteServerUrl}/login'); // 替换成你的登录接口URL
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  final Map<String, dynamic> requestBody = {
    'username': getx.appSettings.value.username,
    'password': getx.appSettings.value.password,
  };

  var response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    String cookie = response.headers['set-cookie'] ?? '';
    var temp = cookie.split('pekoToken=');
    cookie = temp[temp.length - 1].split(';')[0];
    getx.appSettings.value.token = cookie;

    final Map<String, String> json = {
      'jwt': cookie,
    };
    response = await http.post(
        Uri.parse('${getx.appSettings.value.remoteServerUrl}/userinfo'),
        headers: headers,
        body: jsonEncode(json));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      getx.appSettings.value.username = jsonResponse['username'];
      getx.appSettings.value.authority = jsonResponse['user_authority'];
      getx.appSettings.value.isLoggedIn = true;
      getx.updateSettings(getx.appSettings.value);
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<void> getNewTokenCircle() async {
  bool result = await getNewToken();
  if (!result) {
    await Future.delayed(const Duration(seconds: 1));
    await getNewTokenCircle();
  }
}
