import 'dart:convert';
import 'dart:math' as math;
import 'package:date_jar/model/Category.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:date_jar/create_activity_page/create_activity_page.dart';
import 'package:date_jar/create_category_page/create_category_page.dart';
import 'package:date_jar/edit_sub_category_page/edit_sub_category_page.dart';
import 'package:date_jar/home_page/components/header.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:confetti/confetti.dart';

import '../constants.dart';

class SubCategoryPage extends StatefulWidget {
  List<dynamic> subCategoriesInput;
  String categoryType;

  SubCategoryPage({Key key, this.subCategoriesInput, this.categoryType})
      : super(key: key);

  @override
  _subCategoryPageState createState() => _subCategoryPageState();
}

class _subCategoryPageState extends State<SubCategoryPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<Category> subcategories = [];
  Image picture;
  bool activityPop = false;
  ConfettiController _controllerCenter;
  String randomActivityName = '';
  Category currentCategoryOpened;
  String errorMessage = '';
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  Tween<Offset> offset = Tween(begin: Offset(1, 0), end: Offset(0, 0));

  @override
  void initState() {
    super.initState();
    getProfilePic();
    getData();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    super.dispose();
    _controllerCenter.dispose();
  }

  void getData() async {
    setState(() {
      List<Category> subcategoriesAux = (widget.subCategoriesInput as List)
          .map((category) => Category.fromJson(category))
          .toList();
      Future ft = Future(() {});
      subcategoriesAux.forEach((category) {
        ft = ft.then((_) {
          return Future.delayed(const Duration(milliseconds: 100), () {
            subcategories.add(category);
            animatedListKey.currentState.insertItem(subcategories.length - 1);
          });
        });
      });
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

  Future<void> getRandomActivity(Category category) async {
    final SharedPreferences prefs = await _prefs;
    String authToken = prefs.getString('auth_token');
    var res = await http.get(
        baseUrl + 'activities/random/category/' + category.id.toString(),
        headers: {'Authorization': 'Bearer ' + authToken});
    setState(() {
      if (json.decode(res.body).toString().contains("error")) {
        errorMessage = 'There was an error getting your random activity';
      } else {
        if (json.decode(res.body)['name'] != null) {
          randomActivityName = json.decode(res.body)['name'];
        } else {
          randomActivityName = 'No activity yet';
        }
      }
    });
  }

  Future<bool> deleteCategory(Category category) async {
    final SharedPreferences prefs = await _prefs;
    String authToken = prefs.getString('auth_token');
    var res = await http.post(baseUrl + 'categories/remove/' + category.name,
        headers: {'Authorization': 'Bearer ' + authToken},
        body: jsonEncode({}));
    print(res.body);
    if (res.body.contains('error') || res.body != 'Success') {
      setState(() {
        errorMessage = 'Error deleting the category';
      });
      return false;
    }
    return true;
  }

  Future<bool> deleteActivity() async {
    final SharedPreferences prefs = await _prefs;
    String authToken = prefs.getString('auth_token');
    var res = await http.post(baseUrl + 'activities/delete',
        headers: {'Authorization': 'Bearer ' + authToken},
        body: jsonEncode({
          'category_name': currentCategoryOpened.name,
          'category_type': widget.categoryType,
          'activity_name': randomActivityName
        }));
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
          profilePic(picture, context),
          SafeArea(
              child: Padding(
            padding: EdgeInsets.only(top: 90, left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedList(
                      initialItemCount: subcategories.length,
                      key: animatedListKey,
                      itemBuilder: (BuildContext ctxt, int index, animation) {
                        return SlideTransition(
                          position: animation.drive(offset),
                          child: taskWidget(
                              Color((math.Random().nextDouble() * 0xFFFFFF)
                                      .toInt())
                                  .withOpacity(1.0),
                              subcategories[index],
                              index,
                              ctxt),
                        );
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
              child: Icon(Icons.article_outlined),
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
                            subCategories:
                                subcategories.isNotEmpty ? subcategories : [],
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

  Slidable taskWidget(
      Color color, Category category, int index, BuildContext ctxt) {
    String title = category.name;
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.3,
      child: GestureDetector(
        onTap: () {
          openTaskPop();
          getRandomActivity(category);
          setState(() {
            currentCategoryOpened = category;
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
                        category: category,
                      )),
            );
          },
        ),
        IconSlideAction(
          color: Colors.white,
          icon: Icons.delete,
          onTap: () async {
            bool deleted = await deleteCategory(category);
            print(deleted);
            if (deleted) {
              subcategories.removeAt(index);
              AnimatedList.of(ctxt).removeItem(
                  index,
                  (context, animation) => taskWidget(
                      Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                          .withOpacity(1.0),
                      category,
                      index,
                      ctxt));
            }
          },
        )
      ],
    );
  }
}
