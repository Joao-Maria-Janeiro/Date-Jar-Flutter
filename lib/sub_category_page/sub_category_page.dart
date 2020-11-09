import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:date_jar/create_activity_page/create_activity_page.dart';
import 'package:date_jar/create_category_page/create_category_page.dart';
import 'package:date_jar/edit_sub_category_page/edit_sub_category_page.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:confetti/confetti.dart';

class SubCategoryPage extends StatefulWidget {
  List<dynamic> subCategories;
  String categoryType;

  SubCategoryPage({Key key, this.subCategories, this.categoryType})
      : super(key: key);

  @override
  _subCategoryPageState createState() => _subCategoryPageState();
}

class _subCategoryPageState extends State<SubCategoryPage> {
  final storage = new FlutterSecureStorage();
  Image picture;
  bool activityPop = false;
  ConfettiController _controllerCenter;
  String randomActivityName = '';
  String currentCategoryOpened = '';
  String baseUrl = 'http://192.168.1.18:8080/';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getProfilePic();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    super.dispose();
    _controllerCenter.dispose();
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

  Future<void> getRandomActivity(String categoryName) async {
    String authToken = await storage.read(key: 'auth_token');
    var res = await http.get(
        baseUrl +
            'activities/random/category/' +
            categoryName +
            "/type/" +
            widget.categoryType,
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      randomActivityName = json.decode(res.body)['name'];
    });
  }

  Future<bool> deleteActivity() async {
    String authToken = await storage.read(key: 'auth_token');
    var res = await http.post(baseUrl + 'activities/delete',
        headers: {'Authorization': 'Bearer ' + authToken},
        body: jsonEncode({
          'category_name': currentCategoryOpened,
          'category_type': widget.categoryType,
          'activity_name': randomActivityName
        }));
    print(res.body);
    if (res.body.contains('error') ||
        res.body !=
            'Activity deleted '
                'successfuly') {
      setState(() {
        errorMessage = 'Error deleting the activity';
      });
      return false;
    }
    return true;
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop:
                  false, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
            ),
          ),
          pageTitle(capitalize(widget.categoryType
              .toLowerCase()
              .replaceAll("-", " ")
              .replaceAll("_", " "))),
          profilePic(picture),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Expanded(
                  child: new ListView.builder(
                      itemCount: widget.subCategories.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return taskWidget(
                            Color((math.Random().nextDouble() * 0xFFFFFF)
                                    .toInt())
                                .withOpacity(1.0),
                            widget.subCategories[index]);
                      }),
                ),
              ],
            ),
          )),
          Container(
            child: (activityPop == true)
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white),
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              height: 1,
                            ),
                            Text(
                              errorMessage.isEmpty
                                  ? randomActivityName
                                  : errorMessage,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: errorMessage.isEmpty
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    getRandomActivity(currentCategoryOpened);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "Draw",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 10,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    closeTaskPop();
                                    _controllerCenter.stop();
                                    setState(() {
                                      errorMessage = '';
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Text(
                                        "Take",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 10,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    bool deletedActivity =
                                        await deleteActivity();
                                    print(deletedActivity);
                                    if (deletedActivity) {
                                      closeTaskPop();
                                    } else {
                                      Future.delayed(
                                          const Duration(milliseconds: 2000),
                                          () {
                                        setState(() {
                                          errorMessage = '';
                                        });
                                      });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Text(
                                        "Remove",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        elevation: 15,
        children: [
          SpeedDialChild(
              // child: Icon(Icons.article_outlined),
              label: "Add Category",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateCategoryPage(
                            categoryType: widget.categoryType,
                          )),
                );
              }),
          SpeedDialChild(
              child: Icon(Icons.star),
              label: "Add Activity",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateActivityPage(
                            subCategories: widget.subCategories.isNotEmpty
                                ? widget.subCategories
                                : [],
                            categoryType: widget.categoryType,
                          )),
                );
              }),
        ],
      ),
    );
  }

  openTaskPop() {
    activityPop = true;
    setState(() {});
  }

  closeTaskPop() {
    activityPop = false;
    setState(() {});
  }

  Slidable taskWidget(Color color, String title) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.3,
      child: GestureDetector(
        onTap: () {
          print(title);
          openTaskPop();
          getRandomActivity(title);
          setState(() {
            currentCategoryOpened = title;
          });
          if (_controllerCenter != null) {
            _controllerCenter.play();
          }
        },
        child: Container(
          height: 80,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 3,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 4)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  height: 50,
                  width: 5,
                  color: color,
                )
              ],
            ),
          ),
        ),
      ),
      secondaryActions: [
        IconSlideAction(
          color: Colors.white,
          icon: Icons.edit,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditSubCategoryPage(
                        categoryName: title,
                        categoryType: widget.categoryType,
                      )),
            );
          },
        ),
        IconSlideAction(
          color: Colors.white,
          icon: Icons.delete,
          onTap: () {},
        )
      ],
    );
  }
}
