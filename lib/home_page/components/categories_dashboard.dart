import 'package:date_jar/sub_category_page/sub_category_page.dart';
import 'package:flutter/material.dart';

class GridDashboard extends StatelessWidget {
  Items item1 = new Items(
      title: "Dinning",
      subtitle: "March, Wednesday",
      event: "3 Events",
      img: "assets/icons/icons8-dining-room-100.png");

  Items item2 = new Items(
    title: "Travel",
    subtitle: "Bocali, Apple",
    event: "4 Items",
    img: "assets/icons/icons8-airport-100.png",
  );
  Items item3 = new Items(
    title: "Sports",
    subtitle: "Lucy Mao going to Office",
    event: "",
    img: "assets/icons/icons8-soccer-ball-100.png",
  );
  Items item4 = new Items(
    title: "Cultural",
    subtitle: "Rose favirited your Post",
    event: "",
    img: "assets/icons/icons8-theatre-mask-100.png",
  );
  Items item5 = new Items(
    title: "Adventure",
    subtitle: "Homework, Design",
    event: "4 Items",
    img: "assets/icons/icons8-adventure-100.png",
  );
  Items item6 = new Items(
    title: "Alternative",
    subtitle: "",
    event: "2 Items",
    img: "assets/icons/icons8-dice-100.png",
  );
  Items item7 = new Items(
    title: "Double Date",
    subtitle: "Rose favirited your Post",
    event: "",
    img: "assets/icons/icons8-conference-100.png",
  );
  Items item8 = new Items(
    title: "Stay at home",
    subtitle: "Rose favirited your Post",
    event: "",
    img: "assets/icons/icons8-home-page-100.png",
  );
  Items item9 = new Items(
    title: "Party",
    subtitle: "Rose favirited your Post",
    event: "",
    img: "assets/icons/icons8-party-100.png",
  );
  Items item10 = new Items(
    title: "Ads",
    subtitle: "Rose favirited your Post",
    event: "",
    img: "assets/images/calendar.png",
  );

  Map<String, dynamic> categoriesToSubCategories;

  GridDashboard({
    Key key,
    this.categoriesToSubCategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Items> myList = [
      item1,
      item2,
      item3,
      item4,
      item5,
      item6,
      item7,
      item8,
      item9,
      item10
    ];
    return Flexible(
      child: GridView.count(
          childAspectRatio: 1.0,
          padding: EdgeInsets.only(left: 16, right: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          children: myList.map((data) {
            return GestureDetector(
              onTap: () {
                String title = data.title
                    .replaceAll(" ", "_")
                    .replaceAll("-", "_")
                    .toUpperCase();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubCategoryPage(
                            subCategoriesInput:
                                categoriesToSubCategories.containsKey(title)
                                    ? categoriesToSubCategories[title]
                                    : [],
                            categoryType: title,
                          )),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      data.img,
                      height: 70,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      data.title,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList()),
    );
  }
}

class Items {
  String title;
  String subtitle;
  String event;
  String img;

  Items({this.title, this.subtitle, this.event, this.img});
}
