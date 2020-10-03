import 'package:flutter/material.dart';

Widget categoriesList(List categories) {
  return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: Text(
            categories[index].toString(),
            style: TextStyle(color: Colors.white, fontSize: 36.0),
          ),
          onTap: () {
            print(categories[index].toString());
          },
        );
      });
}
