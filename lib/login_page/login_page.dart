import 'dart:convert';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:date_jar/login_page/components/background.dart';
import 'package:date_jar/signup_page/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  String username;
  String password;
  bool _obscurePassword = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    checkTokenPresentInStorage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkTokenPresentInStorage() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.containsKey('auth_token')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  Future<bool> login() async {
    final SharedPreferences prefs = await _prefs;
    if (username.isNotEmpty && password.isNotEmpty) {
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
          if (res.statusCode == 401) {
            errorMessage = json.decode(res.body)['message'];
          } else {
            errorMessage = "Username and password didn't match";
          }
        });
        return false;
      }
    } else {
      setState(() {
        errorMessage = 'Username and password must be filled';
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
              SvgPicture.asset("assets/svgs/login_main.svg",
                  height: size.height * 0.35),
              SizedBox(
                height: size.height * 0.03,
              ),
              TextFieldContainer(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: primaryColor,
                      ),
                      hintText: "Username"),
                ),
              ),
              TextFieldContainer(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    icon: Icon(Icons.lock, color: primaryColor),
                    suffixIcon: GestureDetector(
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: primaryColor,
                      ),
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Text(
                errorMessage.isEmpty ? "" : errorMessage,
                style: TextStyle(color: Colors.red),
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
                      bool gotAuthToken = await login();
                      if (gotAuthToken) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }
                    },
                    child: Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account ? ",
                    style: TextStyle(color: primaryColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
