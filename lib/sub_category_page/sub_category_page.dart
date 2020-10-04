import 'dart:convert';

import 'package:date_jar/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SubCategoryPage extends StatefulWidget {
  List<dynamic> subCategories;

  SubCategoryPage({Key key, this.subCategories}) : super(key: key);

  @override
  _subCategoryPageState createState() => _subCategoryPageState();
}

class _subCategoryPageState extends State<SubCategoryPage> {
  @override
  void initState() {
    super.initState();
    print(widget.subCategories);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: new ListView.builder(
            itemCount: widget.subCategories.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new Text(widget.subCategories[index]);
            }));
  }
}
