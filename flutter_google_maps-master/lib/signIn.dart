import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/forgotPassword.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_google_maps/main.dart';
import 'package:flutter_google_maps/driver.dart';
import 'package:flutter_google_maps/register.dart';
import 'package:flutter_google_maps/token.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
  final Map<String, dynamic> data = {
    'userName': usernameController.text,
    'passWord': passwordController.text,
  };

  final response = await http.post(
    Uri.parse('https://10.0.2.2:7145/api/Auth/Login'),
    body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
    headers: {
      'Content-Type': 'application/json', // Đặt header Content-Type thành application/json
    },
  );

  if (response.statusCode == 200) {
    // Xử lý đăng nhập thành công
   final Map<String, dynamic> responseData = json.decode(response.body);
  if (responseData['token'] != null) {
      TokenManager.setToken(responseData['token']);
      Map<String, dynamic> decodedToken = json.decode(
      String.fromCharCodes(
      base64Url.decode(TokenManager.getToken().split('.')[1]),
      ),
      );
      if(decodedToken['Role']=="Member"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
      }
      else if (decodedToken['Role']=="Driver"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverPage()));
      }
  } else {
     debugPrint("Error: ${response.statusCode}");
     debugPrint("Response body: ${response.body}");
  }
  }  else {
  debugPrint("Error: ${response.statusCode}");
  debugPrint("Response body: ${response.body}");
}

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 140,
              ),
              Image.asset('assets/image/ic_car_green.png'),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 6),
                child: Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 22, color: Color(0xff333333)),
                ),
              ),
              Text(
                'Login to continue using iCab',
                style: TextStyle(fontSize: 16, color: Color(0xff606470)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
                child: TextField(
                  controller: usernameController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Container(
                        width: 50,
                        child: Image.asset('assets/image/ic_mail.png'),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xffCED0D2),
                              width: 1
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(6))
                      )
                  ),
                ),
              ),
              TextField(
                controller: passwordController,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black
                ),
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Container(
                      width: 50,
                      child: Image.asset('assets/image/ic_phone.png'),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xffCED0D2),
                            width: 1
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    )
                ),
              ),
            GestureDetector(
              onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
              },
              child: Container(
              constraints: BoxConstraints.loose(Size(double.infinity, 30)),
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
              'Forgot password?',
              style: TextStyle(fontSize: 16, color: Color(0xff3277D8)),
              ),
              ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:login,
                    child: Text(
                      'Log In',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
               Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: RichText(
                    text: TextSpan(
                        text: 'New user? ',
                        style: TextStyle(color: Color(0xff606470), fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                                },
                              text: 'Sign up for a new account',
                              style: TextStyle(
                                  color: Color(0xff3277D8), fontSize: 16
                              )
                          )
                        ]
                    )
                ),
              )
            ]
          ),
      ),
      )
      );
  }
}
