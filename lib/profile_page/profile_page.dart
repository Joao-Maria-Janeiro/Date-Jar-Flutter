import 'dart:convert';
import 'dart:typed_data';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'functionality/associate_user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Image picture;
  String username = '';

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUsername() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey('auth_token')) {
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
      body: Stack(
        children: [
          Positioned(
            left: 20,
            top: 0,
            child: Container(
              height: 80,
              width: 250,
              margin: EdgeInsets.only(bottom: 20, top: 60, left: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssociateUserPage()),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Icon(Icons.person_add),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Add your friend'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.clear),
                    SizedBox(
                      width: 20,
                    ),
                    Text('Remove your friend'),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text('Log Out ' + username),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
