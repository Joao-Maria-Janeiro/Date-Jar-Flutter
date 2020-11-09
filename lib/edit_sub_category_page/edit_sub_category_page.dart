import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

//import 'components/categories_dashboard.dart';

class EditSubCategoryPage extends StatefulWidget {
  String categoryName;
  String categoryType;

  EditSubCategoryPage({Key key, this.categoryName, this.categoryType})
      : super(key: key);

  @override
  _EditSubCategoryPageState createState() => _EditSubCategoryPageState();
}

class _EditSubCategoryPageState extends State<EditSubCategoryPage> {
  String baseUrl = 'http://192.168.1.18:8080/';
  List<String> activities = [];
  final storage = new FlutterSecureStorage();
  String authToken;
  Image picture;
  String errorMessage = '';
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  List<bool> editName = [];
  bool editCategoryName = false;
  Tween<Offset> offset = Tween(begin: Offset(1, 0), end: Offset(0, 0));
  String newCategoryName = '';

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
    authToken = await storage.read(key: 'auth_token');
    var res = await http.get(
        baseUrl +
            'activities/category/' +
            widget.categoryName +
            "/type/" +
            widget.categoryType,
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      List auxActivities = json.decode(res.body);
      Future ft = Future(() {});
      auxActivities.forEach((activity) {
        ft = ft.then((_) {
          return Future.delayed(const Duration(milliseconds: 100), () {
            activities.add(activity["name"]);
            animatedListKey.currentState.insertItem(activities.length - 1);
          });
        });
        editName.add(false);
      });
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

  Future<bool> updateCategoryName(String newCategoryName) async {
    var res = await http.post(
        baseUrl +
            'categories/edit/' +
            widget.categoryName +
            "/type/" +
            widget.categoryType,
        body: jsonEncode({'new_category_name': newCategoryName}),
        headers: {'Authorization': 'Bearer ' + authToken});
    if (res.body != "Success") {
      setState(() {
        errorMessage =
            "There was an error updating your category name, please try again";
      });
      return false;
    } else {
      setState(() {
        widget.categoryName = newCategoryName;
      });
      return true;
    }
  }

  Future<bool> updateActivity(
      String oldActivityName, String newActivityName) async {
    var res = await http.post(
        baseUrl +
            'activities/category/' +
            widget.categoryName +
            "/type/" +
            widget.categoryType +
            "/activity",
        body: jsonEncode({
          'new_activity_name': newActivityName,
          'old_activity_name': oldActivityName
        }),
        headers: {'Authorization': 'Bearer ' + authToken});
    if (res.body != "Success") {
      setState(() {
        errorMessage =
            "There was an error updating your activity name, please try again";
      });
      return false;
    } else {
      return true;
    }
  }

  Future<bool> deleteActivity(String activityName) async {
    var res = await http.post(baseUrl + 'activities/delete',
        body: jsonEncode({
          'activity_name': activityName,
          'category_name': widget.categoryName,
          'category_type': widget.categoryType
        }),
        headers: {'Authorization': 'Bearer ' + authToken});
    if (res.body != "Activity deleted successfuly") {
      setState(() {
        errorMessage =
            "There was an error delete your activity, please try again";
      });
      return false;
    } else {
      return true;
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
            child: !editCategoryName
                ? Positioned(
                    left: 20,
                    child: Row(
                      children: [
                        pageTitle(
                          widget.categoryName,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              editCategoryName = !editCategoryName;
                            });
                          },
                          child: Icon(
                            Icons.edit,
                          ),
                        ),
                      ],
                    ),
                  )
                : Positioned(
                    left: 20,
                    top: 0,
                    child: Container(
                      height: 64,
                      margin: EdgeInsets.only(bottom: 20, top: 60, left: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: TextField(
                              onChanged: (value) {
                                newCategoryName = value;
                              },
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                              ),
                              decoration: InputDecoration(
                                hintText: widget.categoryName,
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.3,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  bool updatedCategoryName =
                                      await updateCategoryName(newCategoryName);
                                  if (updatedCategoryName) {
                                    setState(() {
                                      editCategoryName = !editCategoryName;
                                    });
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage()),
                                    );
                                  }
                                },
                                child: Icon(
                                  Icons.check,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    editCategoryName = !editCategoryName;
                                  });
                                },
                                child: Icon(
                                  Icons.clear,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          profilePic(picture),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedList(
                      key: animatedListKey,
                      initialItemCount: activities.length,
                      itemBuilder: (BuildContext ctxt, int index, animation) {
                        Color color = Color(
                                (math.Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1.0);
                        String newActivityName = '';
                        return SlideTransition(
                          position: animation.drive(offset),
                          child: Container(
                            height: 80,
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 3,
                              child: Row(
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: color, width: 4)),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (editName.isEmpty
                                              ? false
                                              : editName[index])
                                          ? Container(
                                              child: TextField(
                                                textInputAction:
                                                    TextInputAction.unspecified,
                                                onChanged: (value) {
                                                  if (value.isNotEmpty) {
                                                    newActivityName = value;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    hintText:
                                                        activities[index]),
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
                                                  fontSize: 18,
                                                  fontFamily: 'Montserrat'),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child: (editName.isEmpty
                                                ? false
                                                : editName[index])
                                            ? Icon(Icons.check)
                                            : Icon(Icons.edit),
                                        onTap: () async {
                                          bool updatedSuccessfully = false;
                                          if (editName[index]) {
                                            updatedSuccessfully =
                                                await updateActivity(
                                                    activities[index],
                                                    newActivityName);
                                          }
                                          setState(() {
                                            if (updatedSuccessfully) {
                                              activities[index] =
                                                  newActivityName;
                                            }
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child: (editName.isEmpty
                                                ? false
                                                : editName[index])
                                            ? Icon(Icons.clear)
                                            : Icon(Icons.delete),
                                        onTap: () async {
                                          bool removedActivity = false;
                                          if (!editName[index]) {
                                            removedActivity =
                                                await deleteActivity(
                                                    activities[index]);
                                          }
                                          setState(() {
                                            if (editName[index]) {
                                              editName[index] = false;
                                            } else {
                                              if (removedActivity) {
                                                AnimatedList.of(ctxt).removeItem(
                                                    index,
                                                    (context, animation) =>
                                                        _buildItem(
                                                            ctxt,
                                                            animation,
                                                            index,
                                                            newActivityName));
                                                // activities.removeAt(index);
                                              }
                                            }
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
                          ),
                        );
                      }),
                ),
              ],
            ),
          )),
          Positioned(
            bottom: 0,
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext ctxt, Animation animation, int index,
      String newActivityName) {
    Color color =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    return SlideTransition(
      position: animation.drive(offset),
      child: Container(
        height: 80,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  (editName.isEmpty ? false : editName[index])
                      ? Container(
                          child: TextField(
                            onChanged: (value) {
                              newActivityName = value;
                            },
                            decoration:
                                InputDecoration(hintText: activities[index]),
                          ),
                          width: MediaQuery.of(context).size.width * 0.3,
                        )
                      : Text(
                          activities[index],
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Montserrat'),
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
                    child: (editName.isEmpty ? false : editName[index])
                        ? Icon(Icons.check)
                        : Icon(Icons.edit),
                    onTap: () async {
                      bool updatedSuccessfully = false;
                      if (editName[index]) {
                        updatedSuccessfully = await updateActivity(
                            activities[index], newActivityName);
                      }
                      setState(() {
                        if (updatedSuccessfully) {
                          activities[index] = newActivityName;
                        }
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
                    child: (editName.isEmpty ? false : editName[index])
                        ? Icon(Icons.clear)
                        : Icon(Icons.delete),
                    onTap: () async {
                      bool removedActivity = false;
                      if (!editName[index]) {
                        removedActivity =
                            await deleteActivity(activities[index]);
                      }
                      setState(() {
                        if (editName[index]) {
                          editName[index] = false;
                        } else {
                          if (removedActivity) {
                            activities.removeAt(index);
                            AnimatedList.of(ctxt).removeItem(
                                index,
                                (context, animation) => SizedBox(
                                      width: 0,
                                      height: 0,
                                    ));
                          }
                        }
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
      ),
    );
  }
}
