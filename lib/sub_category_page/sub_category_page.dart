import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:date_jar/create_activity_page/create_activity_page.dart';
import 'package:date_jar/create_category_page/create_category_page.dart';
import 'package:date_jar/edit_sub_category_page/edit_sub_category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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

  @override
  void initState() {
    super.initState();
    getProfilePic();
    print(widget.subCategories);
    print(widget.categoryType);
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
//    widget.subCategories = [
//      "Test 1",
//      "Test 2",
//      "Test 3",
//      "Test 4",
//      "Test 5",
//      "Test 6",
//      "Test 7",
//      "Test 8",
//      "Test 9",
//      "Test 10",
//      "Test 11",
//      "Test 12"
//    ];
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
          ))
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
                            subCategories: widget.subCategories.isNotEmpty
                                ? widget.subCategories
                                : [],
                          )),
                );
              }),
        ],
      ),
    );
  }

  Slidable taskWidget(Color color, String title) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.3,
      child: GestureDetector(
        onTap: () {
          print(title);
        },
        child: Container(
          height: 80,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      border: Border.all(color: color, width: 4)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Colors.black, fontSize: 18),
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
