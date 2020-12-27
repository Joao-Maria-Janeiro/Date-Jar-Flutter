import 'dart:convert';
import 'dart:typed_data';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'components/categories_dashboard.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> categories = new Map();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
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
    await fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await _prefs;
    String authToken = prefs.getString('auth_token');
    var res = await http.get(baseUrl + 'categories/all',
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      categories = json.decode(utf8.decode(res.bodyBytes));
    });
  }

  Future<void> getProfilePic() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey('picture')) {
      String image = prefs.getString('picture');
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
          profilePic(picture, context),
          RefreshIndicator(
            onRefresh: fetchData,
            backgroundColor: primaryColor,
            color: Colors.white,
            child: SafeArea(
                child: Padding(
              padding:
                  EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  GridDashboard(categoriesToSubCategories: categories),
                ],
              ),
            )),
          )
        ],
      ),
    );
  }
}
