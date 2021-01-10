import 'dart:convert';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:date_jar/login_page/components/background.dart';
import 'package:date_jar/model/Category.dart';
import 'package:date_jar/secrets.dart';
import 'package:date_jar/signup_page/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmAccountPage extends StatefulWidget {
  @override
  _ConfirmAccountPageState createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final cryptor = new PlatformStringCryptor();
  String errorMessage = '';

  Future<bool> login() async {
    final SharedPreferences prefs = await _prefs;
    String salt = prefs.getString('salt_key');
    final String key = await cryptor.generateKeyFromPassword(secret_key, salt);
    String password = await cryptor.decrypt(prefs.getString('password'), key);

    String username = prefs.getString('username');

    var res = await http.post(baseUrl + 'users/authenticate',
        body: jsonEncode({'username': username, 'password': password}));

    if (res.statusCode == 200) {
      var jsonResponse = json.decode(res.body);
      prefs.setString('username', username);
      prefs.setString('auth_token', jsonResponse["token"]);
      prefs.setString('picture', jsonResponse["picture"]);
      return true;
    } else {
      setState(() {
        errorMessage = 'Your account is not active yet';
      });
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
              SvgPicture.asset("assets/svgs/mail_sent.svg",
                  height: size.height * 0.35),
              SizedBox(
                height: size.height * 0.03,
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                      color: primaryLightColor,
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.error_outline),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              "An email was sent to confirm your account!",
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: FlatButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                        color: primaryColor,
                        onPressed: () async {
                          bool loggedIn = await login();
                          if (loggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage()),
                            );
                          }
                        },
                        child: Text(
                          "I've confirmed my account!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
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
