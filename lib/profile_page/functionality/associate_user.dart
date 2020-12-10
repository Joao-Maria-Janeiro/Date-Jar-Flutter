import 'dart:convert';
import 'dart:typed_data';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:date_jar/login_page/components/background.dart';
import 'package:date_jar/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class AssociateUserPage extends StatefulWidget {
  @override
  _AssociateUserPageState createState() => _AssociateUserPageState();
}

class _AssociateUserPageState extends State<AssociateUserPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Image picture;
  String friendUsername;
  String username;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUsername() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey('username')) {
      String usernameRead = prefs.getString('username');
      setState(() {
        username = usernameRead;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.07,
              ),
              SvgPicture.asset("assets/svgs/associate_user.svg",
                  height: size.height * 0.35),
              SizedBox(
                height: size.height * 0.03,
              ),
//              Container(
//                margin: EdgeInsets.symmetric(vertical: 10),
//                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                width: size.width * 0.8,
//                decoration: BoxDecoration(
//                  color: primaryLightColor,
//                  borderRadius: BorderRadius.circular(29),
//                ),
//              ),
              TextFieldContainer(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      friendUsername = value;
                    });
                  },
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.person_add,
                        color: primaryColor,
                      ),
                      hintText: "Friend's username"),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: size.width * 0.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    color: primaryColor,
                    onPressed: () async {
//                      bool createdActivity = await createActivity();
//                      if (createdActivity) {
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(builder: (context) => MyHomePage()),
//                        );
//                      }
                    },
                    child: Text(
                      "Create Activity",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
