import 'dart:convert';
import 'dart:typed_data';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'components/categories_dashboard.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String baseUrl = 'http://192.168.1.18:8080/';
  Map<String, dynamic> categories = new Map();
  final storage = new FlutterSecureStorage();
  Image picture;

  @override
  void initState() {
    super.initState();
    getData();
    getProfilePic();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData() async {
    String authToken = await storage.read(key: 'auth_token');
    var res = await http.get(baseUrl + 'categories/all',
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      categories = json.decode(res.body);
    });
  }

  Future<void> getProfilePic() async {
    if (await storage.containsKey(key: 'picture')) {
      String image = await storage.read(key: 'picture');
      if (image.isNotEmpty) {
        Uint8List bytes = base64Decode(image);
        setState(() {
          picture = new Image.memory(bytes);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          pageTitle("Home"),
          profilePic(picture),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                GridDashboard(categoriesToSubCategories: categories),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
