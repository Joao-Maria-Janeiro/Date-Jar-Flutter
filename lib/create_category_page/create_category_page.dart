import 'dart:convert';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:date_jar/login_page/components/background.dart';
import 'package:date_jar/signup_page/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class CreateCategoryPage extends StatefulWidget {
  String categoryType;

  CreateCategoryPage({Key key, this.categoryType}) : super(key: key);

  @override
  _CreateCategoryState createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategoryPage> {
  String categoryName;
  String baseUrl = 'http://192.168.1.18:8080/';
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    print(widget.categoryType);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> createCategory() async {
    if (categoryName.isNotEmpty) {
      String authToken = await storage.read(key: 'auth_token');
      var res = await http.post(baseUrl + 'categories/add',
          body: jsonEncode(
              {'title': categoryName, 'type': widget.categoryType}), headers: {'Authorization': 'Bearer ' + authToken});
      if (res.body.isNotEmpty && !res.body.contains("error")) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
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
              SvgPicture.asset("assets/svgs/categories.svg",
                  height: size.height * 0.35),
              SizedBox(
                height: size.height * 0.03,
              ),
              TextFieldContainer(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      categoryName = value;
                    });
                  },
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.article_outlined,
                        color: primaryColor,
                      ),
                      hintText: "Category Name"),
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
                      bool createdCategory = await createCategory();
                      if (createdCategory) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }
                    },
                    child: Text(
                      "Create Category",
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