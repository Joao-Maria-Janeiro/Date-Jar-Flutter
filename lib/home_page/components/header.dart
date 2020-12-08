import 'package:date_jar/profile_page/profile_page.dart';
import 'package:flutter/material.dart';

Widget pageTitle(String title) {
  return Positioned(
    left: 20,
    top: 0,
    child: Container(
      height: 64,
      margin: EdgeInsets.only(bottom: 20, top: 60, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
    ),
  );
}

Widget profilePic(Image picture, BuildContext context) {
  return Positioned(
    right: 16,
    top: 0,
    child: Container(
      height: 64,
      margin: EdgeInsets.only(bottom: 20, top: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 32,
              backgroundImage: picture == null
                  ? Image.network(
                          "https://img.icons8.com/pastel-glyph/2x/person-male.png")
                      .image
                  : picture.image,
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
    ),
  );
}
