import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_google_maps/signIn.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  Future<void> register() async {
  final Map<String, dynamic> data = {
    'userName': usernameController.text,
    'passWord': passwordController.text,
    'email': emailController.text,
    'phoneNumber': phoneController.text,
  };

  final response = await http.post(
    Uri.parse('https://10.0.2.2:7145/api/Auth/Register'),
    body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
    headers: {
      'Content-Type': 'application/json', // Đặt header Content-Type thành application/json
    },
  );

  if (response.statusCode == 200) {
    // Xử lý đăng nhập thành công
    // Lưu thông tin đăng nhập hoặc mã thông báo
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }  else {
  debugPrint("Error: ${response.statusCode}");
  debugPrint("Response body: ${response.body}");
}

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff327708)),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
          child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    SizedBox(height: 80),
                    Image.asset('assets/image/ic_car_red.png'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 40, 0, 6),
                      child: Text(
                        'Welcome Aboard!',
                        style: TextStyle(fontSize: 22, color: Color(0xff333333)),
                      ),
                    ),
                    Text(
                      'Signup with iCab simple steps',
                      style: TextStyle(fontSize: 16, color: Color(0xff606470)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 80, 0, 20),
                      child: TextField(
                        controller: usernameController,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_user.png')),
                            border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(6)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_mail.png')),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(6)))),
                      ),
                    ),
                     Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: TextField(
                        controller: phoneController,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: 'PhoneNumber',
                            prefixIcon: Container(
                              width: 50,
                              child: Image.asset('assets/image/ic_mail.png')),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                                borderRadius: BorderRadius.all(Radius.circular(6)))),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Container(
                          width: 50,
                          child: Image.asset('assets/image/ic_lock.png')),
                          border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: register,
                          child: Text(
                            'Log up',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: RichText(
                          text: TextSpan(
                              text: 'Already a user? ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff606470)
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                      },
                                    text: 'Login now',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff3277D8)
                                    )
                                )
                              ]
                          )
                      )
                    )
                ],
              ),
          ),
      ),
    );
  }
}
