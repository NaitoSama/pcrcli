import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'common.dart';

class MyPageLogic {

  Future<bool> changePassword(String url,String name,String token,String oldP,String newP) async {
    var body = jsonEncode({
      "username": name,
      "old_password": oldP,
      "new_password": newP,
    });

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'pekoToken=$token'
    };
    var resp = await http.post(
      Uri.parse('$url/changepassword'),
      headers: headers,
      body: body,
    );
    if (resp.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  // 选择图片
  Future<bool> _pickImage(String url,String token) async {
    // final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var originalImage = File(pickedFile.path);
      var imageBytes = await originalImage.readAsBytes();
      List<int> compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: 1920,
        minWidth: 1080,
        quality: 90,
        format: CompressFormat.jpeg,
      );

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String imagePath = '$tempPath/converted_image.jpg'; // Path to save the converted JPEG image
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(compressedBytes);


      // 裁剪图片
      CroppedFile? croppedImage = await _cropImage(imageFile);
      // CroppedFile? croppedImage = await _cropImage(File(pickedFile.path));

      if (croppedImage != null) {

        // 上传图片
        bool result = await _uploadImage(croppedImage,url,token);
        return result;

        // 刷新页面
        // setState(() {});
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  // 裁剪图片
  Future<CroppedFile?> _cropImage(File image) async {
    return await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '裁剪',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
      ],
    );
    // return await ImageCropper().cropImage(
    //   sourcePath: image.path,
    // aspectRatioPresets: [
    //   CropAspectRatioPreset.square,
    //   // CropAspectRatioPreset.original,
    // ],
    // androidUiSettings: AndroidUiSettings(
    //   toolbarTitle: 'Crop Image',
    //   toolbarColor: Colors.deepOrange,
    //   toolbarWidgetColor: Colors.white,
    //   initAspectRatio: CropAspectRatioPreset.original,
    //   lockAspectRatio: false,
    // ),
    // );
  }

  // 上传图片
  Future<bool> _uploadImage(CroppedFile? image,String url,String token) async {

    // final uri = Uri.parse(url);
    // var request = http.MultipartRequest('POST', uri);
    //
    // request.files.add(await http.MultipartFile.fromPath('pic', image.path));

    var req = SendReq(
      2,
      '$url/v1/uploaduserpic',
      token: token,
      file: image?.path,
      fileKey: 'pic',
    );
    var response = await req.send();
    if (response?.statusCode == 200) {
      // 上传成功
      return true;
    } else {
      // 上传失败
      return false;
    }
  }

}