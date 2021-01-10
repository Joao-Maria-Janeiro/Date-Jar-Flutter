import 'dart:convert';
import 'dart:typed_data';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:date_jar/login_page/login_page.dart';
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
  String friendUsername = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getUsername();
    getFriendName();
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

  Future<void> getFriendName() async {
    final SharedPreferences prefs = await _prefs;
    String authToken = prefs.getString('auth_token');
    var res = await http.get(baseUrl + 'users/friend',
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      if (res.body.toString().contains("error")) {
        errorMessage = 'Error retriving your friend, please login again';
      } else {
        friendUsername = res.body.toString();
        prefs.setString('friendUsername', friendUsername);
      }
    });
  }

  Future<void> removeFriend() async {
    final SharedPreferences prefs = await _prefs;
    String authToken = prefs.getString('auth_token');
    var res = await http.post(baseUrl + 'users/remove-friend',
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      if (res.body.toString().contains("error")) {
        errorMessage = 'Error removing your friend, please try again later';
      } else {
        friendUsername = '';
        prefs.remove('friendUsername');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      }
    });
  }

  void logOut() async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Current friend: ' + friendUsername,
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssociateUserPage()),
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        friendUsername.isEmpty
                            ? Container(
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
                              )
                            : Container(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                    ),
                                    Icon(Icons.person_add),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Change your friend',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                friendUsername.isEmpty
                    ? Container()
                    : InkWell(
                        onTap: () {
                          removeFriend();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                            ),
                            Icon(Icons.clear),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Remove your friend',
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () => logOut(),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Log Out ' + username,
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
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
          )),
        ],
      ),
    );
  }
}
