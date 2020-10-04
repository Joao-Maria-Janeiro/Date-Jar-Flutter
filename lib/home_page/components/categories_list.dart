import 'package:flutter/material.dart';

Widget categoriesList(List categories) {
  return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 10,
          child: InkWell(
            child: Text(categories[index].toString(),
                style: TextStyle(color: Colors.black, fontSize: 24.0)),
            onTap: () {
              print(categories[index].toString());
            },
          ),
        );
      });
}
