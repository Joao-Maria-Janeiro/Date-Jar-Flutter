import 'dart:convert';
import 'dart:typed_data';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = new FlutterSecureStorage();
  Image picture;

  @override
  void initState() {
    super.initState();
    getProfilePic();
  }

  @override
  void dispose() {
    super.dispose();
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
                    Icon(Icons.person_add),
                    SizedBox(
                      width: 20,
                    ),
                    Text('Add your friend'),
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
                    Icon(Icons.clear),
                    SizedBox(
                      width: 20,
                    ),
                    Text('Remove your friend'),
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
