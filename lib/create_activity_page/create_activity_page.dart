import 'dart:convert';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:date_jar/login_page/components/background.dart';
import 'package:date_jar/signup_page/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateActivityPage extends StatefulWidget {
  List<dynamic> subCategories;

  CreateActivityPage({Key key, this.subCategories}) : super(key: key);

  @override
  _CreateActivityState createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivityPage> {
  String baseUrl = 'http://192.168.1.18:8080/';
  final storage = new FlutterSecureStorage();
  List<DropdownMenuItem<String>> _dropdownMenuItems;
  String _selectedItem;
  String activityName;

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(widget.subCategories);
    _selectedItem = _dropdownMenuItems[0].value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> createActivity() async {
    if (activityName.isNotEmpty) {
      String authToken = await storage.read(key: 'auth_token');
      var res = await http.post(baseUrl + 'activities/add',
          body: jsonEncode(
              {'activity_name': activityName, 'category_name': _selectedItem}),
          headers: {'Authorization': 'Bearer ' + authToken});
      if (res.body.isNotEmpty && !res.body.contains("error")) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  List<DropdownMenuItem<String>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<String>> items = List();
    for (String listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
              SvgPicture.asset("assets/svgs/signup.svg",
                  height: size.height * 0.35),
              SizedBox(
                height: size.height * 0.03,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  color: primaryLightColor,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Row(
                  children: [
                    Icon(Icons.article_outlined, color: primaryColor),
                    SizedBox(
                      width: size.width * 0.07,
                    ),
                    DropdownButton<String>(
                        value: _selectedItem,
                        items: _dropdownMenuItems,
                        onChanged: (value) {
                          setState(() {
                            _selectedItem = value;
                          });
                        }),
                  ],
                ),
              ),
              TextFieldContainer(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      activityName = value;
                    });
                  },
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.star,
                        color: primaryColor,
                      ),
                      hintText: "Activity Name"),
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
                      bool createdActivity = await createActivity();
                      if (createdActivity) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }
                    },
                    child: Text(
                      "Create Activity",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: primaryLightColor,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
