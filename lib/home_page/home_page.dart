import 'dart:convert';

import 'package:date_jar/constants.dart';
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

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData() async {
    String authToken = await storage.read(key: 'auth_token');
    var res = await http.get(baseUrl + 'categories/all',
        headers: {'Authorization': 'Bearer ' + authToken});
    print(res.body);
    setState(() {
      categories = json.decode(res.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
//      appBar: buildAppBar(),
      body: Stack(
        children: [
          Container(
            height: size.height * .3,
            decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: AssetImage('assets/images/top_header.png')),
            ),
          ),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 64,
                  margin: EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 32,
                        backgroundImage:
                            AssetImage('assets/images/avataaars-svg.png'),
                        backgroundColor: primaryColor,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ),
                GridDashboard(categoriesToSubCategories: categories),
              ],
            ),
          ))
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.only(left: 20.0),
        icon: Icon(Icons.menu),
        color: primaryColor,
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          icon: Icon(Icons.person),
          color: primaryColor,
          onPressed: () {},
        ),
      ],
    );
  }
}
