import 'dart:convert';
import 'dart:io';

import 'package:date_jar/constants.dart';
import 'package:date_jar/home_page/home_page.dart';
import 'package:date_jar/login_page/components/background.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _SignupState extends State<SignupPage> {
  String username = "";
  String password = "";
  String password2 = "";
  String email = "";
  bool _obscurePassword = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  File _image;
  AppState state;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    state = AppState.free;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> signup() async {
    final SharedPreferences prefs = await _prefs;
    if (username.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        password2.isEmpty) {
      setState(() {
        errorMessage = "All text fields are mandatory";
      });
      return false;
    }
    var profilePicBytesForUserMissingPic;
    if (_image == null) {}
    var res = await http.post(baseUrl + 'users/create',
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'picture': _image == null
              ? ''
              : base64Encode(await FlutterImageCompress.compressWithFile(
                  _image.path,
                  quality: 20))
        }));
    if (res.body.isNotEmpty && res.body.contains("{")) {
      var jsonResponse = json.decode(res.body);
      try {
        prefs.setString('username', username);
        prefs.setString('auth_token', jsonResponse["token"]);
        prefs.setString('picture', jsonResponse["picture"]);
      } catch (e) {
        return false;
      }
      return true;
    } else {
      setState(() {
        errorMessage = res.body;
      });
      return false;
    }
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });

    _cropImage();
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true),
        iosUiSettings: IOSUiSettings(
            title: 'Cropper',
            hidesNavigationBar: true,
            aspectRatioLockEnabled: true,
            rectWidth: 300,
            rectHeight: 300));
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage(context) {
    _image = null;
    setState(() {
      state = AppState.free;
    });
    _showPicker(context);
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
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (state == AppState.free)
                      _showPicker(context);
                    else if (state == AppState.picked)
                      _cropImage();
                    else if (state == AppState.cropped) _clearImage(context);
                  },
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: primaryColor,
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              _image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50)),
                            width: 100,
                            height: 100,
                            child: Icon(
                              _buildButtonIcon(),
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
              ),
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
                      email = value;
                    });
                  },
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: primaryColor,
                      ),
                      hintText: "Email"),
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
              TextFieldContainer(
                child: TextField(
                  onChanged: (value) {
                    password2 = value;
                    if (value != password) {
                      errorMessage = "Passwords don't match";
                    } else {
                      errorMessage = "";
                    }
                  },
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Repeat Password",
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
                      bool gotAuthToken = await signup();
                      if (gotAuthToken) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }
                    },
                    child: Text(
                      "Sign Up",
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
                    "Already Have an account ? ",
                    style: TextStyle(color: primaryColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
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

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  IconData _buildButtonIcon() {
    if (state == AppState.free)
      return Icons.camera_alt;
    else if (state == AppState.picked)
      return Icons.crop;
    else if (state == AppState.cropped) return Icons.clear;
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
