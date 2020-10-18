import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:date_jar/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

//import 'components/categories_dashboard.dart';

class EditSubCategoryPage extends StatefulWidget {
  String categoryName;

  EditSubCategoryPage({Key key, this.categoryName}) : super(key: key);

  @override
  _EditSubCategoryPageState createState() => _EditSubCategoryPageState();
}

class _EditSubCategoryPageState extends State<EditSubCategoryPage> {
  String baseUrl = 'http://192.168.1.18:8080/';
  List<String> activities = [];
  final storage = new FlutterSecureStorage();
  Image picture;

  List<bool> editName = [];

  @override
  void initState() {
    super.initState();
    getData();
    getProfilePic();
    print(widget.categoryName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData() async {
    String authToken = await storage.read(key: 'auth_token');
    var res = await http.get(
        baseUrl + 'activities/category/' + widget.categoryName,
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      List auxActivities = json.decode(res.body);
      auxActivities.forEach((activity) {
        activities.add(activity["name"]);
        editName.add(false);
      });
      print(activities);
      print(editName);
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
                        backgroundImage: picture == null
                            ? Image.network(
                                    "https://img.icons8.com/pastel-glyph/2x/person-male.png")
                                .image
                            : picture.image,
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        Color color = Color(
                                (math.Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1.0);
                        return Container(
                          height: 80,
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 10,
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: color, width: 4)),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (editName.isEmpty ? false : editName[index])
                                        ? Container(
                                            child: TextField(
                                              onChanged: (value) {},
                                              decoration: InputDecoration(
                                                  hintText: activities[index]),
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                          )
                                        : Text(
                                            activities[index],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: (editName.isEmpty
                                              ? false
                                              : editName[index])
                                          ? Icon(Icons.check)
                                          : Icon(Icons.edit),
                                      onTap: () {
                                        setState(() {
                                          editName[index] = !editName[index];
                                        });
                                      },
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: (editName.isEmpty
                                              ? false
                                              : editName[index])
                                          ? Icon(Icons.clear)
                                          : Icon(Icons.delete),
                                      onTap: () {
                                        setState(() {
                                          editName[index] = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
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
