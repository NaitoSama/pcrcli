import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
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

class SendReq {
  String? token;
  int reqMethod;
  http.MultipartRequest? request;
  http.StreamedResponse? response;
  Map<String,String>? query;
  String? file;
  String? fileKey;
  String url;
  SendReq(this.reqMethod,this.url, {this.token, this.query, this.file, this.fileKey});

  Future<http.StreamedResponse?> send () async {
    var url1 = Uri.parse(url);
    if (query != null){
      url1 = url1.replace(queryParameters: query);
    }
    switch(reqMethod){
      case 1: request = http.MultipartRequest('GET',url1);
      case 2: request = http.MultipartRequest('POST',url1);
      default: return null;
    }
    if (file != null && fileKey != null){
      try {
        request?.files.add(
            await http.MultipartFile.fromPath(fileKey!, file!)
        );
      } catch (e){
        print('err: $e');
        return null;
      }
    }
    if (token != null){
      var headers = {
        'Cookie': 'pekoToken=$token'
      };
      request?.headers.addAll(headers);
    }

    response = await request?.send();

    if (response?.statusCode == 200) {
      print(await response?.stream.bytesToString());
      return response;
    }
    else {
      print(response?.reasonPhrase);
      return null;
    }
  }
}