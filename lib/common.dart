import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WS{
  late WebSocketChannel ws;
  void connectWS(String url,String token){
    ws = IOWebSocketChannel.connect(url,headers: {
      HttpHeaders.cookieHeader:'pekoToken=$token',
    });
  }
}