import 'dart:convert';

import 'package:date_jar/home_page/components/categories_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String baseUrl = 'http://192.168.1.185:8080/';
  List categories = [];

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
    var res = await http.get(baseUrl + 'categories/categories/all', headers: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImV4cCI6MTYwMTExMDQzNSwiaWF0IjoxNjAwNzk0ODY2fQ.it8NjrfgAeZr3cq7SgFuhoszgA_KNgznfl4oOcMevBE'
    });
    setState(() {
      categories = json.decode(res.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            height: MediaQuery.of(context).size.height * 0.1,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: InkWell(
                      child: Text(categories[index].toString(),
                          style:
                              TextStyle(color: Colors.black, fontSize: 24.0)),
                      onTap: () {
                        print(categories[index].toString());
                      },
                    ),
                  );
                }),
          ),
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
        color: Colors.black,
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          icon: Icon(Icons.search),
          color: Colors.black,
          onPressed: () {},
        ),
      ],
    );
  }
}
